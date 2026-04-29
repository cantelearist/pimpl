#!/bin/bash
set -e

REPO_NAME="pimpl"
GITHUB_URL="https://github.com/cantelearist/pimpl.git"
REPO_PATH="/var/git/${REPO_NAME}.git"

echo "🚀 Starting git mirror server..."
echo "Repository: $REPO_NAME"
echo "GitHub URL: $GITHUB_URL"
echo "Local path: $REPO_PATH"

# Initialize mirror repository if it doesn't exist
if [ ! -d "$REPO_PATH" ]; then
    echo "📦 Creating mirror repository from GitHub..."
    git clone --mirror "$GITHUB_URL" "$REPO_PATH"
    echo "✅ Mirror created successfully"
else
    echo "📁 Mirror repository already exists"
fi

# Enable HTTP serving
cd "$REPO_PATH"
git config http.receivepack true

# Function to sync from GitHub
sync_from_github() {
    echo "🔄 Syncing from GitHub at $(date)..."
    cd "$REPO_PATH"
    git fetch -q --all
    echo "✅ Sync complete"
}

# Initial sync
sync_from_github

# Setup periodic sync (every 5 minutes)
(
    while true; do
        sleep 300
        sync_from_github 2>&1 || echo "⚠️  Sync failed at $(date)"
    done
) &

# Start Python HTTP server with git HTTP backend support
echo "🌐 Starting HTTP server on port 8080..."

python3 << 'PYTHON_EOF'
#!/usr/bin/env python3
import http.server
import socketserver
import subprocess
import os
import sys

GIT_PROJECT_ROOT = '/var/git'
REPO_PATH = os.path.join(GIT_PROJECT_ROOT, 'pimpl.git')

class GitHTTPHandler(http.server.BaseHTTPRequestHandler):
    def log_message(self, format, *args):
        print(f"[{self.client_address[0]}] {format % args}", file=sys.stderr)

    def do_GET(self):
        self.handle_git_request()

    def do_POST(self):
        self.handle_git_request()

    def handle_git_request(self):
        path = self.path

        # Remove leading slash
        if path.startswith('/'):
            path = path[1:]

        # Handle git/repo.git requests
        if 'pimpl.git' in path or 'git/' in path:
            try:
                # Setup environment for git http-backend
                env = os.environ.copy()
                env['GIT_PROJECT_ROOT'] = GIT_PROJECT_ROOT
                env['GIT_HTTP_EXPORT_ALL'] = '1'
                env['REQUEST_METHOD'] = self.command
                env['PATH_INFO'] = self.path.split('pimpl.git')[-1] if 'pimpl.git' in self.path else self.path
                env['QUERY_STRING'] = self.path.split('?')[1] if '?' in self.path else ''
                env['CONTENT_LENGTH'] = self.headers.get('Content-Length', '0')

                # Read request body
                content_length = int(env.get('CONTENT_LENGTH', 0))
                request_body = self.rfile.read(content_length) if content_length > 0 else b''

                # Call git http-backend
                proc = subprocess.Popen(
                    ['git', 'http-backend'],
                    cwd=REPO_PATH,
                    env=env,
                    stdin=subprocess.PIPE,
                    stdout=subprocess.PIPE,
                    stderr=subprocess.PIPE
                )

                stdout, stderr = proc.communicate(input=request_body, timeout=30)

                # Parse response
                response_lines = stdout.split(b'\r\n')
                headers_end = -1
                for i, line in enumerate(response_lines):
                    if line == b'':
                        headers_end = i
                        break

                if headers_end > 0:
                    header_lines = response_lines[:headers_end]
                    body = b'\r\n'.join(response_lines[headers_end+1:])
                else:
                    header_lines = []
                    body = stdout

                # Send response
                self.send_response(200)
                self.send_header('Content-Type', 'application/x-git-upload-pack-result')
                self.send_header('Content-Length', str(len(body)))
                self.send_header('Cache-Control', 'no-cache')
                self.end_headers()
                self.wfile.write(body)

            except subprocess.TimeoutExpired:
                self.send_response(504)
                self.send_header('Content-Type', 'text/plain')
                self.end_headers()
                self.wfile.write(b'Gateway Timeout')
            except Exception as e:
                print(f"Error: {e}", file=sys.stderr)
                self.send_response(500)
                self.send_header('Content-Type', 'text/plain')
                self.end_headers()
                self.wfile.write(f"Internal Server Error: {e}".encode())
        else:
            # Info page
            self.send_response(200)
            self.send_header('Content-Type', 'text/html; charset=utf-8')
            self.end_headers()
            html = b'''<!DOCTYPE html>
<html>
<head><title>Git Mirror Server</title></head>
<body style="font-family: monospace; margin: 20px;">
    <h1>Git Mirror Server</h1>
    <p><strong>Status:</strong> ✅ Running</p>
    <p><strong>GitHub Repository:</strong> https://github.com/cantelearist/pimpl.git</p>
    <p><strong>Clone URL:</strong> <code>http://127.0.0.1:45139/git/pimpl.git</code></p>
    <p><strong>Auto-sync:</strong> Every 5 minutes</p>
</body>
</html>'''
            self.wfile.write(html)

PORT = 8080
print(f"Starting Git Mirror HTTP Server on port {PORT}")
with socketserver.TCPServer(("0.0.0.0", PORT), GitHTTPHandler) as httpd:
    print(f"✅ Server ready for connections")
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        print("\n🛑 Server stopped")
PYTHON_EOF

echo "Server exited"
