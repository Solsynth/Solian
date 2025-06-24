# Solar Network

![](https://solsynth.dev/_next/static/media/alpha.e779a584.webp)

[![Crowdin](https://badges.crowdin.net/solian/localized.svg)](https://crowdin.com/project/solian)

*Tap the badge above to help us tranlate!*

Hello there! Welcome to the main repository of the DysonNetwork (also known as the Solar Network). The code here is mainly about the front-end app (also known as Solian). But you can still post issues here to get help and request new features!

## Server

The backend of the Solar Network project is located at [Solsynth/DysonNetwork](https://github.com/Solsynth/DysonNetwork)

## Tech Stack

For those people who want to know the tech stack of this project, the front-end was built by Flutter, which provides cross-platform ability.
The backend was built in .NET and PostgreSQL.

If you want to contribute to the project, learn more about the [Code of Conduct](./CODE_OF_CONDUCT.md).

## Getting Started

The content below will lead you to the world of Solar Network.

### For Normal Users

**The v3 Release is not ready, yet.**

1. Go to the Github Releases page, and download the latest release / pre-release according to your platform.
   - **What's the difference between stable and pre-release?** The pre-release is untested by the other users and includes the new cutting-edge features, usually the pre-release is the feature drop. At the same time, due to we're not doing the API versioning, some breaking changes may break the stable release, so use the pre-release one instead.
2. Create an account on the Solar Network
3. Go to your email inbox to confirm your registration
4. Start exploring!

### For Developers

To make the Solar Network App run in debug mode on your machine, you need to install the flutter development environment, for more environments, head to https://flutter.dev.

For the Linux platform, you need to install those extra development libs:

```bash
sudo apt-get update -y
sudo apt-get install -y ninja-build libgtk-3-dev
sudo apt-get install -y libmpv-dev mpv
sudo apt-get install -y libayatana-appindicator3-dev
sudo apt-get install -y keybinder-3.0
sudo apt-get install -y libnotify-dev
sudo apt-get install -y libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev
sudo apt-get install -y gstreamer-1.0
```

Then, use the flutter run for the app running in debug mode.

```bash
flutter pub get
```

If you want to build the release version, use the flutter build command. Learn more from the flutter docs.

```bash
flutter build <platform>
```

