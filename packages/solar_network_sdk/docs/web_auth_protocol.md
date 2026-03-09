# Web Auth Protocol (solian://auth/web)

This document describes the native APP_CONNECT-compatible web auth trigger
handled by Solian via deep link protocol:

- `solian://auth/web`

It is designed for native apps (for example iOS/Android custom URI schemes)
that need challenge and token exchange through the Solian app.

## Overview

Two deep-link calls are supported:

1. Challenge request
2. Token exchange request

Both calls require `redirect_uri` so Solian can return result data to your app.

## Challenge Request

Use this URL format:

```text
solian://auth/web?app=<app_slug>&redirect_uri=<encoded_redirect_uri>&state=<optional_state>
```

Parameters:

- `app`: app slug (required). Solian resolves app metadata from `/develop/apps/<slug>`.
- `redirect_uri`: your app callback URI (must include a scheme), e.g. `acme://auth/callback`.
- `state` (optional): opaque value that Solian echoes back.

Success callback:

```text
<redirect_uri>?status=ok&challenge=<challenge>&state=<state>
```

Denied callback:

```text
<redirect_uri>?status=denied&state=<state>
```

Error callback:

```text
<redirect_uri>?status=error&error=<reason>&state=<state>
```

## Token Exchange Request

After your app signs the challenge with APP_CONNECT secret, use:

```text
solian://auth/web?signed_challenge=<signature>&redirect_uri=<encoded_redirect_uri>&state=<optional_state>
```

Parameters:

- `signed_challenge`: APP_CONNECT signature (snake_case field name).
- `redirect_uri`: your app callback URI.
- `state` (optional): opaque value echoed back.

Success callback:

```text
<redirect_uri>?status=success&token=<session_token>&state=<state>
```

Error callback:

```text
<redirect_uri>?status=error&error=<reason>&state=<state>
```

## SDK Helpers

`WebAuthClient` provides helper builders:

- `getProtocolChallengeUrl({ appSlug, redirectUri, state })`
- `getProtocolExchangeUrl({ signedChallenge, redirectUri, state })`

These produce properly encoded `solian://auth/web` URLs.

## Notes

- Solian expects snake_case fields for APP_CONNECT payloads.
- `redirect_uri` must be a valid URI with scheme.
- Preserve and verify `state` in callback to prevent request mix-up.
