#!/usr/bin/env python3
"""Local-only web server for STALKER PDA manual browser mode."""
from http.server import ThreadingHTTPServer, SimpleHTTPRequestHandler
from pathlib import Path
import argparse
import os

class Handler(SimpleHTTPRequestHandler):
    def end_headers(self):
        self.send_header('Cache-Control', 'no-cache, no-store, must-revalidate')
        self.send_header('Pragma', 'no-cache')
        self.send_header('Expires', '0')
        self.send_header('X-Content-Type-Options', 'nosniff')
        self.send_header('Referrer-Policy', 'no-referrer')
        super().end_headers()

    def log_message(self, fmt, *args):
        print('[PDA]', fmt % args)


def main():
    parser = argparse.ArgumentParser(description='Локальный сервер КПК Зоны')
    parser.add_argument('--port', type=int, default=8080)
    args = parser.parse_args()
    if not 1024 <= args.port <= 65535:
        raise SystemExit('Порт должен быть в диапазоне 1024–65535')
    os.chdir(Path(__file__).resolve().parent)
    server = ThreadingHTTPServer(('127.0.0.1', args.port), Handler)
    print(f'КПК Зоны запущен. Откройте именно: http://localhost:{args.port}/')
    print('Остановка: Ctrl+C')
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print('\nСервер остановлен.')
    finally:
        server.server_close()

if __name__ == '__main__':
    main()
