## Qalbu NLP Chatbot Service

Python Flask service for retrieval-based Islamic guidance. It loads active rows from `ai_knowledge_base`, builds a TF-IDF index, and replies with natural templates plus `ai_sources` for Laravel logging.

### Endpoints
- POST `/chat`
  - Request JSON: `{ "message": string, "user_emotion": string|null, "conversation_id": number|string|null }`
  - Response JSON: `{ reply, ai_response_type, ai_sources, candidates, meta }`
- POST `/feedback`
  - Request JSON: `{ kb_id: number, helpful?: 0|1, rating?: number(0-1 or 0-5), comment?: string }`
- GET `/health`

### Environment variables
- DB_HOST, DB_PORT, DB_NAME, DB_USER, DB_PASS
- PORT (default 5000), SIMILARITY_THRESHOLD (default 0.25), TOP_K (default 3), KB_RELOAD_SECONDS (default 300)

Create a local `.env` (optional) or export env vars via your shell or process manager.

### Setup (local)
1) Create venv and install deps
```
python -m venv .venv
. .venv/bin/activate  # Windows: .venv\\Scripts\\activate
pip install -r requirements.txt
```
2) Run service
```
python chatbot_service.py
```
3) Test
```
curl -X POST http://localhost:5000/chat \
  -H "Content-Type: application/json" \
  -d '{"message":"Saya sedang sedih dan butuh nasihat"}'
```

### Windows quick run
Double-click `run_windows.bat` (edit inside to set env vars if needed).

### Linux/macOS quick run
```
chmod +x run_unix.sh
./run_unix.sh
```

### Docker
Build and run:
```
docker build -t qalbu-chatbot .
docker run --rm -p 5000:5000 \
  -e DB_HOST=host.docker.internal -e DB_PORT=3306 \
  -e DB_NAME=quranicare_db -e DB_USER=root -e DB_PASS= \
  qalbu-chatbot
```

### DB expectations
`ai_knowledge_base` columns used: `id, content_type, content_id, emotion_trigger, context_keywords, guidance_text, suggested_actions, usage_count, effectiveness_score, is_active`.

You can preload sample data with `ai_kb_seed.sql`.

### Laravel integration quick notes
- Laravel POST `/chatbot` → forward body to this service `/chat`
- Save AI reply to `qalbu_messages` with `ai_sources`, `ai_response_type`
- On user feedback → POST `/feedback` here and/or update DB directly
