# Island Activity System

The Activity System allows users to share their current status (e.g., music playback, gaming) with other users on the Island platform. It supports two main integration paths: **Desktop Now Playing** (native music detection) and **RPC Server** (Discord-compatible protocol for third-party apps).

## Overview

The activity system consists of:

1. **Desktop Presence Services** - Monitor idle status and now playing state
2. **Activity RPC Server** - Discord-compatible server for third-party app integration
3. **Server API** - Pulsar playback endpoints (`/pulsar/sessions`, `/pulsar/users/.../now-playing`)
4. **WebSocket Updates** - Real-time presence updates via WebSocket

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        Island App                               │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────┐ │
│  │ Desktop Presence│    │  Now Playing    │    │  RPC Server │ │
│  │  (Idle Status)  │    │   Service       │    │  (arRPC)    │ │
│  └────────┬────────┘    └────────┬────────┘    └──────┬──────┘ │
│           │                      │                    │        │
│           ▼                      ▼                    ▼        │
│  ┌────────────────────────────────────────────────────────────┐│
│  │                   Activity Data Builder                    ││
│  └────────────────────────────┬───────────────────────────────┘│
│                               │                                │
└───────────────────────────────┼────────────────────────────────┘
                                │
                                ▼
                    ┌──────────────────────────────┐
                    │          Pulsar API          │
                    │ POST /pulsar/sessions/now-playing │
                    │ POST /pulsar/sessions/end    │
                    └──────────────────────────────┘
