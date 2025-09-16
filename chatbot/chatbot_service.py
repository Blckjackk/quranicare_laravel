import os
import json
import time
import threading
import re
from typing import List, Dict, Any

from flask import Flask, request, jsonify
from flask_cors import CORS
import mysql.connector

# ML/NLP
import numpy as np
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity


app = Flask(__name__)
CORS(app, resources={r"/*": {"origins": "*"}})


# ------------------------- Config -------------------------
DB_CONFIG = {
    "host": os.getenv("DB_HOST", "127.0.0.1"),
    "user": os.getenv("DB_USER", "root"),
    "password": os.getenv("DB_PASS", ""),
    "database": os.getenv("DB_NAME", "quranicare_db"),
    "port": int(os.getenv("DB_PORT", 3306)),
}

SIMILARITY_THRESHOLD = float(os.getenv("SIMILARITY_THRESHOLD", 0.25))
TOP_K = int(os.getenv("TOP_K", 3))
RELOAD_SECONDS = int(os.getenv("KB_RELOAD_SECONDS", 300))


# ------------------------- Global state -------------------------
kb_rows: List[Dict[str, Any]] = []
corpus_texts: List[str] = []
vectorizer: TfidfVectorizer | None = None
tfidf_matrix = None
kb_lock = threading.Lock()


# ------------------------- Utilities -------------------------
_ID_STOPWORDS = {
    "dan", "yang", "di", "ke", "dari", "untuk", "itu", "ini", "atau",
    "pada", "dengan", "karena", "sebagai", "dalam", "adalah", "apa", "saya",
    "aku", "kamu", "kami", "kita", "mereka", "ia", "dia", "tidak", "ya",
}


def clean_text(text: str) -> str:
    if not text:
        return ""
    s = text.lower()
    s = re.sub(r"[^a-z0-9\u0600-\u06FF\s]", " ", s)
    s = re.sub(r"\s+", " ", s).strip()
    tokens = [t for t in s.split() if t not in _ID_STOPWORDS]
    return " ".join(tokens)


def connect_db():
    return mysql.connector.connect(**DB_CONFIG)


def load_kb_from_db():
    global kb_rows, corpus_texts, vectorizer, tfidf_matrix
    with kb_lock:
        db = connect_db()
        cur = db.cursor(dictionary=True)
        cur.execute(
            """
            SELECT id, content_type, content_id, emotion_trigger, context_keywords,
                   guidance_text, suggested_actions, usage_count, effectiveness_score
            FROM ai_knowledge_base
            WHERE is_active = 1
            ORDER BY id ASC
            """
        )
        rows = cur.fetchall() or []
        cur.close()
        db.close()

        kb_rows = []
        corpus_texts = []
        for r in rows:
            combined = " ".join(
                filter(
                    None,
                    [
                        str(r.get("emotion_trigger") or ""),
                        str(r.get("context_keywords") or ""),
                        str(r.get("guidance_text") or ""),
                    ],
                )
            )
            kb_rows.append(r)
            corpus_texts.append(clean_text(combined))

        if corpus_texts:
            vectorizer = TfidfVectorizer(max_features=20000)
            tfidf_matrix = vectorizer.fit_transform(corpus_texts)
        else:
            vectorizer = None
            tfidf_matrix = None


# Initial load
load_kb_from_db()


def periodic_reload(interval_seconds: int):
    while True:
        time.sleep(interval_seconds)
        try:
            load_kb_from_db()
            app.logger.info("Knowledge base reloaded: %s items", len(kb_rows))
        except Exception as e:
            app.logger.exception("KB reload failed: %s", e)


threading.Thread(target=periodic_reload, args=(RELOAD_SECONDS,), daemon=True).start()


# ------------------------- Core search -------------------------
def search_candidates(user_text: str, top_k: int) -> List[Dict[str, Any]]:
    global vectorizer, tfidf_matrix, kb_rows
    q = clean_text(user_text)
    if not q or vectorizer is None or tfidf_matrix is None or not kb_rows:
        return []

    q_vec = vectorizer.transform([q])
    sims = cosine_similarity(q_vec, tfidf_matrix).flatten()
    idxs = np.argsort(-sims)[:top_k]
    results: List[Dict[str, Any]] = []
    for i in idxs:
        score = float(sims[i])
        if score <= 0:
            continue
        kb = dict(kb_rows[i])
        kb["_score"] = score
        results.append(kb)
    return results


