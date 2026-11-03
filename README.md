# Package Game · Client

The Android and iOS client for **Package**, a multiplayer GPS game about building factories, trading resources, and delivering goods on a shared map.

[Server](https://github.com/triangle-int/package-game-backend-5) · [Telegram](https://t.me/packagegame)

## Stack

- **Flutter / Dart** — mobile app for Android and iOS.
- **BLoC / Riverpod** — state management; **Freezed** — data models.
- **flutter_map / OpenStreetMap** — map; **Dio / WebSocket** — server communication.
- **Firebase** — authentication, push notifications, analytics, and crash reporting.

## Getting started

You need Flutter, Python 3, Make, and the platform toolchain: Android SDK with ADB and JDK 17+, or macOS with Xcode and CocoaPods for iOS. Start the [local server](https://github.com/triangle-int/package-game-backend-5#getting-started) first.

Create `.env.staging` (debug) and `.env.production` (release) in the repository root. Both use the same keys; a minimal local configuration is:

```dotenv
SERVER_URL=http://127.0.0.1:3005/
MAP_URL_DARK=https://tile.openstreetmap.org/{z}/{x}/{y}.png
MAP_URL_WHITE=https://tile.openstreetmap.org/{z}/{x}/{y}.png
MAP_ACCESS_KEY=
WIREDASH_SECRET_TOKEN=
WIREDASH_PROJECT_ID=
SERVER_CERTIFICATE=
```

Normal sign-in requires matching Firebase configuration in the client and server. For your own Firebase project, update the platform identifiers and run `flutterfire configure`. Debug builds also support temporary Dev Login with the local server; those accounts are lost from the client on restart.

```bash
make install PLATFORM=android   # Use PLATFORM=ios for iOS
dart run build_runner build --delete-conflicting-outputs
```

Android uses ADB port forwarding. For an iOS simulator, use `make dev i` with the same URL. For a physical iPhone, use the Mac’s LAN IP in both `DEV_BIND_ADDRESS=<mac-ip> make dev` on the server and `make dev i SERVER_URL=http://<mac-ip>:3005/` on the client; signing and a shared network are required. Add `DEVICE=<id>` to select a device; `make stop` ends the development session.

## Development

```bash
flutter analyze
flutter test
```

Regenerate models and providers with the `build_runner` command above after changing their definitions.

## Release builds

```bash
make build a   # APK: build/app/outputs/flutter-apk/app-release.apk
make build i   # IPA: build/ios/ipa/
```

Android requires a signing keystore configured through `android/key.properties` (see [example](android/key.properties.example)). iOS requires Xcode signing; use `IOS_EXPORT_METHOD=app-store` for App Store export. Override `SERVER_URL`, `BUILD_NAME`, or `BUILD_NUMBER` as needed.
