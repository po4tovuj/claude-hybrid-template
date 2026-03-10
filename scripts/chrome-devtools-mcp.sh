#!/bin/bash
# Auto-detect WebStorm's Chrome debugging port and launch MCP server

# Auto-detect the active WebStorm debug session by finding the most recently
# modified DevToolsActivePort file (works with any WebStorm version)
JETBRAINS_DIR="$HOME/Library/Application Support/JetBrains"
DEVTOOLS_PORT_FILE=$(find "$JETBRAINS_DIR" -name "DevToolsActivePort" -path "*/WebStorm*/chrome-user-data/*" 2>/dev/null -exec ls -t {} + 2>/dev/null | head -1)

# When Chrome starts with --remote-debugging-port=0, it writes the actual port
# to DevToolsActivePort file (first line is port, second line is websocket path)
if [ -n "$DEVTOOLS_PORT_FILE" ] && [ -f "$DEVTOOLS_PORT_FILE" ]; then
  PORT=$(head -1 "$DEVTOOLS_PORT_FILE")
else
  # Fallback: try to parse from command line (won't work if port=0)
  PORT=$(ps aux | grep -i "chrome" | grep "JetBrains" | grep -o "remote-debugging-port=[0-9]*" | tail -1 | cut -d= -f2)
fi

if [ -z "$PORT" ] || [ "$PORT" = "0" ]; then
  echo "Error: Could not find WebStorm's Chrome debugging port." >&2
  echo "Make sure WebStorm JS debugger is running." >&2
  exit 1
fi

echo "Detected WebStorm Chrome debugging port: $PORT" >&2

# Launch the MCP server with the detected port
exec npx -y --registry https://registry.npmjs.org chrome-devtools-mcp@latest --browserUrl "http://127.0.0.1:$PORT"