def boost_scores_by_emotion_and_effectiveness(candidates: List[Dict[str, Any]], user_emotion: str | None) -> List[Dict[str, Any]]:
    for c in candidates:
        boost = 0.0
        et = (c.get("emotion_trigger") or "").lower()
        if user_emotion and et and user_emotion.lower() in et:
            boost += 0.15
        try:
            eff = float(c.get("effectiveness_score") or 0.0)
            boost += min(max(eff, 0.0), 1.0) * 0.1
        except Exception:
            pass
        # Prioritize Quran ayah when available
        if (c.get("content_type") or "") == "quran_ayah":
            boost += 0.2
        c["_score"] = c["_score"] + boost
    candidates.sort(key=lambda x: -x["_score"])
    return candidates


def render_reply_template(kb_item: Dict[str, Any]) -> str:
    guidance = kb_item.get("guidance_text") or ""
    content_type = kb_item.get("content_type") or ""
    suggested_raw = kb_item.get("suggested_actions") or "[]"
    try:
        suggested = json.loads(suggested_raw) if isinstance(suggested_raw, str) else (suggested_raw or [])
    except Exception:
        suggested = []

    opening = "MasyaAllah, terima kasih atas pertanyaannya."
    source_note = f"Sumber: {content_type} (kb_id: {kb_item.get('id')})"

    action_text = ""
    if suggested:
        if isinstance(suggested, list):
            action_text = "Saran tindakan: " + "; ".join([str(x) for x in suggested])
        else:
            action_text = "Saran tindakan: " + str(suggested)

    reply_parts = [opening, guidance]
    if action_text:
        reply_parts.append(action_text)
    reply_parts.append(source_note)
    return "\n\n".join([p for p in reply_parts if p])


def search_quran_direct(user_text: str, top_k: int = 1) -> List[Dict[str, Any]]:
    """Direct DB search on quran_ayahs using fulltext if available, else LIKE.
    Returns a list of items shaped similarly to kb rows for uniform handling.
    """
    try:
        db = connect_db()
        cur = db.cursor(dictionary=True)
        q = user_text.strip()
        # Try FULLTEXT first (requires index). Fallback to LIKE.
        try:
            cur.execute(
                """
                SELECT qa.id AS ayah_id, qa.quran_surah_id, qa.number AS ayah_number,
                       qa.text_indonesian, qa.text_arabic, qs.number AS surah_number,
                       qs.name_indonesian AS surah_name
                FROM quran_ayahs qa
                JOIN quran_surahs qs ON qs.id = qa.quran_surah_id
                WHERE MATCH (qa.text_indonesian, qa.tafsir_indonesian) AGAINST (? IN NATURAL LANGUAGE MODE)
                LIMIT %s
                """,
                (q, top_k),
            )
            rows = cur.fetchall() or []
        except Exception:
            like = f"%{q}%"
            cur.execute(
                """
                SELECT qa.id AS ayah_id, qa.quran_surah_id, qa.number AS ayah_number,
                       qa.text_indonesian, qa.text_arabic, qs.number AS surah_number,
                       qs.name_indonesian AS surah_name
                FROM quran_ayahs qa
                JOIN quran_surahs qs ON qs.id = qa.quran_surah_id
                WHERE qa.text_indonesian LIKE %s OR qa.tafsir_indonesian LIKE %s
                LIMIT %s
                """,
                (like, like, top_k),
            )
            rows = cur.fetchall() or []
        cur.close()
        db.close()
        results: List[Dict[str, Any]] = []
        for r in rows:
            guidance = (
                f"{r.get('text_indonesian') or ''}\n\n"
                f"(QS. {r.get('surah_name')}:{r.get('ayah_number')})"
            ).strip()
            results.append({
                "id": int(r.get("ayah_id")),
                "content_type": "quran_ayah",
                "content_id": int(r.get("ayah_id")),
                "emotion_trigger": None,
                "context_keywords": None,
                "guidance_text": guidance,
                "suggested_actions": json.dumps(["Renungkan makna ayat ini", "Perbanyak doa dan dzikir"]),
                "_score": 0.51,  # baseline moderate confidence
            })
        return results
    except Exception as e:
        app.logger.warning("Quran direct search failed: %s", e)
        return []


def async_update_usage(kb_id: int):
    try:
        db = connect_db()
        cur = db.cursor()
        cur.execute("UPDATE ai_knowledge_base SET usage_count = usage_count + 1 WHERE id = %s", (kb_id,))
        db.commit()
        cur.close()
        db.close()
    except Exception as e:
        app.logger.exception("Failed update usage: %s", e)


# ------------------------- HTTP Endpoints -------------------------
@app.route("/health", methods=["GET"]) 
def health():
    return jsonify({"status": "ok", "kb_items": len(kb_rows)})


