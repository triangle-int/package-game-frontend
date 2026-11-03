#!/usr/bin/env python3
"""Prepare Flutter dependencies and platform tooling without running the app."""

import os
from pathlib import Path
import shutil
import subprocess
import sys

ROOT = Path(__file__).resolve().parent.parent


def run(*command, cwd=ROOT, env=None):
    print('+', ' '.join(command), flush=True)
    return subprocess.run(command, cwd=cwd, env=env, check=False).returncode == 0


def main():
    platform = sys.argv[1] if len(sys.argv) == 2 else ''
    if platform not in ('all', 'android', 'ios'):
        print('Используйте make install PLATFORM=all, android или ios.', file=sys.stderr)
        return 1
    if not shutil.which('flutter'):
        print('Установите Flutter SDK и добавьте flutter в PATH.', file=sys.stderr)
        return 1

    pub_ok = run('flutter', 'pub', 'get')
    ok = pub_ok
    android = platform in ('all', 'android')
    ios = platform in ('all', 'ios')
    if ios and sys.platform != 'darwin':
        print('Для iOS необходим macOS с Xcode и CocoaPods.', file=sys.stderr)
        ok = False
        ios = False
    if (android or ios) and not run('flutter', 'precache', *(['--android'] if android else []), *(['--ios'] if ios else [])):
        ok = False

    if android:
        if not shutil.which('adb'):
            print('Android: установите Android SDK Platform Tools и добавьте adb в PATH.', file=sys.stderr)
            ok = False
        env = os.environ.copy()
        if sys.platform == 'darwin':
            java = subprocess.run(['/usr/libexec/java_home', '-v', '17'], capture_output=True, text=True)
            if java.returncode == 0:
                env['JAVA_HOME'] = java.stdout.strip()
        local_properties = ROOT / 'android' / 'local.properties'
        sdk_configured = bool(env.get('ANDROID_HOME') or env.get('ANDROID_SDK_ROOT'))
        if local_properties.exists():
            sdk_configured |= any(line.startswith('sdk.dir=') for line in local_properties.read_text().splitlines())
        if not sdk_configured:
            print('Android: настройте Android SDK через Android Studio или ANDROID_HOME.', file=sys.stderr)
            ok = False
        java_bin = str(Path(env['JAVA_HOME']) / 'bin' / 'java') if env.get('JAVA_HOME') else shutil.which('java')
        if not java_bin:
            print('Android: установите JDK 17 или новее.', file=sys.stderr)
            ok = False
        else:
            version = subprocess.run([java_bin, '-version'], capture_output=True, text=True)
            import re
            match = re.search(r'version "(\d+)(?:\.(\d+))?', version.stderr)
            major = int(match.group(2)) if match and match.group(1) == '1' else int(match.group(1)) if match else 0
            if version.returncode or major < 17:
                print('Android: требуется JDK 17 или новее; настройте JAVA_HOME.', file=sys.stderr)
                ok = False
        if not run('./gradlew', '--version', cwd=ROOT / 'android', env=env):
            print('Android: проверьте установку Java и Gradle.', file=sys.stderr)
            ok = False

    if ios:
        if not shutil.which('xcodebuild') or not run('xcodebuild', '-version'):
            print('iOS: установите и настройте Xcode.', file=sys.stderr)
            ok = False
        if not shutil.which('pod'):
            print('iOS: установите CocoaPods и добавьте pod в PATH.', file=sys.stderr)
            ok = False
        elif pub_ok and not run('pod', 'install', cwd=ROOT / 'ios'):
            ok = False
    if ok:
        print('Зависимости подготовлены. Игра не запускалась.')
    return 0 if ok else 1


if __name__ == '__main__':
    sys.exit(main())
