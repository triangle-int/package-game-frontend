#!/usr/bin/env python3
"""Build signed release artifacts for Android or iOS."""

import os
from pathlib import Path
import shutil
import subprocess
import sys
from urllib.parse import urlparse

ROOT = Path(__file__).resolve().parent.parent


def optional_build_arguments():
    arguments = []
    server_url = os.environ.get('SERVER_URL', '')
    if server_url:
        parsed_url = urlparse(server_url)
        if parsed_url.scheme not in ('http', 'https') or not parsed_url.hostname:
            sys.exit('SERVER_URL должен быть полным адресом http:// или https://.')
        arguments.append(f'--dart-define=SERVER_URL={server_url}')

    build_name = os.environ.get('BUILD_NAME', '')
    build_number = os.environ.get('BUILD_NUMBER', '')
    if build_name:
        arguments.append(f'--build-name={build_name}')
    if build_number:
        arguments.append(f'--build-number={build_number}')
    return arguments


def build_android(arguments):
    if not (ROOT / 'android' / 'key.properties').is_file():
        sys.exit(
            'Не найден android/key.properties. Release APK должен быть подписан; '
            'добавьте локальный keystore и его настройки в key.properties.'
        )
    command = [
        'flutter',
        'build',
        'apk',
        '--release',
        '--android-skip-build-dependency-validation',
        *arguments,
    ]
    result = subprocess.run(command, cwd=ROOT)
    if result.returncode == 0:
        print('Готовый APK: build/app/outputs/flutter-apk/app-release.apk')
    return result.returncode


def build_ios(arguments):
    if sys.platform != 'darwin' or not shutil.which('xcodebuild'):
        sys.exit('Для сборки IPA необходим macOS с установленным Xcode.')
    export_method = os.environ.get('IOS_EXPORT_METHOD', 'development')
    allowed_methods = {'app-store', 'ad-hoc', 'development', 'enterprise'}
    if export_method not in allowed_methods:
        sys.exit(
            'IOS_EXPORT_METHOD должен быть одним из: '
            'app-store, ad-hoc, development, enterprise.'
        )
    command = [
        'flutter',
        'build',
        'ipa',
        '--release',
        f'--export-method={export_method}',
        *arguments,
    ]
    result = subprocess.run(command, cwd=ROOT)
    if result.returncode == 0:
        ipa_files = sorted((ROOT / 'build' / 'ios' / 'ipa').glob('*.ipa'))
        if ipa_files:
            print(f'Готовый IPA: {ipa_files[-1].relative_to(ROOT)}')
        else:
            print('Готовый iOS-архив: build/ios/archive/Runner.xcarchive')
    return result.returncode


def main():
    if len(sys.argv) != 2 or sys.argv[1] not in ('a', 'i'):
        sys.exit('Используйте make build a для Android или make build i для iOS.')
    if not shutil.which('flutter'):
        sys.exit('Установите Flutter SDK и добавьте flutter в PATH.')
    arguments = optional_build_arguments()
    if sys.argv[1] == 'a':
        return build_android(arguments)
    return build_ios(arguments)


if __name__ == '__main__':
    sys.exit(main())
