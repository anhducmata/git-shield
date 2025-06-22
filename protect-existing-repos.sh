#!/bin/bash

# git-shield: Protect existing repositories script
# This script finds and protects existing Git repositories with git-shield

echo "🔍 git-shield: Protecting existing Git repositories..."

# Check if git-shield is installed
TEMPLATE_DIR="$HOME/.git-shield-template"
if [ ! -f "$TEMPLATE_DIR/hooks/pre-commit" ]; then
    echo "❌ git-shield is not installed. Please run the install script first:"
    echo "   curl -sSL https://raw.githubusercontent.com/anhducmata/git-shield/main/install.sh | bash"
    exit 1
fi

# Function to apply git-shield to a repository
apply_git_shield() {
    local repo_path="$1"
    echo "  🛡️  Protecting: $repo_path"
    
    # Check if already protected
    if [ -f "$repo_path/.git/hooks/pre-commit" ] && grep -q "git-shield" "$repo_path/.git/hooks/pre-commit" 2>/dev/null; then
        echo "  ✅ Already protected: $repo_path"
        return 0
    fi
    
    # Apply git-shield
    (cd "$repo_path" && git init > /dev/null 2>&1)
    
    if [ -f "$repo_path/.git/hooks/pre-commit" ] && grep -q "git-shield" "$repo_path/.git/hooks/pre-commit" 2>/dev/null; then
        echo "  ✅ Successfully protected: $repo_path"
        return 0
    else
        echo "  ❌ Failed to protect: $repo_path"
        return 1
    fi
}

# Parse command line arguments
SCAN_DIRS=()
RECURSIVE=false
MAX_DEPTH=3

while [[ $# -gt 0 ]]; do
    case $1 in
        -r|--recursive)
            RECURSIVE=true
            shift
            ;;
        -d|--depth)
            MAX_DEPTH="$2"
            shift 2
            ;;
        -h|--help)
            echo "Usage: $0 [OPTIONS] [DIRECTORIES...]"
            echo ""
            echo "Options:"
            echo "  -r, --recursive     Scan recursively (default: limited depth)"
            echo "  -d, --depth NUM     Maximum depth for scanning (default: 3)"
            echo "  -h, --help          Show this help message"
            echo ""
            echo "Examples:"
            echo "  $0                          # Scan common directories"
            echo "  $0 ~/projects ~/code        # Scan specific directories"
            echo "  $0 -r ~/projects            # Scan recursively"
            echo "  $0 -d 5 ~/projects          # Scan with depth 5"
            exit 0
            ;;
        *)
            SCAN_DIRS+=("$1")
            shift
            ;;
    esac
done

# If no directories specified, use common ones
if [ ${#SCAN_DIRS[@]} -eq 0 ]; then
    SCAN_DIRS=(
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
    echo "No directories specified. Scanning common locations..."
else
    echo "Scanning specified directories..."
fi

repos_found=0
repos_protected=0
repos_failed=0

# Search for Git repositories
for search_dir in "${SCAN_DIRS[@]}"; do
    if [ -d "$search_dir" ]; then
        echo "📁 Scanning: $search_dir"
        
        # Build find command based on options
        if [ "$RECURSIVE" = true ]; then
            find_cmd="find \"$search_dir\" -name \".git\" -type d -print0 2>/dev/null"
        else
            find_cmd="find \"$search_dir\" -maxdepth $MAX_DEPTH -name \".git\" -type d -print0 2>/dev/null"
        fi
        
        # Find .git directories
        while IFS= read -r -d '' git_dir; do
            repo_dir=$(dirname "$git_dir")
            
            # Skip if it's the git-shield template directory
            if [[ "$repo_dir" == *".git-shield-template"* ]]; then
                continue
            fi
            
            # Validate it's a proper Git repository
            if [ -f "$git_dir/HEAD" ] && [ -d "$git_dir/objects" ]; then
                repos_found=$((repos_found + 1))
                
                if apply_git_shield "$repo_dir"; then
                    repos_protected=$((repos_protected + 1))
                else
                    repos_failed=$((repos_failed + 1))
                fi
            fi
        done < <(eval "$find_cmd")
    else
        echo "⚠️  Directory not found: $search_dir"
    fi
done

# Summary
echo ""
echo "📊 Protection Results:"
echo "   🔍 Repositories found: $repos_found"
echo "   🛡️  Successfully protected: $repos_protected"
if [ "$repos_failed" -gt 0 ]; then
    echo "   ❌ Failed to protect: $repos_failed"
fi

if [ "$repos_found" -eq 0 ]; then
    echo "ℹ️  No Git repositories found in the specified directories."
    echo ""
    echo "💡 Tips:"
    echo "   - Try specifying different directories: $0 /path/to/your/repos"
    echo "   - Use recursive search: $0 -r /path/to/search"
    echo "   - Check if your repositories are in uncommon locations"
elif [ "$repos_protected" -eq "$repos_found" ]; then
    echo "✅ All repositories are now protected by git-shield!"
else
    echo "⚠️  Some repositories could not be protected automatically."
    echo "💡 You can manually protect them by running 'git init' in each repository."
fi

echo ""
echo "🎉 git-shield protection scan complete!"
echo "💡 To test protection, try committing a file with secrets in any protected repository." 