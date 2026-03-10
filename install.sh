#!/bin/bash
# Install Claude Hybrid Template into a target project directory

TEMPLATE_DIR="$(cd "$(dirname "$0")" && pwd)"
TARGET_DIR="${1:-.}"

if [ "$TARGET_DIR" = "." ]; then
  echo "Usage: install.sh <target-project-directory>"
  echo "Example: ./install.sh ~/Projects/my-new-app"
  exit 1
fi

if [ ! -d "$TARGET_DIR" ]; then
  echo "Directory '$TARGET_DIR' does not exist. Create it first."
  exit 1
fi

echo "Installing Claude Hybrid Template into: $TARGET_DIR"

cp -r "$TEMPLATE_DIR/.claude" "$TARGET_DIR/"
cp -r "$TEMPLATE_DIR/specs" "$TARGET_DIR/"
cp -r "$TEMPLATE_DIR/scripts" "$TARGET_DIR/"
cp "$TEMPLATE_DIR/.mcp.json" "$TARGET_DIR/"

echo "Done. Open the project in Claude Code and run /setup-wizard"