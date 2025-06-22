#!/bin/bash

echo "📦 Installing git-shield global pre-commit hook..."

TEMPLATE_DIR="$HOME/.git-shield-template"
mkdir -p "$TEMPLATE_DIR/hooks"

# Check if we're running from a cloned repo or via curl | bash
if [ -f "hooks/pre-commit" ]; then
    # Running from cloned repository
    cp hooks/pre-commit "$TEMPLATE_DIR/hooks/"
else
    # Running via curl | bash - download from GitHub
    echo "Downloading pre-commit hook from GitHub..."
    if command -v curl >/dev/null 2>&1; then
        curl -sSL https://raw.githubusercontent.com/anhducmata/git-shield/main/hooks/pre-commit -o "$TEMPLATE_DIR/hooks/pre-commit"
    elif command -v wget >/dev/null 2>&1; then
        wget -q https://raw.githubusercontent.com/anhducmata/git-shield/main/hooks/pre-commit -O "$TEMPLATE_DIR/hooks/pre-commit"
    else
        echo "❌ Error: Neither curl nor wget is available. Please install one of them or clone the repository manually."
        exit 1
    fi
fi

chmod +x "$TEMPLATE_DIR/hooks/pre-commit"

# Set global git template directory
git config --global init.templateDir "$TEMPLATE_DIR"

echo "✅ git-shield installed. All new repos will use this hook."

# Verify installation by testing the hook
echo "🧪 Verifying installation..."

# Create a temporary test directory
TEST_DIR="/tmp/git-shield-verify-$$"
mkdir -p "$TEST_DIR"
cd "$TEST_DIR"

# Initialize a test repository
git init > /dev/null 2>&1

# Check if hook was applied
if [ ! -f ".git/hooks/pre-commit" ]; then
    echo "❌ Installation verification failed: Hook not applied to new repository"
    cd /
    rm -rf "$TEST_DIR"
    exit 1
fi

# Test with a clean file first
echo "Testing clean file..." > /dev/null
echo "This is a safe file with no secrets" > clean_test.txt
git add clean_test.txt
if ! git commit -m "Clean test" > /dev/null 2>&1; then
    echo "❌ Installation verification failed: Clean file was blocked"
    cd /
    rm -rf "$TEST_DIR"
    exit 1
fi

# Test secret detection with a properly formatted file (ASCII encoding)
echo "Testing secret detection..." > /dev/null
printf "OPENAI_API_KEY=sk-1234567890abcdef1234567890abcdef1234567890abcdef\n" > secret_test.txt
git add secret_test.txt

# Test if the hook blocks the secret
if git commit -m "Secret test" > /dev/null 2>&1; then
    echo "❌ Installation verification failed: Secret was not detected and blocked"
    cd /
    rm -rf "$TEST_DIR"
    exit 1
fi

# Clean up test directory
cd /
rm -rf "$TEST_DIR"

echo "✅ Installation verified! Secret detection is working correctly."

# Only prompt if running interactively and ~/projects exists
if [ -t 0 ] && [ -d "$HOME/projects" ]; then
    read -p "Do you want to apply the hook to existing repos in ~/projects? (y/n): " yn
    if [[ "$yn" =~ ^[Yy]$ ]]; then
        find "$HOME/projects" -name ".git" -type d | while read d; do
            (cd "$(dirname "$d")" && git init > /dev/null 2>&1)
        done
        echo "✅ Applied git-shield to existing repositories in ~/projects"
    fi
elif [ -d "$HOME/projects" ]; then
    echo "💡 To apply git-shield to existing repos in ~/projects, run:"
    echo "   find ~/projects -name '.git' -type d | while read d; do (cd \"\$(dirname \"\$d\")\" && git init); done"
fi

echo ""
echo "🎉 git-shield is ready to protect your repositories!"
echo ""
echo "💡 For existing repositories, run 'git init' in each repo to apply the hook."
echo "💡 To test in any repository, try committing a file with: OPENAI_API_KEY=sk-test123..."
