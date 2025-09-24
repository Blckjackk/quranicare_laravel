## QuraniCare Qalbu Chatbot – Full Documentation

### 1) Arsitektur
- Flutter (UI)
  - Kirim chat → Laravel API `POST /api/qalbu/chatbot`
  - Tampilkan balasan `reply` dari backend
  - Untuk debug cepat, bisa langsung kirim ke Flask `POST /chat`
- Laravel (API gateway)
  - Simpan pesan user & AI ke `qalbu_messages`, mengelola `qalbu_conversations`
  - Proxy request ke Python Flask NLP Service
  - Catat pertanyaan yang belum terjawab ke `unanswered_questions`
- Python Flask (NLP)
  - Load `ai_knowledge_base` ke memori → TF‑IDF index
  - Retrieval + boosting (emosi, effectiveness_score, prioritas Qur’an)
  - Fallback cari langsung ke DB `quran_ayahs` + `quran_surahs`
  - Kembalikan JSON: `reply`, `ai_response_type`, `ai_sources`, `candidates`, `meta`
- MariaDB
  - Tabel: `ai_knowledge_base`, `quran_ayahs`, `quran_surahs`, `qalbu_conversations`, `qalbu_messages`, `unanswered_questions`

### 2) Persiapan Database
- Pastikan database `quranicare_db` ada dan dikonfigurasi di Laravel & Flask
- Seed Qur’an (jika belum): `php artisan db:seed --class=QuranSeeder`
- Seed Knowledge Base (contoh):
  - MariaDB console → `USE quranicare_db;`
  - `SOURCE chatbot/ai_kb_seed.sql;`
- Cek data aktif: `SELECT COUNT(*) FROM ai_knowledge_base WHERE is_active=1;`

### 3) Menjalankan Python Flask NLP Service
Lokasi: `chatbot/`

- Dependencies
```
python -m venv .venv
. .venv/bin/activate   # Windows: .venv\Scripts\activate
pip install -r requirements.txt
```
- Environment (Windows cmd contoh)
```
set DB_HOST=127.0.0.1
set DB_PORT=3306
set DB_NAME=quranicare_db
set DB_USER=root
set DB_PASS=
set PORT=5000
set SIMILARITY_THRESHOLD=0.25
set TOP_K=3
set KB_RELOAD_SECONDS=300
```
- Run
```
python chatbot_service.py
```
- Health & debug
  - `GET /health` → `{ status, kb_items }`
  - `GET /kb_stats` → cek koneksi DB & jumlah KB aktif
  - `POST /reload` → paksa reload index

### 4) Menjalankan Laravel API Gateway
Lokasi: `quranicare_be/`

- Env minimal
```
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=quranicare_db
DB_USERNAME=root
DB_PASSWORD=

CHATBOT_BASE_URI=http://127.0.0.1:5000
```
- Migrasi (termasuk tabel `unanswered_questions`)
```
php artisan migrate
```
- Jalankan server (akses dari emulator Android via 10.0.2.2)
```
php artisan serve --host=0.0.0.0 --port=8000
```
- Cek route terdaftar
```
php artisan route:list | findstr /I "qalbu/chatbot"
```

### 5) Endpoint Laravel yang dipakai Flutter
- Public (tanpa auth):
  - `POST /api/qalbu/chatbot` → forward ke Flask, simpan pesan
  - `POST /api/qalbu/chatbot/feedback` → simpan feedback, optional forward ke Flask `/feedback`

Request contoh:
```
POST /api/qalbu/chatbot
Content-Type: application/json
{
  "user_id": 1,
  "message": "saya sedih",
  "conversation_id": 123   // optional
}
```

Respons contoh:
```
{
  "conversation_id": 123,
  "reply": "MasyaAllah, ...",
  "ai_response_type": "quran_reference",
  "ai_sources": [{"id":12,"content_type":"quran_ayah","content_id":45,"score":0.78}],
  "candidates": [{"id":12,"score":0.78,"content_type":"quran_ayah"}],
  "meta": {"chosen_id":12}
}
```

### 6) Endpoint Flask
- `POST /chat` body: `{ message, user_emotion?, conversation_id? }`
- `POST /feedback` body: `{ kb_id, helpful?, rating?, comment? }`
- `GET /health`, `GET /kb_stats`, `POST /reload`

### 7) Integrasi Flutter
- Default: UI panggil Laravel
  - Emulator Android: `--dart-define=API_BASE_URL=http://10.0.2.2:8000/api`
  - Browser/Web/desktop: `--dart-define=API_BASE_URL=http://127.0.0.1:8000/api`
