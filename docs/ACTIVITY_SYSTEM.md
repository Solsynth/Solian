# Island Activity System

The Activity System allows users to share their current status (e.g., music playback, gaming) with other users on the Island platform. It supports two main integration paths: **Desktop Now Playing** (native music detection) and **RPC Server** (Discord-compatible protocol for third-party apps).

## Overview

The activity system consists of:

1. **Desktop Presence Services** - Monitor idle status and now playing state
2. **Activity RPC Server** - Discord-compatible server for third-party app integration
3. **Server API** - REST endpoints to manage activities (`/passport/activities`)
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
                    ┌───────────────────────┐
                    │   Server API          │
                    │ POST /passport/activities │
                    │ DELETE /passport/activities │
                    └───────────────────────┘
```

## Activity Data Structure

Activities are submitted as JSON payloads with the following structure:

```json
{
  "type": 2,
  "manual_id": "desktop:now_playing:unique_id",
  "provider": "apple_music",
  "reference_id": "123456789",
  "queryable_terms": ["apple_music", "123456789", "song title", "artist name"],
  "title": "Song Title",
  "subtitle": "Artist Name",
  "caption": "Album Name",
  "title_url": "https://music.apple.com/...",
  "subtitle_url": "https://music.apple.com/...",
  "small_image": "sha256:abc123...",
  "large_image": "sha256:abc123...",
  "meta": {
    "source": "music",
    "provider": "apple_music",
    "playback_rate": 1.0,
    "duration_seconds": 240.5,
    "position_seconds": 120.3
  },
  "lease_minutes": 5
}
```

### Activity Types

| Value | Type      |
|-------|-----------|
| 0     | Unknown   |
| 1     | Gaming    |
| 2     | Music     |
| 3     | Workout   |

### Key Fields

| Field | Description |
|-------|-------------|
| `type` | Activity type (integer) |
| `manual_id` | Unique identifier for the activity (used for updates/cleanup) |
| `provider` | Content provider (e.g., `apple_music`, `spotify`) |
| `reference_id` | Provider-specific content ID |
| `queryable_terms` | Search terms for activity discovery |
| `title` | Primary text (song name, game name, etc.) |
| `subtitle` | Secondary text (artist, game details) |
| `caption` | Tertiary text (album, stream info) |
| `small_image` / `large_image` | Artwork URLs or `sha256:` references |
| `meta` | Provider-specific metadata |
| `lease_minutes` | Activity lease duration (auto-expires) |

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
2. **`sha256:` hashes**: Resolved to `$serverURL/passport/presence/artworks/$hash`
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

### POST /passport/activities

Create or update an activity.

**Query Parameters:**
- `manualId` (optional): Activity identifier for updates

**Request Body:** Activity data object (see structure above)

### DELETE /passport/activities

Remove an activity.

**Query Parameters:**
- `manualId` (required): Activity identifier to remove

### GET /passport/activities/:username

Get activities for a user.

**Response:** Array of activity objects

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

Received when another user's activities change.

```json
{
  "type": "account.presence.activities.updated",
  "data": { "account_id": "..." }
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
