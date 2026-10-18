# 📦 Package Game Frontend

This repository contains full source code for the frontend part of the package game.

## 📖 About

This is a rewrite of Package on new engine - **Flutter**. Original version on Unity will not be published, because it's so legacy.

## 🗄️ Backend

To test application you need to have running backend. You can learn how to do it from [this link](https://github.com/triangle-int/package-game-backend-5)

## 🛠️ Build

Package currently supports only iOS and Android build targets. Some features may be presented in iOS, but not in Android version (for example IAP in Android is still not working).

> ❗️ iOS can be built only on **MacOS**

### 1. Install the requirement

First of all, we need to install these packages to be able to build application.

- [Flutter](https://docs.flutter.dev/get-started/install)
- [Firebase CLI](https://firebase.google.com/docs/cli#setup_update_cli)
- Any code editor, I use [VSCode](https://code.visualstudio.com/)
- [XCode](https://developer.apple.com/download/applications/) - optional, needed only if you want to build on iOS
- [Android Studio](https://developer.android.com/studio) - optional, needed only if you want to build on Android

There's also some handy extensions for VSCode:

- [Flutter](https://marketplace.visualstudio.com/items?itemName=Dart-Code.flutter)
- [Awesome Flutter Snippets](https://marketplace.visualstudio.com/items?itemName=Nash.awesome-flutter-snippets)

### 1.1. (Optional) Create service accounts

If you want to use feedback feature then create an account on [Wiredash](https://wiredash.io/) and create a project in the Wiredash dashboard.

For authentication and push notifications Package uses Firebase. This repository already includes all API keys for Firebase, but if you want use your own Firebase project - do this:

1. Create Firebase project
2. Change Bundle ID for Android and iOS
   - For Android change Bundle ID in files `android/app/build.gradle`, `android/app/src/{debug,main,profile}/AndroidManifest.xml`,
     `android/app/src/main/kotlin/com/example/package_flutter/MainActivity.kt`.
   - For iOS change Bundle ID in XCode by openning `ios/Runner.xcworkspace`.
3. Run commands
   ```bash
   $ firebase login
   $ dart pub global activate flutterfire_cli
   $ flutterfire configure
   ```

### 2. Prepare workspace

After installation is done, we need to clone repository on local machine:

```bash
$ git clone https://github.com/triangle-int/package-game-frontend.git
```

or if you're using `SSH`:

```bash
$ git clone git@github.com:triangle-int/package-game-frontend.git
```

You might also want to create a fork of Package repository, so feel free to do it!

Next we need to install the dependecies:

```bash
$ flutter pub get
```

Flutter often uses a technic called a _code generation_. And Package uses it's too, so we need to generate a code using `build_runner`

```bash
$ dart run build_runner build
```

> 💡 **Tip for developing**
>
> If you are developing a flutter application and you need run code generation after every change - use this command
>
> ```bash
> dart run build_runner watch
> ```

The final step of preperation is `.env` files. We need to create two files: `.env.staging` and `.env.production`. Schema for both of theese files is same, but you can tweak some values.

> ❗️ If value is optional you still need to declare it in the file, for example `ENV_VARIABLE=""`

#### .env schema

| Key                     | Is required | Description                                                                                                                                                                                 | Example value                                                   |
| ----------------------- | ----------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------- |
| `SERVER_URL`            | Required    | Url to the instance of [Package backend](https://github.com/triangle-int/package-game-backend-5)                                                                                            | `http://api.example.com:3000/`                                  |
| `MAP_ACCESS_KEY`        | Optional    | API Key for tile server of your choose.                                                                                                                                                     | `API_KEY_EXAMPLE`                                               |
| `MAP_URL_DARK`          | Required    | Url to the tile server, must expose: {x} - Tile X, {y} - Tile Y, {z} - Zoom Level (1 - 20) and optional: {r} - Retina mode, {api_key} - key from `MAP_ACCESS_KEY` field (`@2x` or nothing). | `https://tile.openstreetmap.org/{z}/{x}/{y}.png`                |
| `MAP_URL_WHITE`         | Required    | Same as `MAP_URL_DARK` but for light. theme.                                                                                                                                                | `https://tile.openstreetmap.org/{z}/{x}/{y}.png`                |
| `WIREDASH_SECRET_TOKEN` | Optional    | Wiredash Secret Token for feedback. feature                                                                                                                                                 | `API_KEY_EXAMPLE`                                               |
| `WIREDASH_PROJECT_ID`   | Optional    | Wiredash Project ID for feedback.feature                                                                                                                                                    | `PROJECT_ID_EXAMPLE`                                            |
| `SERVER_CERTIFICATE`    | Optional    | If you're using HTTPS you can pass here certificate for edge cases.                                                                                                                         | `-----BEGIN CERTIFICATE-----\nBebra\n-----END CERTIFICATE-----` |

Now we have development ready enviroment, let's get right into building!

### 3. Running

The most interesting part begins. Connect your phone to the PC/Laptop and run

```bash
$ flutter run
```

🎉 Congratilations! You've built a Package!

## ❓ Troubleshooting

TODO

## 💩 Shitty moments disclaimer

Some parts of code are still not refactored and contains many dublications. In free time I will refactor this parts, but if you want speed up the process - submit a pull request or an issue. Please 🙏. Help me...
# Local Android development login

Run `make dev` in the backend directory to start its isolated database and
server. Run `make dev` here to launch a connected Android device or iOS
simulator. If several devices are available, select one with
`make dev DEVICE=<device-id>`; `flutter devices` lists the IDs. Android ports
are forwarded through ADB. `make stop` stops the Flutter session started by
this Makefile. The **Dev Login** button signs in as `dev_user_1`.

For a physical iPhone, start the development backend with
`DEV_BIND_ADDRESS=<mac-lan-ip> make dev` in the backend directory, and run
`make dev DEVICE=<device-id> SERVER_URL=http://<mac-lan-ip>:3005/` here.
Both devices must be on a trusted network. The fixed development login token
is exposed on the selected network interface. iOS device builds also require
valid Xcode signing. The simulator uses localhost by default.
Never enable this option on a public server: the development token is fixed.
