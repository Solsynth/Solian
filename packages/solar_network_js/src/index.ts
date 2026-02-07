/**
 * Solar Network Web Authentication Client
 * 
 * This module provides a JavaScript/TypeScript client for authenticating
 * with the Solar Network desktop app via local HTTP server.
 */

export { WebAuthClient } from './client';
export type {
  WebAuthStatus,
  WebAuthResult,
  WebAuthConfig,
  WaitForAuthOptions,
  ExchangeTokenOptions,
  FetchAccountInfoOptions,
} from './types';
