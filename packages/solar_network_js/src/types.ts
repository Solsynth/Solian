/**
 * Type definitions for Solar Network Web Authentication Client
 */

/**
 * Authentication status returned by the web auth client
 */
export enum WebAuthStatus {
  /** Waiting for user to respond - challenge received */
  challenge = 'challenge',
  /** Authentication successful - token received */
  success = 'success',
  /** Authentication failed - error occurred */
  error = 'error',
  /** User denied the authentication request */
  denied = 'denied',
}

/**
 * Result of an authentication operation
 */
export interface WebAuthResult {
  /** The current status of the authentication */
  status: WebAuthStatus;
  /** The challenge string (only when status is 'challenge') */
  challenge?: string;
  /** The auth token (only when status is 'success') */
  token?: string;
  /** The refresh token (only when status is 'success' and available) */
  refreshToken?: string;
  /** Access token lifetime in seconds */
  expiresIn?: number;
  /** Refresh token lifetime in seconds */
  refreshExpiresIn?: number;
  /** Error message (only when status is 'error') */
  error?: string;
}

/**
 * Configuration for the WebAuthClient
 */
export interface WebAuthConfig {
  /** The local server base URL (default: 'http://127.0.0.1') */
  baseUrl?: string;
  /** The default port to connect to (default: 40000) */
  defaultPort?: number;
  /** The Solar Network web URL for auth redirects (default: 'https://app.solian.fr') */
  webUrl?: string;
}

/**
 * Options for waitForAuth
 */
export interface WaitForAuthOptions {
  /** The port of the local Solar Network app */
  port: number;
  /** The name of your application */
  appName: string;
}

/**
 * Options for exchangeToken
 */
export interface ExchangeTokenOptions {
  /** The port of the local Solar Network app */
  port: number;
  /** The signed challenge returned from waitForAuth */
  signedChallenge: string;
  /** Optional APP_CONNECT secret id to scope validation */
  secretId?: string;
  /** Optional device information */
  deviceInfo?: Record<string, unknown>;
}

/**
 * Options for fetchAccountInfo
 */
export interface FetchAccountInfoOptions {
  /** The port of the local Solar Network app */
  port: number;
  /** The authentication token */
  token: string;
}
