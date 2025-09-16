@echo off
setlocal ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION

REM Activate venv if exists
IF EXIST .venv\Scripts\activate.bat (
    CALL .venv\Scripts\activate.bat
)

SET FLASK_ENV=production
python chatbot_service.py

endlocal
