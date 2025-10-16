#!/bin/bash
# Create or update the .env file with required environment variables
cat > .env << 'EOF'
SEARXNG_BASE_URL="http://searxng:8080"
REDIS_BASE_URL="redis://redis:6379/0"
WORK_DIR="/workspaces/agenticSeek"
OLLAMA_PORT="11434"
LM_STUDIO_PORT="1234"
CUSTOM_ADDITIONAL_LLM_PORT="11435"
OPENAI_API_KEY='optional'
DEEPSEEK_API_KEY='optional'
OPENROUTER_API_KEY='optional'
TOGETHER_API_KEY='optional'
GOOGLE_API_KEY='optional'
ANTHROPIC_API_KEY='optional'
EOF
pip install uvicorn && \
pip install aiofiles && \
pip install fastapi && \
pip install python-dotenv && \
pip install ollama && \
pip install openai && \
pip install termcolor && \
pip install kokoro && \
pip install adaptive_classifier && \
pip install selenium && \
pip install fake-useragent && \
pip install selenium-stealth && \
pip install undetected-chromedriver && \
pip install chromedriver-autoinstaller && \
pip install markdownify && \
pip install langid && \
sudo apt-get update && \
sudo apt-get install -y portaudio19-dev && \
pip install pyaudio && \
pip install celery && \
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -O /tmp/google-chrome-stable_current_amd64.deb && \
sudo apt-get install -y /tmp/google-chrome-stable_current_amd64.deb && \
sudo apt-get install -y libnss3 libatk-bridge2.0-0t64 libgtk-3-0t64 libx11-xcb1 libxcb-dri3-0 libxcomposite1 libxdamage1 libxrandr2 libgbm1 libasound2t64 libpangocairo-1.0-0 libcups2t64 && \
# python3 api.py & \
sudo apt-get update && \
sudo apt-get install -y xdg-utils && \
curl -fsSL https://ollama.com/install.sh | sh && \
export OLLAMA_HOST=0.0.0.0:11434 && \
ollama serve & \
sleep 5 && \
./start_services.sh full & \
sleep 3 && \
xdg-open http://localhost:3000
