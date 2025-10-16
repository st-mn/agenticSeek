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

# Download and configure faster LLM model for better performance
echo "Setting up optimized LLM configuration for faster responses..."

# Try to pull the fastest model first, fallback to medium if needed
if ollama pull llama3.2:1b; then
    echo "Successfully pulled llama3.2:1b (fastest model)"
    sed -i 's/provider_model = .*/provider_model = llama3.2:1b/' config.ini
elif ollama pull llama3.2:3b; then
    echo "Successfully pulled llama3.2:3b (balanced model)"
    sed -i 's/provider_model = .*/provider_model = llama3.2:3b/' config.ini
else
    echo "Warning: Could not pull optimized models, keeping existing configuration"
fi

echo "LLM optimization complete - configured for optimal response times" && \

# Fix frontend timeout issue that causes "Unable to get a response"
echo "Fixing frontend timeout configuration..."

# Create a patch to fix the axios timeout issue
cat > fix_frontend_timeout.sh << 'EOF'
#!/bin/bash
cd frontend/agentic-seek-front/src

# Add timeout to the axios post request
sed -i '/const res = await axios.post.*query.*{/,/});/{
    /});/{
        i\      }, {\
        i\        timeout: 120000 // 2 minutes timeout for LLM processing
    }
}' App.js

echo "Frontend timeout fix applied"
EOF

chmod +x fix_frontend_timeout.sh
./fix_frontend_timeout.sh

# Check if running in GitHub Codespaces and setup port forwarding
if [ -n "$CODESPACE_NAME" ]; then
    echo "Detected GitHub Codespace environment. Setting up port forwarding..."
    
    # Install GitHub CLI if not already installed
    if ! command -v gh &> /dev/null; then
        echo "Installing GitHub CLI..."
        curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
        sudo apt update
        sudo apt install gh -y
    fi
    
    # Wait a moment for services to start
    sleep 10 && \
    
    # Make ports public using gh CLI (this will run in background)
    (sleep 15 && gh codespace ports visibility 7777:public --codespace $CODESPACE_NAME > /dev/null 2>&1 &) && \
    (sleep 15 && gh codespace ports visibility 3000:public --codespace $CODESPACE_NAME > /dev/null 2>&1 &) && \
    (sleep 15 && gh codespace ports visibility 11434:public --codespace $CODESPACE_NAME > /dev/null 2>&1 &) && \
    
    echo "Port forwarding setup initiated for ports 7777, 3000, and 11434"
fi

# Start services with monitoring
./start_services.sh full & \

# Create API monitoring script to restart if it crashes
cat > monitor_api.sh << 'EOF'
#!/bin/bash
while true; do
    if ! pgrep -f "python3 api.py" > /dev/null; then
        echo "$(date): API server not running, restarting..."
        cd /workspaces/agenticSeek
        python3 api.py &
    fi
    sleep 10
done
EOF
chmod +x monitor_api.sh
./monitor_api.sh &

echo "AgenticSeek started with API monitoring enabled"
sleep 3 && \
xdg-open http://localhost:3000
