#!/usr/bin/env bash
set -euo pipefail

# Activate venv if exists
if [ -d ".venv" ]; then
  source .venv/bin/activate
fi

export FLASK_ENV=production
python chatbot_service.py
