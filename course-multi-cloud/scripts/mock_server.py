import http.server
import socketserver
import sys

port = int(sys.argv[1]) if len(sys.argv) > 1 else 8000

class Handler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header("Content-type", "text/plain")
        self.end_headers()
        self.wfile.write(f"Mock Response from port {port}\n".encode())

with socketserver.TCPServer(("", port), Handler) as httpd:
    httpd.serve_forever()
