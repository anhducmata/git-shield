#!/bin/bash

# git-shield test script
# This script helps you test your git-shield installation

set -e

echo "🧪 Testing git-shield installation..."

# Check if git-shield is installed
TEMPLATE_DIR="$HOME/.git-shield-template"
if [ ! -d "$TEMPLATE_DIR" ]; then
    echo "❌ git-shield is not installed. Run install.sh first."
    exit 1
fi

if [ ! -f "$TEMPLATE_DIR/hooks/pre-commit" ]; then
    echo "❌ git-shield pre-commit hook not found. Run install.sh first."
    exit 1
fi

echo "✅ git-shield is installed."

# Check global git config
GIT_TEMPLATE=$(git config --global init.templateDir 2>/dev/null || echo "")
if [ "$GIT_TEMPLATE" != "$TEMPLATE_DIR" ]; then
    echo "❌ Global git template directory not configured correctly."
    echo "   Expected: $TEMPLATE_DIR"
    echo "   Found: $GIT_TEMPLATE"
    exit 1
fi

echo "✅ Global git configuration is correct."

# Create a test repository
TEST_DIR="/tmp/git-shield-test-$$"
mkdir -p "$TEST_DIR"
cd "$TEST_DIR"

echo "📁 Creating test repository..."

# Initialize git repository (this should apply the global template)
git init > /dev/null 2>&1

# Check if the hook was applied
if [ ! -f ".git/hooks/pre-commit" ]; then
    echo "❌ Pre-commit hook was not applied to new repository."
    exit 1
fi

echo "✅ Pre-commit hook was applied to new repository."

# Test with a file containing no secrets
echo "Testing with clean file..."
echo "This is a test file with no secrets." > test.txt
git add test.txt
if git commit -m "Test commit" > /dev/null 2>&1; then
    echo "✅ Clean file test passed."
else
    echo "❌ Clean file test failed."
    exit 1
fi

# Test with traditional secrets
echo "Testing with traditional secrets..."
echo "AWS_ACCESS_KEY_ID=AKIA1234567890ABCDEF" > traditional_secrets.txt
git add traditional_secrets.txt
if git commit -m "Test commit with traditional secret" > /dev/null 2>&1; then
    echo "❌ Traditional secret detection test failed - secret was committed!"
    exit 1
else
    echo "✅ Traditional secret detection test passed - commit was blocked."
fi

# Test with AI credentials
echo "Testing with AI credentials..."

# Test OpenAI API key
echo "Testing OpenAI API key..."
echo "OPENAI_API_KEY=sk-1234567890abcdef1234567890abcdef1234567890abcdef" > ai_secrets.txt
git add ai_secrets.txt
if git commit -m "Test commit with OpenAI API key" > /dev/null 2>&1; then
    echo "❌ OpenAI API key detection test failed - secret was committed!"
    exit 1
else
    echo "✅ OpenAI API key detection test passed - commit was blocked."
fi

# Test Anthropic API key
echo "Testing Anthropic API key..."
echo "ANTHROPIC_API_KEY=sk-ant-1234567890abcdef1234567890abcdef1234567890abcdef" > anthropic_secret.txt
git add anthropic_secret.txt
if git commit -m "Test commit with Anthropic API key" > /dev/null 2>&1; then
    echo "❌ Anthropic API key detection test failed - secret was committed!"
    exit 1
else
    echo "✅ Anthropic API key detection test passed - commit was blocked."
fi

# Test Hugging Face token
echo "Testing Hugging Face token..."
echo "HUGGINGFACE_TOKEN=hf_1234567890abcdef1234567890abcdef123456789" > hf_secret.txt
git add hf_secret.txt
if git commit -m "Test commit with Hugging Face token" > /dev/null 2>&1; then
    echo "❌ Hugging Face token detection test failed - secret was committed!"
    exit 1
else
    echo "✅ Hugging Face token detection test passed - commit was blocked."
fi

# Test Google AI API key
echo "Testing Google AI API key..."
echo "GOOGLE_AI_API_KEY=AIza1234567890abcdef1234567890abcdef123456789" > google_ai_secret.txt
git add google_ai_secret.txt
if git commit -m "Test commit with Google AI API key" > /dev/null 2>&1; then
    echo "❌ Google AI API key detection test failed - secret was committed!"
    exit 1
