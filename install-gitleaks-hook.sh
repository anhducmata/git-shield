#!/bin/bash

set -e

echo "🔧 Starting installation of global Gitleaks pre-commit hook..."

# === 1. Check and install Gitleaks ===
if ! command -v gitleaks &> /dev/null; then
  echo "📦 Gitleaks not found. Installing via Homebrew..."

  if ! command -v brew &> /dev/null; then
    echo "❌ Homebrew is not installed. Please install it from https://brew.sh/ and try again."
    exit 1
  fi

  brew install gitleaks
  echo "✅ Gitleaks installed successfully."
else
  echo "✅ Gitleaks already installed."
fi

# === 2. Create global git hook template ===
HOOK_DIR="$HOME/.git-templates/hooks"
mkdir -p "$HOOK_DIR"

cat << 'EOF' > "$HOOK_DIR/pre-commit"
#!/bin/sh
echo "🔒 Running Gitleaks secret scan..."
gitleaks detect --source . --no-git -v
if [ $? -ne 0 ]; then
  echo "🚫 Gitleaks detected potential secrets! Commit aborted."
  exit 1
fi
EOF

chmod +x "$HOOK_DIR/pre-commit"

# === 3. Apply template globally ===
git config --global init.templateDir "$HOME/.git-templates"

echo ""
echo "✅ Global Gitleaks pre-commit hook installed!"
echo "📁 All new git repositories will now use this hook."
echo "💡 To apply it to an existing repo, run:"
echo "   cd /your/repo && git init"
