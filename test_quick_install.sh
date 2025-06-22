#!/bin/bash

# Test script for quick install verification
echo "🧪 Testing git-shield quick install..."

# Clean up any existing installation
git config --global --unset init.templateDir 2>/dev/null || true
rm -rf ~/.git-shield-template 2>/dev/null || true

# Test the quick install
echo "📦 Running quick install..."
curl -sSL https://raw.githubusercontent.com/anhducmata/git-shield/main/install.sh | bash

if [ $? -eq 0 ]; then
    echo "✅ Quick install completed successfully!"
else
    echo "❌ Quick install failed!"
    exit 1
fi

# Verify installation
echo "🔍 Verifying installation..."
TEMPLATE_DIR=$(git config --global --get init.templateDir)
if [ -z "$TEMPLATE_DIR" ]; then
    echo "❌ Global template directory not set"
    exit 1
fi

if [ ! -f "$TEMPLATE_DIR/hooks/pre-commit" ]; then
    echo "❌ Pre-commit hook not found"
    exit 1
fi

echo "✅ git-shield quick install test passed!"
echo "🎉 The quick install now works correctly in one command!" 