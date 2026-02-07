# Solar Network JS Auth Example

This is an example web application demonstrating how to use `@solarnetwork/js-auth`.

## Quick Start

```bash
npm install
npm start
```

Then open http://localhost:5173 in your browser.

## What This Does

1. Enter your Solar Network desktop app's port (default: 40000)
2. Enter your app name
3. Click "Start Authentication"
4. The Solar Network desktop app will show a confirmation dialog
5. Allow or deny the request in the desktop app
6. If allowed, the web app receives a challenge and exchanges it for a token
7. Use the token to fetch account info

## Files

- `index.html` - The example web app
- `package.json` - Dependencies and scripts