- Alternatif debug cepat: panggil Flask langsung
  - `--dart-define=CHAT_BASE_URL=http://10.0.2.2:5000` (emulator) atau `http://127.0.0.1:5000` (web/desktop)
- File referensi:
  - `quranicare/lib/screens/qalbu_chat_screen.dart` (memakai Laravel proxy)
  - `quranicare/lib/services/chat_service.dart` (langsung ke Flask)

### 8) Model & Tabel Inti
- `ai_knowledge_base` (konten):
  - `id, content_type(enum), content_id, emotion_trigger, context_keywords, guidance_text, suggested_actions(JSON), usage_count, effectiveness_score, is_active, created_at, updated_at`
- `quran_ayahs`, `quran_surahs` untuk fallback Qur’an
- `qalbu_conversations`, `qalbu_messages` untuk log chat
- `unanswered_questions` untuk pertanyaan yang belum terjawab

Laravel models yang disesuaikan:
- `App/Models/QalbuConversation.php` → `$fillable`: `user_id, title, conversation_type, user_emotion, context_data, is_active, last_message_at`
- `App/Models/QalbuMessage.php` → `$fillable`: `qalbu_conversation_id, sender, message, ai_sources, suggested_actions, ai_response_type, is_helpful, user_feedback`
- `App/Models/UnansweredQuestion.php` → `$fillable` + `$casts['context'=>'array']`

### 9) Cara Kerja NLP
- Preprocessing teks → TF‑IDF → cosine similarity
- Ambil top‑k kandidat dari `ai_knowledge_base`
- Boosting skor:
  - Kecocokan `emotion_trigger`
  - `effectiveness_score` tinggi
  - Prioritas `content_type = quran_ayah`
- Jika skor rendah → fallback query langsung ke `quran_ayahs` (FULLTEXT / LIKE)
- Render template jawaban (pembuka → guidance → saran → sumber)
- Update `usage_count` (async); `/feedback` meng-update `effectiveness_score`

### 10) Troubleshooting
- `kb_items = 0` di `/health`
  - Cek `/kb_stats` → koneksi DB & hitung KB aktif
  - Seed `chatbot/ai_kb_seed.sql` → `SELECT COUNT(*) FROM ai_knowledge_base WHERE is_active=1;`
  - Pastikan env Flask: `DB_HOST/DB_NAME/DB_USER/DB_PASS`
  - `POST /reload` setelah seeding
- Flutter Web: `ERR_CONNECTION_TIMED_OUT` ke `10.0.2.2`
  - 10.0.2.2 hanya untuk Android emulator. Web gunakan `127.0.0.1`
  - Jalankan: `flutter run -d chrome --dart-define=API_BASE_URL=http://127.0.0.1:8000/api`
- Android emulator: timeout ke Laravel
  - Pastikan Laravel bind `0.0.0.0:8000`
  - Firewall Windows izinkan php/artisan pada port 8000
  - Flutter run: `--dart-define=API_BASE_URL=http://10.0.2.2:8000/api`
- `GET not supported for /api/qalbu/chatbot`
  - Endpoint memang POST; test dengan POST (curl/Postman/Flutter)
- CORS (Flutter Web)
  - Laravel `config/cors.php`: untuk dev, longgarkan `allowed_origins: ['*']`, `paths: ['api/*', ...]` → `php artisan config:clear`

### 11) Roadmap/Upgrade
- Ganti TF‑IDF → embeddings (sentence-transformers) + FAISS/Elastic
- Intent classification untuk rute jawaban
- Admin UI untuk mengelola `unanswered_questions` → tambah ke `ai_knowledge_base`

### 12) Quick Commands Recap
- Flask: `python chatbot_service.py` → `GET /health`
- Laravel: `php artisan serve --host=0.0.0.0 --port=8000`
- Test host: 
```
curl -X POST http://127.0.0.1:8000/api/qalbu/chatbot \
 -H "Content-Type: application/json" \
 -d "{\"user_id\":1,\"message\":\"tes\"}"
```
- Flutter Android: `flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000/api`
- Flutter Web: `flutter run -d chrome --dart-define=API_BASE_URL=http://127.0.0.1:8000/api`

---
Jika ada error, sertakan pesan/log ringkas (Flask `/kb_stats`, Laravel `storage/logs/laravel.log`, dan Network tab Flutter/Web) agar perbaikan tepat sasaran.

