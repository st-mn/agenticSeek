#!/bin/bash

# Script to make port 7777 public in GitHub Codespaces
echo "🔧 Setting up AgenticSeek for GitHub Codespaces..."

# Check if we're in a codespace
if [ -n "$CODESPACE_NAME" ]; then
    echo "📍 Detected GitHub Codespace: $CODESPACE_NAME"
    
    # Try to make port 7777 public using gh CLI
    if command -v gh &> /dev/null; then
        echo "🔓 Attempting to make port 7777 public..."
        gh codespace ports visibility 7777:public --codespace $CODESPACE_NAME 2>/dev/null || echo "⚠️  Could not automatically set port visibility"
    fi
    
    # Construct the correct backend URL
    BACKEND_URL="https://${CODESPACE_NAME}-7777.${GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN}"
    echo "🌐 Backend URL should be: $BACKEND_URL"
    
    # Update the .env.development file
    cat > frontend/agentic-seek-front/.env.development << EOF
# Environment-specific configuration for development
# Auto-generated for GitHub Codespaces
REACT_APP_BACKEND_URL=$BACKEND_URL
EOF
    
    echo "✅ Updated frontend configuration"
    
    # Test if the backend is reachable
    echo "🔍 Testing backend connectivity..."
    if curl -s --max-time 5 "$BACKEND_URL/health" > /dev/null; then
        echo "✅ Backend is reachable at $BACKEND_URL"
    else
        echo "❌ Backend not reachable. You may need to:"
        echo "   1. Go to the 'Ports' tab in VS Code"
        echo "   2. Find port 7777"
        echo "   3. Right-click and select 'Port Visibility' > 'Public'"
        echo "   4. Refresh the frontend"
    fi
else
    echo "📍 Not in GitHub Codespace - using localhost configuration"
    cat > frontend/agentic-seek-front/.env.development << EOF
# Environment-specific configuration for development
REACT_APP_BACKEND_URL=http://localhost:7777
EOF
fi

echo "🚀 Setup complete!"