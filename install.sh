#!/bin/bash

echo "📦 Installing git-shield global pre-commit hook..."

TEMPLATE_DIR="$HOME/.git-shield-template"
mkdir -p "$TEMPLATE_DIR/hooks"

cp hooks/pre-commit "$TEMPLATE_DIR/hooks/"
chmod +x "$TEMPLATE_DIR/hooks/pre-commit"

git config --global init.templateDir "$TEMPLATE_DIR"

echo "✅ git-shield installed. All new repos will use this hook."

read -p "Do you want to apply the hook to existing repos in ~/projects? (y/n): " yn
if [[ "$yn" =~ ^[Yy]$ ]]; then
    find ~/projects -name ".git" -type d | while read d; do
        (cd "$(dirname "$d")" && git init)
    done
fi
