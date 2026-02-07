# Solian (Solar Network)

<p align="center">
  <img src="assets/icons/icon.png" width="120" alt="Solian Logo">
</p>

<p align="center">
  <b>A peaceful social network</b>
</p>

<p align="center">
  <a href="LICENSE.txt"><img src="https://img.shields.io/github/license/Solsynth/HyperNet.Surface" alt="License"></a>
  <a href="https://crowdin.com/project/solian"><img src="https://badges.crowdin.net/solian/localized.svg" alt="Localization Status"></a>
  <a href="https://github.com/Solsynth/HyperNet.Surface/releases"><img src="https://img.shields.io/github/v/release/Solsynth/HyperNet.Surface?include_prereleases" alt="Latest Release"></a>
</p>

---

Solian (also known as Solar Network) is a social networking platform, designed to help you express yourself freely and connect with others. We're not aiming to replace any major platform—just providing another peaceful community for you to be part of.

Note: Fediverse support is currently experimental and limited.

> **Help us translate!** Click the Crowdin badge above to contribute translations.
>
> If you read Chinese, visit our documentation: [Suki - Solar Network](https://kb.solsynth.dev/zh/solar-network) | [中文 README](./README_CN.md)

---

## Table of Contents

- [Features](#features)
- [Getting Started](#getting-started)
  - [For Users](#for-users)
  - [For Developers](#for-developers)
- [Packages](#packages)
- [Server](#server)
- [Tech Stack](#tech-stack)
- [Contributing](#contributing)

---

## Features

### Available Now

| Feature | Status | Description |
|---------|--------|-------------|
| Timeline | Done | Chronological feed of posts |
| Posts, Articles & Moments | Done | Multiple content types for different needs |
| Instant Messaging | Done | Real-time chat with group support |
| Realms | Done | Communities organized by shared interests |
| OAuth Integration | Done | Secure third-party authentication |
| Check-in | Done | Location and status sharing |
| Countdown | Done | Track special dates and festivals |
| RSS Reader | Done | Subscribe to external feeds |
| Wallet | Done | Credit system for transactions |
| Stickers | Done | Express yourself with custom stickers |
| Rich Text Editor | Done | Markdown-based with extended syntax |
| Social Features | Done | Friends list and blocklist management |
| File Management | Done | Upload and organize files |
| AI Features | Done | Smart assistance throughout the app |

### Coming Soon

- **Fitness & Health** - Track your health and exercise goals
- **SolarWatt Ideask** - An todo and task management app

---

## Getting Started

### For Users

1. **Download the App**
   - Visit [GitHub Releases](https://github.com/Solsynth/HyperNet.Surface/releases) to download the latest version for your platform
   - **Stable vs Pre-release:** Pre-releases include cutting-edge features but may have untested changes. Since we don't use API versioning, breaking changes may affect stable releases—consider using pre-releases for the best experience.

2. **Create an Account**
   - Sign up on the Solar Network
   - Verify your email address
   - Start exploring!

### For Developers

#### Prerequisites

- [Flutter SDK](https://flutter.dev) installed
- For Linux development, install additional dependencies:

```bash
sudo apt-get update -y
sudo apt-get install -y \
  ninja-build \
  libgtk-3-dev \
  libmpv-dev \
  mpv \
  libayatana-appindicator3-dev \
  keybinder-3.0 \
  libnotify-dev \
  libgstreamer1.0-dev \
  libgstreamer-plugins-base1.0-dev \
  gstreamer-1.0
```

#### Running the App

```bash
# Install dependencies
flutter pub get

# Run in debug mode
flutter run

# Build release version
flutter build <platform>
```

See the [Flutter documentation](https://docs.flutter.dev) for more build options.

---

## Packages

This repository is organized as a monorepo containing useful Dart packages under the `packages/` directory.

Want to build with Solar Network? Check out:

- [Documentation](https://kb.solsynth.dev)
- [API Reference](https://api.solsynth.dev)
- [`packages/solar_network_sdk`](./packages/solar_network_sdk) - Official Dart SDK

---

## Server

The backend powering Solar Network is available at:
**[Solsynth/DysonNetwork](https://github.com/Solsynth/DysonNetwork)**

---

## Tech Stack

| Layer | Technology |
|-------|------------|
| **Frontend** | Flutter - Cross-platform UI framework |
| **Backend** | .NET with PostgreSQL database |
| **Protocols** | ActivityPub (Fediverse), WebSockets, REST API |

---

## Contributing

We welcome contributions! Please read our [Code of Conduct](./CODE_OF_CONDUCT.md) before participating.

- [Report bugs](https://github.com/Solsynth/HyperNet.Surface/issues)
- [Suggest features](https://github.com/Solsynth/HyperNet.Surface/discussions)
- [Translate the app](https://crowdin.com/project/solian)

---

<p align="center">
  Made with love by the Solar Network Team
</p>