```

## Activity Data Structure

Activities are submitted as JSON payloads with the following structure:

```json
{
  "domain": "music",
  "manual_id": "desktop:now_playing:unique_id",
  "provider": "apple_music",
  "provider_key": "123456789",
  "title": "Song Title",
  "subtitle": "Artist Name",
  "caption": "Album Name",
  "artwork_url": "sha256:abc123...",
  "small_image": "sha256:abc123...",
  "large_image": "sha256:abc123...",
  "progress_seconds": 120,
  "duration_seconds": 240,
  "meta": {
    "source": "music",
    "provider": "apple_music",
    "playback_rate": 1.0
  },
  "lease_minutes": 5
}
```

### Activity Domains

| Value      | Meaning                         |
|------------|---------------------------------|
| `music`    | Music or podcast playback       |
| `gaming`   | Game activity                   |
| `video`    | Video playback                  |
| `anime`    | Anime playback                  |
| `book`     | Reading                         |
| `custom`   | Anything else                   |

Pulsar also stores the free-form domain on each session; the client maps
`video`/`anime` to the entertainment presence glyph and `book` to reading.

### Key Fields

| Field | Description |
|-------|-------------|
| `domain` | Activity kind (`music`, `gaming`, `video`, `anime`, `book`, `custom`) |
| `manual_id` | Unique identifier for the session (used for updates/cleanup) |
| `provider` | Content provider (e.g., `apple_music`, `spotify`) |
| `provider_key` | Provider-specific content ID |
| `title` | Primary text (song name, game name, etc.) |
| `subtitle` | Secondary text (artist, game details) |
| `caption` | Tertiary text (album, stream info) |
| `small_image` / `large_image` | Artwork URLs; `artwork_url` is the canonical field |
| `progress_seconds` / `duration_seconds` | Playback position and length |
| `meta` | Provider-specific metadata |
| `lease_minutes` | Session lease duration (auto-expires) |

## Desktop Now Playing Service

The `DesktopNowPlayingService` monitors system media playback using `nowplaying-cli` (macOS) or native APIs.

### Features

- **Polling-based detection**: Polls every 2 seconds for media state changes
- **Multi-source support**: Apple Music, Spotify, and other media players
- **Artwork handling**: Resolves artwork hashes to server URLs
- **Automatic cleanup**: Clears activity after 1 minute of pause, immediately on stop
- **Lease renewal**: Renews activity every 4.5 minutes (lease is 5 minutes)

### Configuration

Settings in **Desktop Presence > Now Playing**:

| Setting | Description |
|---------|-------------|
| Enable Now Playing | Master toggle for now playing detection |
| CLI Path (macOS) | Path to `nowplaying-cli` executable |
| Reuse Fixed Manual ID | Use same manual ID across all tracks |
| Disable Apple Music Integration | Disable MusicKit API (keeps basic detection) |

### Manual ID Generation

Manual IDs follow the pattern:
- Fixed mode: `desktop:now_playing:fixed`
- Dynamic mode: `desktop:now_playing:<unique_id>` or `desktop:now_playing:<title_hash>`

## Activity RPC Server

The RPC Server implements a Discord-compatible Rich Presence protocol, allowing third-party apps to set activity status.

### Supported Protocols

1. **WebSocket** (port 6463-6472)
   - JSON encoding only
   - Version 1 only

2. **IPC** (Unix domain sockets / Windows named pipes)
   - Binary packet format (8-byte header + JSON payload)
   - Used by Electron apps

### Packet Format (IPC)

```
┌─────────────┬─────────────┬──────────────────┐
│ Type (4B)   │ Length (4B) │ Data (variable)  │
│ Int32 LE    │ Int32 LE    │ JSON encoded     │
└─────────────┴─────────────┴──────────────────┘
```

IPC Packet Types:
- 0: Handshake
- 1: Frame (data)
- 2: Close
- 3: Ping
- 4: Pong

### RPC Commands

#### SET_ACTIVITY

Sets the user's activity status.

**Request:**
```json
{
  "cmd": "SET_ACTIVITY",
  "args": {
    "activity": {
      "name": "Spotify",
      "type": 2,
      "details": "Song Title",
      "state": "Artist Name",
      "assets": {
        "large_image": "spotify_abcd1234",
        "large_text": "Album Name",
        "small_image": "play_icon",
        "small_text": "Playing"
      }
    }
  },
  "nonce": "unique-request-id"
}
```

**Response:**
```json
{
  "cmd": "SET_ACTIVITY",
  "data": { ... },
  "evt": null,
  "nonce": "unique-request-id"
}
```

### Discord Type Mapping

The RPC server maps Discord activity types to Island activity types:

| Discord Type | Value | Island Type | Value |
|--------------|-------|-------------|-------|
| Playing      | 0     | Gaming      | 1     |
| Listening    | 2     | Music       | 2     |
| Watching     | 3     | Music       | 2     |
| Competing    | 5     | Gaming      | 1     |

### Asset Handling

Discord assets are prefixed with `discord:` when they don't contain a colon:
- `large_image: "abcd1234"` → `large_image: "discord:abcd1234"`
- `large_image: "https://..."` → unchanged

## Configuration

### Desktop Presence Settings

Located in **Settings > Desktop Presence**:

#### Idle Status
- **Enable Idle Status**: Monitor and share idle state via WebSocket

#### Now Playing
- **Enable Now Playing**: Detect and share media playback state
- **CLI Path**: Path to `nowplaying-cli` (macOS)
- **Reuse Fixed Manual ID**: Use consistent activity ID
- **Disable Apple Music Integration**: Skip MusicKit API calls

#### RPC Server
- **Enable RPC Server**: Start Discord-compatible RPC server
- **Server Status**: Current server state (running/stopped/error)
- **Recent Packets**: View captured RPC packets with direction indicators

### Provider Configuration

Providers are resolved in this order:
1. Explicit `providerKey` from the event
2. Source-based mapping:
   - `ExternalNowPlayingSource.music` → `apple_music`
   - `ExternalNowPlayingSource.spotify` → `spotify`
   - Other → Bundle identifier or app name

## Artwork Resolution

Artwork URLs can be:
1. **HTTP/HTTPS URLs**: Direct image links
2. **`sha256:` hashes**: Resolved to `$serverURL/stargate/presence/artworks/$hash`
3. **Discord asset IDs**: Prefixed with `discord:` for RPC activities

## Error Handling

- **Publish failures**: Error stored in `NowPlayingState.lastError`, displayed in preview
- **Connection issues**: Activities queued for retry
- **Lease expiration**: Activities auto-expire after `lease_minutes`

## Debugging

The settings UI provides real-time debugging tools:

1. **Idle Status Preview**: Shows current idle time
2. **Now Playing Preview**: Shows detected track info, activity payload, and errors
3. **RPC Server Preview**: Shows server status, current activity, and packet log

### Packet Logging

The RPC server captures the last 50 packets with:
- Direction (incoming/outgoing)
- Packet type
- Timestamp
- Full JSON payload (expandable)

## API Endpoints

### POST /pulsar/sessions/now-playing

Create or refresh a live session. Pulsar upserts on `(account_id, manual_id)`,
so renewals use the same call.

**Request Body:** Pulsar session object (see structure above). `title` is
required; `domain` defaults to `music`.

### POST /pulsar/sessions/end

End a live session.

**Request Body:**

```json
{ "manual_id": "desktop:now_playing:unique_id", "auto_scrobble": false }
```

`auto_scrobble` defaults to `false`; the Discord-RPC path must leave it off.

### GET /pulsar/users/:username/now-playing

Get the active sessions for one account.

**Response:** Array of Pulsar session objects.

### GET /pulsar/presence/activities?account_ids=…

Batch form used by the friend overview. Comma-separated or repeated
`account_ids`; at most 200 per request. Only active sessions are returned.

## WebSocket Events

### status.idle

Sent when idle state changes.

```json
{
  "type": "status.idle",
  "data": { "is_idle": true },
  "endpoint": "passport"
}
```

### account.presence.activities.updated

Received when a live session changes. Pulsar sends one `session` object (or
`null` when the session ends); the client also accepts Stargate's legacy
`activities` array.

```json
{
  "type": "account.presence.activities.updated",
  "data": {
    "account_id": "...",
    "session": { "id": "...", "domain": "music", "title": "..." }
  }
}
```

## Platform Support

| Feature | macOS | Windows | Linux | Web | Mobile |
|---------|-------|---------|-------|-----|--------|
| Idle Status | ✓ | ✓ | ✓ | ✗ | ✗ |
| Now Playing | ✓ | ✓ | ✗ | ✗ | ✗ |
| RPC Server | ✓ | ✓ | ✓ | ✗ | ✗ |

## Dependencies

- `nowplaying-cli`: macOS command-line tool for media detection
- `IslandDesktopPresence`: Native plugin for system monitoring
- `shelf` / `shelf_web_socket`: HTTP/WebSocket server for RPC
- `activity_rpc_transport`: IPC transport layer