else
    echo "✅ Google AI API key detection test passed - commit was blocked."
fi

# Test ML framework credentials
echo "Testing ML framework credentials..."

# Test Weights & Biases API key
echo "Testing Weights & Biases API key..."
echo "WANDB_API_KEY=1234567890abcdef1234567890abcdef123456789" > wandb_secret.txt
git add wandb_secret.txt
if git commit -m "Test commit with W&B API key" > /dev/null 2>&1; then
    echo "❌ W&B API key detection test failed - secret was committed!"
    exit 1
else
    echo "✅ W&B API key detection test passed - commit was blocked."
fi

# Test vector database credentials
echo "Testing vector database credentials..."

# Test Pinecone API key
echo "Testing Pinecone API key..."
echo "PINECONE_API_KEY=1234567890abcdef1234567890abcdef123456789" > pinecone_secret.txt
git add pinecone_secret.txt
if git commit -m "Test commit with Pinecone API key" > /dev/null 2>&1; then
    echo "❌ Pinecone API key detection test failed - secret was committed!"
    exit 1
else
    echo "✅ Pinecone API key detection test passed - commit was blocked."
fi

# Test web framework secrets
echo "Testing web framework secrets..."

# Test Flask secret key
echo "Testing Flask secret key..."
echo "FLASK_SECRET_KEY=1234567890abcdef1234567890abcdef123456789" > flask_secret.txt
git add flask_secret.txt
if git commit -m "Test commit with Flask secret key" > /dev/null 2>&1; then
    echo "❌ Flask secret key detection test failed - secret was committed!"
    exit 1
else
    echo "✅ Flask secret key detection test passed - commit was blocked."
fi

# Test with Python file containing AI credentials
echo "Testing Python file with AI credentials..."
cat > ai_config.py << 'EOF'
# AI Configuration
import os

# These should be blocked
OPENAI_API_KEY = "sk-1234567890abcdef1234567890abcdef1234567890abcdef"
ANTHROPIC_API_KEY = "sk-ant-1234567890abcdef1234567890abcdef1234567890abcdef"
HUGGINGFACE_TOKEN = "hf_1234567890abcdef1234567890abcdef123456789"

# This should be allowed
DATABASE_URL = "postgresql://user:password@localhost:5432/db"
EOF

git add ai_config.py
if git commit -m "Test commit with Python AI config" > /dev/null 2>&1; then
    echo "❌ Python AI config detection test failed - secrets were committed!"
    exit 1
else
    echo "✅ Python AI config detection test passed - commit was blocked."
fi

# Test with JSON file containing AI credentials
echo "Testing JSON file with AI credentials..."
cat > config.json << 'EOF'
{
  "openai_api_key": "sk-1234567890abcdef1234567890abcdef1234567890abcdef",
  "anthropic_api_key": "sk-ant-1234567890abcdef1234567890abcdef1234567890abcdef",
  "database_url": "postgresql://user:password@localhost:5432/db"
}
EOF

git add config.json
if git commit -m "Test commit with JSON AI config" > /dev/null 2>&1; then
    echo "❌ JSON AI config detection test failed - secrets were committed!"
    exit 1
else
    echo "✅ JSON AI config detection test passed - commit was blocked."
fi

# Test with environment file
echo "Testing .env file with AI credentials..."
cat > .env << 'EOF'
# AI Service Credentials
OPENAI_API_KEY=sk-1234567890abcdef1234567890abcdef1234567890abcdef
ANTHROPIC_API_KEY=sk-ant-1234567890abcdef1234567890abcdef1234567890abcdef
HUGGINGFACE_TOKEN=hf_1234567890abcdef1234567890abcdef123456789

# Database
DATABASE_URL=postgresql://user:password@localhost:5432/db
EOF

git add .env
if git commit -m "Test commit with .env file" > /dev/null 2>&1; then
    echo "❌ .env file detection test failed - secrets were committed!"
    exit 1
else
    echo "✅ .env file detection test passed - commit was blocked."
fi

# Clean up
cd /
rm -rf "$TEST_DIR"

echo ""
echo "🎉 All tests passed! git-shield is working correctly."
echo ""
echo "💡 You can now use git-shield in your repositories."
echo "   The hook will automatically be applied to new repositories."
echo "   For existing repositories, run 'git init' to apply the hook."
echo ""
echo "🔒 AI credential protection is active and working!" 