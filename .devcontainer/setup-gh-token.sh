#!/bin/bash
# Setup GitHub CLI authentication using git credential helper

# Find the git credential file
CRED_FILE=$(git config --get credential.github.com.helper | sed 's/.*cat //;s/[^/]*$//' | tr -d "';" | xargs -I {} find {} -type f 2>/dev/null | head -1)

if [ -n "$CRED_FILE" ] && [ -f "$CRED_FILE" ]; then
    # Extract the GitHub token
    GITHUB_TOKEN=$(grep "^password=" "$CRED_FILE" | cut -d= -f2)
    
    if [ -n "$GITHUB_TOKEN" ]; then
        # Set GH_TOKEN for the current session
        export GH_TOKEN="$GITHUB_TOKEN"
        
        # Add to shell profile for future sessions
        if ! grep -q "export GH_TOKEN=" ~/.bashrc 2>/dev/null; then
            echo "" >> ~/.bashrc
            echo "# GitHub CLI authentication" >> ~/.bashrc
            echo "CRED_FILE=\$(git config --get credential.github.com.helper | sed 's/.*cat //;s/[^/]*\$//' | tr -d \"';\" | xargs -I {} find {} -type f 2>/dev/null | head -1)" >> ~/.bashrc
            echo "if [ -n \"\$CRED_FILE\" ] && [ -f \"\$CRED_FILE\" ]; then" >> ~/.bashrc
            echo "    export GH_TOKEN=\$(grep \"^password=\" \"\$CRED_FILE\" | cut -d= -f2)" >> ~/.bashrc
            echo "fi" >> ~/.bashrc
        fi
        
        echo "✅ GitHub CLI authenticated successfully"
        gh auth status 2>&1 | head -5
    else
        echo "⚠️  Could not extract GitHub token from credential file"
    fi
else
    echo "⚠️  Git credential file not found"
fi
