#!/bin/bash

PORT=8080

echo "🚀 Starting local web server on http://localhost:$PORT"
echo "📂 Serving from: $(pwd)"
echo ""
echo "Open your browser to:"
echo "  👉 http://localhost:$PORT/index.html"
echo ""
echo "Press Ctrl+C to stop"
echo ""

# Try Python 3 first, then Python 2
if command -v python3 &> /dev/null; then
    python3 -m http.server $PORT
elif command -v python &> /dev/null; then
    python -m SimpleHTTPServer $PORT
else
    echo "❌ Python not found. Please install Python or use Node.js alternative."
    exit 1
fi
