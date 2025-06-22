#!/bin/bash

echo "🧹 Uninstalling git-shield..."

git config --global --unset init.templateDir
rm -rf "$HOME/.git-shield-template"

echo "✅ git-shield removed. Global hooks are no longer active."