@app.route("/kb_stats", methods=["GET"]) 
def kb_stats():
    try:
        db = connect_db()
        cur = db.cursor()
        cur.execute("SELECT COUNT(*) FROM ai_knowledge_base WHERE is_active = 1")
        count = cur.fetchone()[0]
        cur.close()
        db.close()
        return jsonify({
            "db_host": DB_CONFIG.get("host"),
            "db_name": DB_CONFIG.get("database"),
            "active_kb_count": int(count),
        })
    except Exception as e:
        return jsonify({"error": str(e), "db_host": DB_CONFIG.get("host"), "db_name": DB_CONFIG.get("database")}), 500


@app.route("/reload", methods=["POST"]) 
def reload_kb():
    try:
        load_kb_from_db()
        return jsonify({"status": "reloaded", "kb_items": len(kb_rows)})
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route("/chat", methods=["POST"]) 
def chat():
    payload = request.get_json(force=True) or {}
    user_message = (payload.get("message") or "").strip()
    user_emotion = payload.get("user_emotion")
    conversation_id = payload.get("conversation_id")  # forwarded-only

    if not user_message:
        return jsonify({"error": "no message provided"}), 400

    candidates = search_candidates(user_message, TOP_K)
    candidates = boost_scores_by_emotion_and_effectiveness(candidates, user_emotion)

    if not candidates or candidates[0]["_score"] < SIMILARITY_THRESHOLD:
        # Try direct Quran search before giving up
        quran_hits = search_quran_direct(user_message, top_k=1)
        if quran_hits:
            chosen = quran_hits[0]
            reply_text = render_reply_template(chosen)
            ai_sources = [{
                "id": chosen["id"],
                "content_type": chosen.get("content_type"),
                "content_id": chosen.get("content_id"),
                "score": chosen.get("_score"),
            }]
            return jsonify({
                "reply": reply_text,
                "ai_response_type": "quran_reference",
                "ai_sources": ai_sources,
                "candidates": [{"id": c["id"], "score": c.get("_score", 0.0), "content_type": c.get("content_type")} for c in quran_hits],
                "meta": {"reason": "fallback_quran"}
            })

        fallback_text = (
            "Maaf, saya belum menemukan dalil yang sesuai untuk pertanyaan ini. "
            "Pertanyaan Anda akan kami catat agar bisa dijawab di kemudian hari."
        )
        return jsonify({
            "reply": fallback_text,
            "ai_response_type": "text",
            "ai_sources": [],
            "candidates": [],
            "meta": {"reason": "low_similarity"}
        })

    chosen = candidates[0]
    reply_text = render_reply_template(chosen)

    ai_sources = [{
        "id": chosen["id"],
        "content_type": chosen.get("content_type"),
        "content_id": chosen.get("content_id"),
        "score": chosen.get("_score"),
    }]

    threading.Thread(target=async_update_usage, args=(chosen["id"],), daemon=True).start()

    return jsonify({
        "reply": reply_text,
        "ai_response_type": "quran_reference" if chosen.get("content_type") == "quran_ayah" else "text",
        "ai_sources": ai_sources,
        "candidates": [{"id": c["id"], "score": c["_score"], "content_type": c.get("content_type")} for c in candidates],
        "meta": {"chosen_id": chosen["id"], "conversation_id": conversation_id}
    })


@app.route("/feedback", methods=["POST"]) 
def feedback():
    payload = request.get_json(force=True) or {}
    kb_id = payload.get("kb_id")
    helpful = payload.get("helpful")
    rating = payload.get("rating")
    _ = payload.get("comment")  # optionally log elsewhere

    if not kb_id:
        return jsonify({"error": "kb_id required"}), 400

    try:
        db = connect_db()
        cur = db.cursor()
        cur.execute("SELECT usage_count, effectiveness_score FROM ai_knowledge_base WHERE id = %s", (kb_id,))
        row = cur.fetchone()
        if row is not None:
            usage_count = int(row[0] or 0)
            eff = float(row[1] or 0.0)
            new_usage = usage_count + 1

            if rating is not None:
                r = float(rating)
                if r > 1:
                    r = r / 5.0
            else:
                r = 1.0 if helpful else 0.0

            new_eff = (eff * usage_count + r) / new_usage if new_usage > 0 else r
            cur.execute(
                "UPDATE ai_knowledge_base SET usage_count = %s, effectiveness_score = %s WHERE id = %s",
                (new_usage, new_eff, kb_id),
            )
            db.commit()
        cur.close()
        db.close()
    except Exception as e:
        app.logger.exception("Failed to store feedback: %s", e)
        return jsonify({"error": "db error"}), 500

    return jsonify({"status": "ok"})


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=int(os.getenv("PORT", 5000)), debug=True)


