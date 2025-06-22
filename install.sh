#!/bin/bash

# Parse command line arguments
FUTURE_ONLY=false
while [[ $# -gt 0 ]]; do
    case $1 in
        --future-only)
            FUTURE_ONLY=true
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --future-only   Install git-shield for new repositories only (skip existing repos)"
            echo "  -h, --help      Show this help message"
            echo ""
            echo "Examples:"
            echo "  $0                    # Install and protect existing repositories"
            echo "  $0 --future-only     # Install for future repositories only"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

echo "📦 Installing git-shield global pre-commit hook..."

TEMPLATE_DIR="$HOME/.git-shield-template"
mkdir -p "$TEMPLATE_DIR/hooks"

# Check if we're running from a cloned repo or via curl | bash
if [ -f "hooks/pre-commit" ]; then
    # Running from cloned repository
    # Ensure Unix line endings for macOS/Linux compatibility
    if command -v dos2unix >/dev/null 2>&1; then
        # Use dos2unix if available
        dos2unix -n "hooks/pre-commit" "$TEMPLATE_DIR/hooks/pre-commit"
    elif command -v tr >/dev/null 2>&1; then
        # Use tr to convert CRLF to LF
        tr -d '\r' < "hooks/pre-commit" > "$TEMPLATE_DIR/hooks/pre-commit"
    else
        # Fallback: use sed to remove carriage returns
        sed 's/\r$//' "hooks/pre-commit" > "$TEMPLATE_DIR/hooks/pre-commit"
    fi
else
    # Running via curl | bash - download from GitHub
    echo "Downloading pre-commit hook from GitHub..."
    if command -v curl >/dev/null 2>&1; then
        curl -sSL https://raw.githubusercontent.com/anhducmata/git-shield/main/hooks/pre-commit | tr -d '\r' > "$TEMPLATE_DIR/hooks/pre-commit"
    elif command -v wget >/dev/null 2>&1; then
        wget -q https://raw.githubusercontent.com/anhducmata/git-shield/main/hooks/pre-commit -O - | tr -d '\r' > "$TEMPLATE_DIR/hooks/pre-commit"
    else
        echo "❌ Error: Neither curl nor wget is available. Please install one of them or clone the repository manually."
        exit 1
    fi
fi

chmod +x "$TEMPLATE_DIR/hooks/pre-commit"

# Verify the hook file is properly formatted for Unix systems
if [ "$(uname)" = "Darwin" ] || [ "$(uname)" = "Linux" ]; then
    # Check if file has proper Unix line endings
    if command -v file >/dev/null 2>&1; then
        FILE_TYPE=$(file "$TEMPLATE_DIR/hooks/pre-commit")
        if echo "$FILE_TYPE" | grep -q "CRLF"; then
            echo "⚠️  Converting Windows line endings to Unix format..."
            if command -v dos2unix >/dev/null 2>&1; then
                dos2unix "$TEMPLATE_DIR/hooks/pre-commit"
            else
                # Fallback: use sed or tr
                if command -v tr >/dev/null 2>&1; then
                    tr -d '\r' < "$TEMPLATE_DIR/hooks/pre-commit" > "$TEMPLATE_DIR/hooks/pre-commit.tmp"
                    mv "$TEMPLATE_DIR/hooks/pre-commit.tmp" "$TEMPLATE_DIR/hooks/pre-commit"
                else
                    sed -i 's/\r$//' "$TEMPLATE_DIR/hooks/pre-commit"
                fi
                chmod +x "$TEMPLATE_DIR/hooks/pre-commit"
            fi
        fi
    fi
    
    # Verify the shebang is correct
    FIRST_LINE=$(head -n1 "$TEMPLATE_DIR/hooks/pre-commit")
    if [[ "$FIRST_LINE" != "#!/bin/bash" ]]; then
        echo "⚠️  Fixing shebang line for Unix compatibility..."
        # Create a temporary file with correct shebang
        {
            echo "#!/bin/bash"
            tail -n +2 "$TEMPLATE_DIR/hooks/pre-commit"
        } > "$TEMPLATE_DIR/hooks/pre-commit.tmp"
        mv "$TEMPLATE_DIR/hooks/pre-commit.tmp" "$TEMPLATE_DIR/hooks/pre-commit"
        chmod +x "$TEMPLATE_DIR/hooks/pre-commit"
    fi
fi

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
printf "OPENAI_API_KEY=test-key-1234567890abcdef1234567890abcdef1234567890abcdef\n" > secret_test.txt
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

# Skip existing repository protection if --future-only flag is used
if [ "$FUTURE_ONLY" = true ]; then
    echo ""
    echo "🎉 git-shield is ready to protect your repositories!"
    echo ""
    echo "💡 git-shield will automatically protect all new repositories you create."
    echo "💡 To protect existing repositories later, run:"
    echo "   curl -sSL https://raw.githubusercontent.com/anhducmata/git-shield/main/protect-existing-repos.sh | bash"
    echo "💡 To test protection, try committing a file with: OPENAI_API_KEY=test-key123..."
    exit 0
fi

# Auto-discover and protect existing repositories
echo "🔍 Scanning for existing Git repositories..."

# Common directories where Git repos are typically stored
SEARCH_DIRS=(
    "$HOME"
    "$HOME/projects"
    "$HOME/Projects"
    "$HOME/code"
    "$HOME/Code"
    "$HOME/dev"
    "$HOME/Development"
    "$HOME/repos"
    "$HOME/git"
    "$HOME/workspace"
    "$HOME/Documents"
    "$HOME/Desktop"
)

repos_found=0
repos_protected=0

# Function to apply git-shield to a repository
apply_git_shield() {
    local repo_path="$1"
    echo "  🛡️  Protecting: $repo_path"
    (cd "$repo_path" && git init > /dev/null 2>&1)
    if [ -f "$repo_path/.git/hooks/pre-commit" ]; then
        repos_protected=$((repos_protected + 1))
        return 0
    else
        return 1
    fi
}

# Search for Git repositories (limit depth to avoid going too deep)
for search_dir in "${SEARCH_DIRS[@]}"; do
    if [ -d "$search_dir" ]; then
        echo "Scanning $search_dir..."
        
        # Find .git directories (max depth 3 to avoid performance issues)
        while IFS= read -r -d '' git_dir; do
            repo_dir=$(dirname "$git_dir")
            
            # Skip if it's the git-shield template directory
            if [[ "$repo_dir" == *".git-shield-template"* ]]; then
                continue
            fi
            
            # Skip if it's a bare repository
            if [[ "$git_dir" == *".git" ]] && [ -f "$git_dir/HEAD" ] && [ -d "$git_dir/objects" ]; then
                repos_found=$((repos_found + 1))
                
                # Check if it already has the git-shield hook
                if [ ! -f "$repo_dir/.git/hooks/pre-commit" ] || ! grep -q "git-shield" "$repo_dir/.git/hooks/pre-commit" 2>/dev/null; then
                    apply_git_shield "$repo_dir"
                else
                    echo "  ✅ Already protected: $repo_dir"
                    repos_protected=$((repos_protected + 1))
                fi
            fi
        done < <(find "$search_dir" -maxdepth 3 -name ".git" -type d -print0 2>/dev/null)
    fi
done

echo ""
if [ "$repos_found" -gt 0 ]; then
    echo "📊 Repository scan results:"
    echo "   Found: $repos_found repositories"
    echo "   Protected: $repos_protected repositories"
    
    if [ "$repos_protected" -eq "$repos_found" ]; then
        echo "✅ All existing repositories are now protected by git-shield!"
    else
        echo "⚠️  Some repositories could not be automatically protected."
        echo "   You can manually protect them by running 'git init' in each repository."
    fi
else
    echo "ℹ️  No existing Git repositories found in common locations."
fi

# Interactive option for custom directories
if [ -t 0 ]; then
    echo ""
    read -p "Do you have repositories in other directories you'd like to protect? (y/n): " custom_scan
    if [[ "$custom_scan" =~ ^[Yy]$ ]]; then
        read -p "Enter the directory path to scan: " custom_dir
        if [ -d "$custom_dir" ]; then
            echo "Scanning $custom_dir..."
            while IFS= read -r -d '' git_dir; do
                repo_dir=$(dirname "$git_dir")
                if [[ "$git_dir" == *".git" ]] && [ -f "$git_dir/HEAD" ] && [ -d "$git_dir/objects" ]; then
                    if [ ! -f "$repo_dir/.git/hooks/pre-commit" ] || ! grep -q "git-shield" "$repo_dir/.git/hooks/pre-commit" 2>/dev/null; then
                        apply_git_shield "$repo_dir"
                    else
                        echo "  ✅ Already protected: $repo_dir"
                    fi
                fi
            done < <(find "$custom_dir" -name ".git" -type d -print0 2>/dev/null)
        else
            echo "❌ Directory not found: $custom_dir"
        fi
    fi
fi

echo ""
echo "🎉 git-shield is ready to protect your repositories!"
echo ""
echo "💡 For any new repositories you create, git-shield will be applied automatically."
echo "💡 To manually protect a specific repository, run 'git init' in that directory."
echo "💡 To test protection, try committing a file with: OPENAI_API_KEY=test-key123..."
