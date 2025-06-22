#!/bin/bash

# git-shield: macOS Line Endings Fix Script
# This script fixes line ending issues with git-shield pre-commit hooks on macOS

echo "🍎 git-shield: Fixing macOS line endings..."

TEMPLATE_DIR="$HOME/.git-shield-template"
PRECOMMIT_HOOK="$TEMPLATE_DIR/hooks/pre-commit"

# Check if git-shield is installed
if [ ! -f "$PRECOMMIT_HOOK" ]; then
    echo "❌ git-shield pre-commit hook not found at: $PRECOMMIT_HOOK"
    echo "Please run the install script first:"
    echo "   curl -sSL https://raw.githubusercontent.com/anhducmata/git-shield/main/install.sh | bash"
    exit 1
fi

# Check if we're on macOS
if [ "$(uname)" != "Darwin" ]; then
    echo "ℹ️  This script is designed for macOS. Current system: $(uname)"
    echo "Line ending issues are primarily a concern on macOS."
fi

echo "🔍 Checking current pre-commit hook..."

# Check file type and line endings
if command -v file >/dev/null 2>&1; then
    FILE_TYPE=$(file "$PRECOMMIT_HOOK")
    echo "Current file type: $FILE_TYPE"
    
    if echo "$FILE_TYPE" | grep -q "CRLF"; then
        echo "⚠️  Found Windows line endings (CRLF) - fixing..."
        NEEDS_FIX=true
    elif echo "$FILE_TYPE" | grep -q "text"; then
        echo "✅ File appears to have correct text format"
        NEEDS_FIX=false
    else
        echo "⚠️  Unusual file format detected - attempting to fix..."
        NEEDS_FIX=true
    fi
else
    echo "⚠️  'file' command not available - will attempt to fix anyway"
    NEEDS_FIX=true
fi

# Check shebang
FIRST_LINE=$(head -n1 "$PRECOMMIT_HOOK" 2>/dev/null)
if [[ "$FIRST_LINE" != "#!/bin/bash" ]]; then
    echo "⚠️  Incorrect or missing shebang: '$FIRST_LINE'"
    NEEDS_FIX=true
fi

if [ "$NEEDS_FIX" = true ]; then
    echo "🔧 Fixing pre-commit hook..."
    
    # Create backup
    cp "$PRECOMMIT_HOOK" "$PRECOMMIT_HOOK.backup.$(date +%s)"
    echo "📁 Backup created: $PRECOMMIT_HOOK.backup.$(date +%s)"
    
    # Fix line endings and ensure proper format
    if command -v dos2unix >/dev/null 2>&1; then
        echo "Using dos2unix to fix line endings..."
        dos2unix "$PRECOMMIT_HOOK"
    else
        echo "Using tr to fix line endings..."
        tr -d '\r' < "$PRECOMMIT_HOOK" > "$PRECOMMIT_HOOK.tmp"
        mv "$PRECOMMIT_HOOK.tmp" "$PRECOMMIT_HOOK"
    fi
    
    # Ensure proper shebang
    FIRST_LINE=$(head -n1 "$PRECOMMIT_HOOK")
    if [[ "$FIRST_LINE" != "#!/bin/bash" ]]; then
        echo "Fixing shebang..."
        {
            echo "#!/bin/bash"
            tail -n +2 "$PRECOMMIT_HOOK"
        } > "$PRECOMMIT_HOOK.tmp"
        mv "$PRECOMMIT_HOOK.tmp" "$PRECOMMIT_HOOK"
    fi
    
    # Set executable permissions
    chmod +x "$PRECOMMIT_HOOK"
    
    echo "✅ Pre-commit hook fixed!"
else
    echo "✅ Pre-commit hook appears to be in correct format already."
fi

# Verify the fix
echo ""
echo "🧪 Verifying fix..."

if [ -x "$PRECOMMIT_HOOK" ]; then
    echo "✅ Hook is executable"
else
    echo "❌ Hook is not executable"
    chmod +x "$PRECOMMIT_HOOK"
    echo "✅ Fixed executable permissions"
fi

FIRST_LINE=$(head -n1 "$PRECOMMIT_HOOK")
if [[ "$FIRST_LINE" == "#!/bin/bash" ]]; then
    echo "✅ Correct shebang: $FIRST_LINE"
else
    echo "❌ Incorrect shebang: $FIRST_LINE"
fi

if command -v file >/dev/null 2>&1; then
    FILE_TYPE=$(file "$PRECOMMIT_HOOK")
    if echo "$FILE_TYPE" | grep -q -v "CRLF"; then
        echo "✅ Correct line endings (Unix format)"
    else
        echo "❌ Still has Windows line endings"
    fi
fi

# Test with a simple syntax check
if bash -n "$PRECOMMIT_HOOK" 2>/dev/null; then
    echo "✅ Script syntax is valid"
else
    echo "❌ Script syntax error detected"
    echo "Please check the hook manually: $PRECOMMIT_HOOK"
fi

echo ""
echo "🎉 macOS line ending fix complete!"
echo ""
echo "💡 If you're still experiencing issues:"
echo "   1. Try reinstalling git-shield: curl -sSL https://raw.githubusercontent.com/anhducmata/git-shield/main/install.sh | bash"
echo "   2. Check if your terminal/editor is configured for Unix line endings"
echo "   3. Report the issue at: https://github.com/anhducmata/git-shield/issues" 