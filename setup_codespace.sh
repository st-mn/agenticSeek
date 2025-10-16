#!/bin/bash

# Setup script for GitHub Codespaces
# This script automatically configures the backend URL for the current codespace

echo "Setting up AgenticSeek for GitHub Codespaces..."

# Check if we're in a codespace
if [ -n "$CODESPACE_NAME" ]; then
    echo "Detected GitHub Codespace: $CODESPACE_NAME"
    
    # Get the codespace URL
    CODESPACE_URL="https://${CODESPACE_NAME}-7777.${GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN}"
    
    echo "Configuring backend URL: $CODESPACE_URL"
    
    # Update the .env.development file
    cat > frontend/agentic-seek-front/.env.development << EOF
# Environment-specific configuration for development
# This file is loaded in development mode and overrides .env
REACT_APP_BACKEND_URL=$CODESPACE_URL
EOF
    
    echo "Configuration updated successfully!"
    echo "Backend URL set to: $CODESPACE_URL"
else
    echo "Not running in GitHub Codespaces, using default configuration"
fi

echo "Setup complete!"