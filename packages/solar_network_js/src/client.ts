/**
 * Solar Network Web Authentication Client
 * 
 * This client enables JavaScript/TypeScript applications to authenticate
 * with the Solar Network desktop app via a local HTTP server.
 * 
 * Usage:
 * ```typescript
 * import { WebAuthClient } from '@solarnetwork/js-auth';
 * 
 * const client = new WebAuthClient();
 * 
 * // Request authentication
 * const result = await client.waitForAuth({
 *   port: 40000,
 *   appName: 'MyApp',
 * });
 * 
 * if (result.status === 'challenge') {
 *   // Sign the challenge (implement your signing logic)
 *   const signedChallenge = await signChallenge(result.challenge);
 *   
 *   // Exchange for token
 *   const tokenResult = await client.exchangeToken({
 *     port: 40000,
 *     signedChallenge,
 *   });
 *   
 *   if (tokenResult.status === 'success') {
 *     console.log('Token:', tokenResult.token);
 *   }
 * }
 * ```
 */

import { WebAuthStatus } from './types';
import type {
  WebAuthResult,
  WebAuthConfig,
  WaitForAuthOptions,
  ExchangeTokenOptions,
  FetchAccountInfoOptions,
} from './types';

/**
 * Default configuration values
 */
const DEFAULT_CONFIG: Required<WebAuthConfig> = {
  baseUrl: 'http://127.0.0.1',
  defaultPort: 40000,
  webUrl: 'https://app.solian.fr',
};

/**
 * Web Authentication Client for Solar Network
 * 
 * Connects to the Solar Network desktop app's local authentication server
 * to perform secure authentication without requiring users to re-enter credentials.
 */
export class WebAuthClient {
  private config: Required<WebAuthConfig>;

  /**
   * Create a new WebAuthClient
   * @param config - Optional configuration
   */
  constructor(config?: WebAuthConfig) {
    this.config = {
      baseUrl: config?.baseUrl ?? DEFAULT_CONFIG.baseUrl,
      defaultPort: config?.defaultPort ?? DEFAULT_CONFIG.defaultPort,
      webUrl: config?.webUrl ?? DEFAULT_CONFIG.webUrl,
    };
  }

  /**
   * Get the authentication URL to open in a browser
   * 
   * This URL redirects the user to the Solar Network web app for additional
   * authentication if needed.
   * 
   * @param port - The port of the local server
   * @returns The authentication URL
   */
  getAuthenticationUrl(port?: number): string {
    const portNumber = port ?? this.config.defaultPort;
    return `${this.config.webUrl}/auth/web?port=${portNumber}`;
  }

  /**
   * Wait for user to respond to authentication request
   * 
   * This method opens a long-polling connection to the local Solar Network app.
   * It will wait until the user either allows or denies the authentication request.
   * 
   * The connection remains open while the user decides. This method will return:
   * - `{ status: 'challenge', challenge: '...' }` if the user allows
   * - `{ status: 'denied' }` if the user denies
   * - `{ status: 'error', error: '...' }` if something goes wrong
   * 
   * @param options - Options including port and app name
   * @returns The authentication result
   */
  async waitForAuth(options: WaitForAuthOptions): Promise<WebAuthResult> {
    const { port, appName } = options;
    const url = `${this.config.baseUrl}:${port}/alive?app=${encodeURIComponent(appName)}`;

    try {
      const response = await fetch(url);

      if (!response.ok) {
        throw new Error(`HTTP ${response.status}: ${response.statusText}`);
      }

      const data = await response.json() as Record<string, unknown>;
      const status = data.status as string;

      if (status === 'denied') {
        return {
          status: WebAuthStatus.denied,
        };
      }

      if (status === 'ok' && typeof data.challenge === 'string') {
        return {
          status: WebAuthStatus.challenge,
          challenge: data.challenge,
        };
      }

      return {
        status: WebAuthStatus.error,
        error: data.error as string ?? 'Unknown response from server',
      };
    } catch (error) {
      return {
        status: WebAuthStatus.error,
        error: error instanceof Error ? error.message : String(error),
      };
    }
  }

  /**
   * Exchange a signed challenge for an authentication token
   * 
   * After the user allows authentication and you've signed the challenge,
   * call this method to exchange it for a session token.
   * 
   * @param options - Options including port, signed challenge, and optional device info
   * @returns The token result
   */
  async exchangeToken(options: ExchangeTokenOptions): Promise<WebAuthResult> {
    const { port, signedChallenge, deviceInfo } = options;
    const url = `${this.config.baseUrl}:${port}/exchange`;

    try {
      const response = await fetch(url, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          signed_challenge: signedChallenge,
          ...(deviceInfo ?? {}),
        }),
      });

      if (!response.ok) {
        const errorData = await response.json().catch(() => ({}));
        return {
          status: WebAuthStatus.error,
          error: (errorData as Record<string, unknown>).error as string 
            ?? `HTTP ${response.status}: ${response.statusText}`,
        };
      }

      const data = await response.json() as Record<string, unknown>;

      if (typeof data.token === 'string') {
        return {
          status: WebAuthStatus.success,
          token: data.token,
        };
      }

      return {
        status: WebAuthStatus.error,
        error: 'No token in response',
      };
    } catch (error) {
      return {
        status: WebAuthStatus.error,
        error: error instanceof Error ? error.message : String(error),
      };
    }
  }

  /**
   * Fetch account information using an auth token
   * 
   * This endpoint proxies through the local Solar Network app to fetch
   * the authenticated user's account info.
   * 
   * @param options - Options including port and token
   * @returns The account info response
   */
  async fetchAccountInfo<T = Record<string, unknown>>(
    options: FetchAccountInfoOptions
  ): Promise<{ success: boolean; data?: T; error?: string }> {
    const { port, token } = options;
    const url = `${this.config.baseUrl}:${port}/me`;

    try {
      const response = await fetch(url, {
        headers: {
          'Authorization': `Bearer ${token}`,
        },
      });

      if (!response.ok) {
        const errorData = await response.json().catch(() => ({}));
        return {
          success: false,
          error: (errorData as Record<string, unknown>).error as string
            ?? `HTTP ${response.status}: ${response.statusText}`,
        };
      }

      const data = await response.json() as T;
      return {
        success: true,
        data,
      };
    } catch (error) {
      return {
        success: false,
        error: error instanceof Error ? error.message : String(error),
      };
    }
  }

  /**
   * Full authentication flow helper
   * 
   * This convenience method combines waitForAuth, challenge signing (via callback),
   * and exchangeToken into a single call.
   * 
   * @param options - Authentication options including port, app name, and signing callback
   * @returns The token result
   */
  async authenticate(
    options: WaitForAuthOptions & {
      /** Callback to sign the challenge - implement your signing logic here */
      signChallenge: (challenge: string) => Promise<string> | string;
    }
  ): Promise<WebAuthResult> {
    // Step 1: Wait for user to respond
    const authResult = await this.waitForAuth(options);

    if (authResult.status !== WebAuthStatus.challenge) {
      return authResult;
    }

    // Step 2: Sign the challenge
    let signedChallenge: string;
    try {
      signedChallenge = await options.signChallenge(authResult.challenge!);
    } catch (error) {
      return {
        status: WebAuthStatus.error,
        error: `Failed to sign challenge: ${error instanceof Error ? error.message : String(error)}`,
      };
    }

    // Step 3: Exchange for token
    return this.exchangeToken({
      port: options.port,
      signedChallenge,
    });
  }
}
