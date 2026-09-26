# Solian (Solar Network)

<p align="center">
  <img src="assets/icons/icon.webp" width="120" alt="Solian Logo">
</p>

<p align="center">
  <b>A peaceful social network</b>
</p>

<p align="center">
  <a href="LICENSE.txt"><img src="https://img.shields.io/github/license/Solsynth/HyperNet.Surface" alt="License"></a>
  <a href="https://github.com/Solsynth/HyperNet.Surface/releases"><img src="https://img.shields.io/github/v/release/Solsynth/HyperNet.Surface?include_prereleases" alt="Latest Release"></a>
</p>

---

Solian (also known as Solar Network) is a social networking platform, designed to help you express yourself freely and connect with others. We're not aiming to replace any major platform—just providing another peaceful community for you to be part of.

Note: Fediverse support is currently experimental and limited.

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
| --------- | -------- | ------------- |
| Timeline | Done | Chronological feed of posts |
| Posts, Articles & Blog | Done | Multiple content types for different needs |
| Post Chaining | Done | Chain related posts into a thread |
| Instant Messaging | Done | Real-time chat with groups, voice messages, reactions and read receipts |
| End-to-End Encryption | Done | MLS-encrypted messages |
| Realms | Done | Communities organized by shared interests |
| OAuth Integration | Done | Secure third-party authentication |
| Passkeys | Done | Passwordless sign-in with WebAuthn passkeys |
| Check-in | Done | Location and status sharing |
| Countdown | Done | Track special dates and festivals |
| Event Calendar | Done | Plan and share events with your community |
| Meet | Done | Find and meet people nearby |
| Weather | Done | Weather forecast on your dashboard |
| Wallet | Done | Credits, exchange, orders and billing |
| Stickers | Done | Express yourself with custom stickers |
| Rich Text Editor | Done | Markdown-based with extended syntax |
| Social Features | Done | Friends, blocklist and mute management |
| File Management | Done | Upload and organize files |
| Tickets | Done | Support tickets and issue tracking |
| Plugins | Done | Extend the app with community plugins |
| Board | Done | Custom widgets on your profile |
| Workspaces | Done | Shared spaces for collaboration |
| Progressions | Done | Make your move on Solar Network memorizable |
| Fediverse | Beta | Interact with other fediverse instances |

### Relay Route

Traffic can be routed through a nearby **relay node** instead of dialing the
server directly. Relays are L4: they read the SNI from the TLS ClientHello and
copy bytes to the origin without terminating TLS, so the certificate, `Host`
header, and end-to-end encryption are unchanged — only the socket moves.

Pick one under **Settings → Connection → Relay Route**, or leave it on
*Direct*. The list comes from the server's `GET /relays` catalog (loaded over a
direct connection so a broken relay can never hide its own picker). Selecting a
route applies immediately: HTTP clients are rebuilt and the realtime channel is
re-dialed; the selection persists across launches.

The reusable pieces — catalog client, models, and the connection factory — live
in [`solar_network_foundation`](packages/solar_network_foundation) so other
Solar Network clients can route through the same relays.

Not routed through a relay: native transports that never touch Dart's HTTP
stack (media playback, WebRTC, in-app webviews, platform notification/native
plugins).

---

## Getting Started

### For Users

1. **Download the App**
   - Visit [Solar Network product page](https://solsynth.dev/products/solar-network) to download the latest version for your platform
   - **Rolling updates:** Solian uses rolling releases — we don't use API versioning, so breaking changes can land at any time. Keep the app up to date for the best experience.

2. **Create an Account**
   - Sign up on the Solar Network
   - Verify your email address
   - Start exploring!

### For Developers

#### Prerequisites

- [Flutter SDK](https://flutter.dev) installed
- For Windows development, install [NASM](https://www.nasm.us) (required by `webcrypto` native assets):

  ```powershell
  winget install NASM.NASM
  ```

- For macOS development, keep the Rust `stable` toolchain current (`rustup update stable`). Archiving from Xcode fails with `E0463: can't find crate for proc_macro_error_attr` when `stable` is older than 1.98 — Xcode's `MACOSX_DEPLOYMENT_TARGET` (13.5) makes the linker emit chained-fixups proc-macro dylibs that older rustc cannot read.
- For Linux development, install additional dependencies:
- For web, the preferred build params is: `flutter build web --wasm`

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
| ------- | ------------ |
| **Frontend** | Flutter - Cross-platform UI framework |
| **Backend** | .NET with PostgreSQL database |
| **Protocols** | ActivityPub (Fediverse), WebSockets, REST API |

---

## Contributing

We welcome contributions! Please read our [Code of Conduct](./CODE_OF_CONDUCT.md) before participating.

- [Report bugs](https://github.com/Solsynth/HyperNet.Surface/issues)
- [Suggest features](https://github.com/Solsynth/HyperNet.Surface/discussions)

## Licensing

This project is licensed under the GNU Affero General Public License v3.0 (AGPL-3.0).

If you deploy an instance of DysonNetwork, fork the Island project, or redistribute modified versions of this software, you must comply with the AGPL-3.0 license terms, including:

- Including a copy of the original license
- Preserving existing copyright notices and attribution
- Clearly stating any modifications you made
- Providing corresponding source code to users interacting with the service over a network

Original authorship and copyright attribution to LittleSheep, Solsynth, and this repository’s contributors must be retained where applicable.

Please note that the AGPL-3.0 license applies to the software source code only. Certain assets, logos, icons, branding materials, and trademarks may be licensed separately and are not automatically covered under the same terms.

Third-party deployments, forks, and derivative services must not impersonate or present themselves as the official Solar Network service operated by Solsynth.

The names “Solar Network”, “Solian”, related logos, and associated branding may not be used to market, advertise, or identify third-party deployments without prior permission from Solsynth.

References to the underlying DysonNetwork software or the Island project for descriptive or compatibility purposes are permitted.

Besides, if your fork project is an 3rd party client of the Solar Network,
make sure you've read and understand the [Solar Network Developer Agreement](https://solsynth.dev/en/legal/solar-network-dev/)

See:

- [LICENSE.txt](./LICENSE.txt)
- [assets/LICENSE.md](./assets/icons/LICENSE.md) (if applicable)

---

<p align="center">
  Made with love by the Solar Network Team
</p>
