#!/usr/bin/env python3
"""Run one local Flutter session without touching other applications."""
import json
import os
from pathlib import Path
import signal
import subprocess
import sys
from urllib.parse import urlparse

ROOT = Path(__file__).resolve().parent.parent
PIDFILE = ROOT / '.dart_tool' / 'package-game-dev.pid'


def running_pid():
    try:
        pid = int(PIDFILE.read_text().strip())
        command = subprocess.run(['ps', '-p', str(pid), '-o', 'command='], capture_output=True, text=True).stdout
        return pid if 'tools/dev.py start' in command else None
    except (OSError, ValueError):
        return None


def stop():
    pid = running_pid()
    if pid is None:
        print('Нет запущенной через make dev сессии клиента.')
        return
    os.kill(pid, signal.SIGTERM)
    print('Сессия клиента останавливается.')


def start():
    if running_pid():
        sys.exit('Клиент уже запущен через make dev; сначала выполните make stop.')
    result = subprocess.run(['flutter', 'devices', '--machine'], cwd=ROOT, check=True, capture_output=True, text=True)
    devices = [d for d in json.loads(result.stdout) if d.get('targetPlatform', '').startswith(('android', 'ios')) and d.get('isSupported', False)]
    requested = os.environ.get('DEVICE', '')
    if requested:
        devices = [d for d in devices if d['id'] == requested]
    if len(devices) != 1:
        print('Выберите устройство: make dev DEVICE=<id>')
        for device in devices:
            print(f"  {device['id']} — {device['name']} ({device['targetPlatform']})")
        sys.exit(1)
    device = devices[0]
    url = os.environ.get('SERVER_URL', '')
    platform = device['targetPlatform']
    if platform.startswith('android'):
        for port in (3005, 3006):
            subprocess.run(['adb', '-s', device['id'], 'reverse', f'tcp:{port}', f'tcp:{port}'], check=True)
    elif not device.get('emulator', False) and not url:
        sys.exit('Для iPhone укажите адрес Mac: make dev DEVICE=<id> SERVER_URL=http://<ip-mac>:3005/')
    if url and (urlparse(url).scheme not in ('http', 'https') or not urlparse(url).hostname):
        sys.exit('SERVER_URL должен быть полным адресом http:// или https://.')
    if platform.startswith('ios') and not device.get('emulator', False) and urlparse(url).hostname in ('localhost', '127.0.0.1', '::1'):
        sys.exit('localhost на iPhone указывает на сам телефон; укажите сетевой адрес Mac.')
    command = ['flutter', 'run', '-d', device['id'], '--android-skip-build-dependency-validation']
    if url:
        command.append(f'--dart-define=SERVER_URL={url}')
    PIDFILE.parent.mkdir(parents=True, exist_ok=True)
    PIDFILE.write_text(str(os.getpid()))
    child = None
    def terminate(_signum, _frame):
        if child and child.poll() is None:
            child.terminate()
    signal.signal(signal.SIGTERM, terminate)
    try:
        child = subprocess.Popen(command, cwd=ROOT)
        return child.wait()
    finally:
        PIDFILE.unlink(missing_ok=True)


if __name__ == '__main__':
    if sys.argv[1:] == ['start']:
        sys.exit(start())
    if sys.argv[1:] == ['stop']:
        stop()
    else:
        sys.exit('Используйте make dev или make stop.')
