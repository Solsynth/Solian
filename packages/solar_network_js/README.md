# @solarnetwork/js-auth

> Solar Network Web Authentication Client for JavaScript/TypeScript

A lightweight JavaScript/TypeScript client for authenticating web applications with the Solar Network desktop app via a local HTTP server.

## Features

- **TypeScript support** - Full type definitions included
- **Zero dependencies** - Uses native `fetch` API
- **Universal** - Works in browsers and Node.js (with fetch polyfill)
- **Promise-based** - Modern async/await API
- **Flexible** - Use the full flow or individual methods

## Installation

```bash
npm install @solarnetwork/js-auth
```

Or with yarn:

```bash
yarn add @solarnetwork/js-auth
```

## Quick Start

```typescript
import { WebAuthClient } from '@solarnetwork/js-auth';

const client = new WebAuthClient();

// Request authentication
const result = await client.waitForAuth({
  port: 40000,
  appName: 'MyWebApp',
});

if (result.status === 'challenge') {
  // Sign the challenge (implement your signing logic)
  const signedChallenge = await signChallenge(result.challenge);
  
  // Exchange for token
  const tokenResult = await client.exchangeToken({
    port: 40000,
    signedChallenge,
  });
  
  if (tokenResult.status === 'success') {
    console.log('Token:', tokenResult.token);
  }
}
```

## API Reference

### WebAuthClient

```typescript
new WebAuthClient(config?: WebAuthConfig)
```

#### Configuration Options

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `baseUrl` | string | `'http://127.0.0.1'` | Local server base URL |
| `defaultPort` | number | `40000` | Default port to connect to |
| `webUrl` | string | `'https://app.solian.fr'` | Solar Network web URL |

### Methods

#### `getAuthenticationUrl(port?: number): string`

Get the authentication URL for web-based auth flows.

```typescript
const url = client.getAuthenticationUrl(40000);
// Returns: 'https://app.solian.fr/auth/web?port=40000'
```

#### `waitForAuth(options: WaitForAuthOptions): Promise<WebAuthResult>`

Wait for the user to respond to an authentication request.

```typescript
interface WaitForAuthOptions {
  port: number;      // Port of the local Solar Network app
  appName: string;   // Name of your application
}
```

**Returns:**
- `{ status: 'challenge', challenge: '...' }` - User allowed, challenge received
- `{ status: 'denied' }` - User denied the request
- `{ status: 'error', error: '...' }` - Something went wrong

#### `exchangeToken(options: ExchangeTokenOptions): Promise<WebAuthResult>`

Exchange a signed challenge for an auth token.

```typescript
interface ExchangeTokenOptions {
  port: number;
  signedChallenge: string;
  deviceInfo?: Record<string, unknown>;
}
```

**Returns:**
- `{ status: 'success', token: '...' }` - Token received
- `{ status: 'error', error: '...' }` - Something went wrong

#### `fetchAccountInfo<T>(options: FetchAccountInfoOptions): Promise<{ success: boolean; data?: T; error?: string }>`

Fetch the authenticated user's account info.

```typescript
interface FetchAccountInfoOptions {
  port: number;
  token: string;  // The auth token from exchangeToken
}
```

#### `authenticate(options: WaitForAuthOptions & { signChallenge: (challenge: string) => Promise<string> | string }): Promise<WebAuthResult>`

Convenience method that combines the full auth flow.

```typescript
const result = await client.authenticate({
  port: 40000,
  appName: 'MyWebApp',
  signChallenge: async (challenge) => {
    // Your signing implementation
    return signedChallenge;
  },
});

if (result.status === 'success') {
  console.log('Token:', result.token);
}
```

## Authentication Flow

```
┌─────────────┐                              ┌─────────────────┐
│  Your App   │                              │  Solar Network   │
│  (Browser)  │                              │  Desktop App    │
└──────┬──────┘                              └────────┬────────┘
       │                                               │
       │  1. GET /alive?app=Name                      │
       │ ─────────────────────────────────────────────>│
       │                                               │  Show dialog
       │                                               │  User allows/denies
       │  2. { status: 'ok', challenge: '...' }       │
       │◀─────────────────────────────────────────────│
       │                                               │
       │  3. Sign challenge (implement signing)        │
       │                                               │
       │  4. POST /exchange { signed_challenge: ... }  │
       │ ─────────────────────────────────────────────>│
       │                                               │
       │  5. { status: 'ok', token: '...' }           │
       │◀─────────────────────────────────────────────│
       │                                               │
       │  6. Use token to call API                     │
       └────────────────────────────────────────────────
```

## Complete Example

```typescript
import { WebAuthClient } from '@solarnetwork/js-auth';

const client = new WebAuthClient();

async function authenticate() {
  try {
    // Step 1: Wait for user response
    const authResult = await client.waitForAuth({
      port: 40000,
      appName: 'MyWebApp',
    });

    if (authResult.status === 'denied') {
      console.log('User denied the request');
      return;
    }

    if (authResult.status !== 'challenge') {
      console.error('Auth failed:', authResult.error);
      return;
    }

    // Step 2: Sign the challenge
    // This is where you'd implement your cryptographic signing
    const signedChallenge = await signWithPrivateKey(authResult.challenge);

    // Step 3: Exchange for token
    const tokenResult = await client.exchangeToken({
      port: 40000,
      signedChallenge,
    });

    if (tokenResult.status !== 'success') {
      console.error('Token exchange failed:', tokenResult.error);
      return;
    }

    console.log('Authentication successful!');
    console.log('Token:', tokenResult.token);

    // Step 4: Fetch account info
    const accountResult = await client.fetchAccountInfo({
      port: 40000,
      token: tokenResult.token!,
    });

    if (accountResult.success) {
      console.log('Account:', accountResult.data);
    }
  } catch (error) {
    console.error('Authentication error:', error);
  }
}

// Example signing function (implement your own)
async function signWithPrivateKey(challenge: string): Promise<string> {
  // Use Web Crypto API or your preferred crypto library
  const encoder = new TextEncoder();
  const data = encoder.encode(challenge);
  
  // Import your private key (example using RSA)
  const privateKey = await crypto.subtle.importKey(
    'pkcs8',
    /* your private key bytes */,
    { name: 'RSA-PSS', hash: 'SHA-256' },
    false,
    ['sign']
  );

  const signature = await crypto.subtle.sign(
    { name: 'RSA-PSS', saltLength: 32 },
    privateKey,
    data
  );

  // Return as base64
  return btoa(String.fromCharCode(...new Uint8Array(signature)));
}

authenticate();
```

## Browser Example

See [`examples/browser/`](examples/browser/) for a complete browser-based example.

### Running the Example

```bash
cd examples/browser
npm install
npm start
```

Then open `http://localhost:3000` in your browser.

## Requirements

- Modern browser with `fetch` support OR Node.js 18+ (with fetch polyfill for older versions)
- TypeScript 5.0+ (for type checking, optional)

## License

MIT
