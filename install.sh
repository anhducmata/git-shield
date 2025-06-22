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

git config --global init.templateDir "$TEMPLATE_DIR"

echo "✅ git-shield installed. All new repos will use this hook."

# Only prompt if running interactively and ~/projects exists
if [ -t 0 ] && [ -d "$HOME/projects" ]; then
    read -p "Do you want to apply the hook to existing repos in ~/projects? (y/n): " yn
    if [[ "$yn" =~ ^[Yy]$ ]]; then
        find "$HOME/projects" -name ".git" -type d | while read d; do
            (cd "$(dirname "$d")" && git init)
        done
        echo "✅ Applied git-shield to existing repositories in ~/projects"
    fi
elif [ -d "$HOME/projects" ]; then
    echo "💡 To apply git-shield to existing repos in ~/projects, run:"
    echo "   find ~/projects -name '.git' -type d | while read d; do (cd \"\$(dirname \"\$d\")\" && git init); done"
fi
