var PasskeyAuthenticator = (function (exports) {
    'use strict';

    /******************************************************************************
    Copyright (c) Microsoft Corporation.

    Permission to use, copy, modify, and/or distribute this software for any
    purpose with or without fee is hereby granted.

    THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH
    REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY
    AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
    INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM
    LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR
    OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
    PERFORMANCE OF THIS SOFTWARE.
    ***************************************************************************** */
    /* global Reflect, Promise, SuppressedError, Symbol */


    function __classPrivateFieldGet(receiver, state, kind, f) {
        if (kind === "a" && !f) throw new TypeError("Private accessor was defined without a getter");
        if (typeof state === "function" ? receiver !== state || !f : !state.has(receiver)) throw new TypeError("Cannot read private member from an object whose class did not declare it");
        return kind === "m" ? f : kind === "a" ? f.call(receiver) : f ? f.value : state.get(receiver);
    }

    function __classPrivateFieldSet(receiver, state, value, kind, f) {
        if (kind === "m") throw new TypeError("Private method is not writable");
        if (kind === "a" && !f) throw new TypeError("Private accessor was defined without a setter");
        if (typeof state === "function" ? receiver !== state || !f : !state.has(receiver)) throw new TypeError("Cannot write private member to an object whose class did not declare it");
        return (kind === "a" ? f.call(receiver, value) : f ? f.value = value : state.set(receiver, value)), value;
    }

    typeof SuppressedError === "function" ? SuppressedError : function (error, suppressed, message) {
        var e = new Error(message);
        return e.name = "SuppressedError", e.error = error, e.suppressed = suppressed, e;
    };

    // src/webauthn-json/base64url.ts
    function base64urlToBuffer(baseurl64String) {
      const padding = "==".slice(0, (4 - baseurl64String.length % 4) % 4);
      const base64String = baseurl64String.replace(/-/g, "+").replace(/_/g, "/") + padding;
      const str = atob(base64String);
      const buffer = new ArrayBuffer(str.length);
      const byteView = new Uint8Array(buffer);
      for (let i = 0; i < str.length; i++) {
        byteView[i] = str.charCodeAt(i);
      }
      return buffer;
    }
    function bufferToBase64url(buffer) {
      const byteView = new Uint8Array(buffer);
      let str = "";
      for (const charCode of byteView) {
        str += String.fromCharCode(charCode);
      }
      const base64String = btoa(str);
      const base64urlString = base64String.replace(/\+/g, "-").replace(
        /\//g,
        "_"
      ).replace(/=/g, "");
      return base64urlString;
    }

    // src/webauthn-json/convert.ts
    var copyValue = "copy";
    var convertValue = "convert";
    function convert(conversionFn, schema2, input) {
      if (schema2 === copyValue) {
        return input;
      }
      if (schema2 === convertValue) {
        return conversionFn(input);
      }
      if (schema2 instanceof Array) {
        return input.map((v) => convert(conversionFn, schema2[0], v));
      }
      if (schema2 instanceof Object) {
        const output = {};
        for (const [key, schemaField] of Object.entries(schema2)) {
          if (schemaField.derive) {
            const v = schemaField.derive(input);
            if (v !== undefined) {
              input[key] = v;
            }
          }
          if (!(key in input)) {
            if (schemaField.required) {
              throw new Error(`Missing key: ${key}`);
            }
            continue;
          }
          if (input[key] == null) {
            output[key] = null;
            continue;
          }
          output[key] = convert(
            conversionFn,
            schemaField.schema,
            input[key]
          );
        }
        return output;
      }
    }
    function derived(schema2, derive) {
      return {
        required: true,
        schema: schema2,
        derive
      };
    }
    function required(schema2) {
      return {
        required: true,
        schema: schema2
      };
    }
    function optional(schema2) {
      return {
        required: false,
        schema: schema2
      };
    }

    // src/webauthn-json/basic/schema.ts
    var publicKeyCredentialDescriptorSchema = {
      type: required(copyValue),
      id: required(convertValue),
      transports: optional(copyValue)
    };
    var simplifiedExtensionsSchema = {
      appid: optional(copyValue),
      appidExclude: optional(copyValue),
      credProps: optional(copyValue)
    };
    var simplifiedClientExtensionResultsSchema = {
      appid: optional(copyValue),
      appidExclude: optional(copyValue),
      credProps: optional(copyValue)
    };
    var credentialCreationOptions = {
      publicKey: required({
        rp: required(copyValue),
        user: required({
          id: required(convertValue),
          name: required(copyValue),
          displayName: required(copyValue)
        }),
        challenge: required(convertValue),
        pubKeyCredParams: required(copyValue),
        timeout: optional(copyValue),
        excludeCredentials: optional([publicKeyCredentialDescriptorSchema]),
        authenticatorSelection: optional(copyValue),
        attestation: optional(copyValue),
        extensions: optional(simplifiedExtensionsSchema)
      }),
      signal: optional(copyValue)
    };
    var publicKeyCredentialWithAttestation = {
      type: required(copyValue),
      id: required(copyValue),
      rawId: required(convertValue),
      authenticatorAttachment: optional(copyValue),
      response: required({
        clientDataJSON: required(convertValue),
        attestationObject: required(convertValue),
        transports: derived(
          copyValue,
          (response) => {
            var _a;
            return ((_a = response.getTransports) == null ? undefined : _a.call(response)) || [];
          }
        )
      }),
      clientExtensionResults: derived(
        simplifiedClientExtensionResultsSchema,
        (pkc) => pkc.getClientExtensionResults()
      )
    };
    var credentialRequestOptions = {
      mediation: optional(copyValue),
      publicKey: required({
        challenge: required(convertValue),
        timeout: optional(copyValue),
        rpId: optional(copyValue),
        allowCredentials: optional([publicKeyCredentialDescriptorSchema]),
        userVerification: optional(copyValue),
        extensions: optional(simplifiedExtensionsSchema)
      }),
      signal: optional(copyValue)
    };
    var publicKeyCredentialWithAssertion = {
      type: required(copyValue),
      id: required(copyValue),
      rawId: required(convertValue),
      authenticatorAttachment: optional(copyValue),
      response: required({
        clientDataJSON: required(convertValue),
        authenticatorData: required(convertValue),
        signature: required(convertValue),
        userHandle: required(convertValue)
      }),
      clientExtensionResults: derived(
        simplifiedClientExtensionResultsSchema,
        (pkc) => pkc.getClientExtensionResults()
      )
    };

    // src/webauthn-json/basic/api.ts
    function createRequestFromJSON(requestJSON) {
      return convert(base64urlToBuffer, credentialCreationOptions, requestJSON);
    }
    function createResponseToJSON(credential) {
      return convert(
        bufferToBase64url,
        publicKeyCredentialWithAttestation,
        credential
      );
    }
    async function create(requestJSON) {
      const credential = await navigator.credentials.create(
        createRequestFromJSON(requestJSON)
      );
      return createResponseToJSON(credential);
    }
    function getRequestFromJSON(requestJSON) {
      return convert(base64urlToBuffer, credentialRequestOptions, requestJSON);
    }
    function getResponseToJSON(credential) {
      return convert(
        bufferToBase64url,
        publicKeyCredentialWithAssertion,
        credential
      );
    }
    async function get(requestJSON) {
      const credential = await navigator.credentials.get(
        getRequestFromJSON(requestJSON)
      );
      return getResponseToJSON(credential);
    }

    var _PasskeyAuthenticator_abortController;
    const ABORTED_BY_USER = 'operation aborted by user.';
    class PasskeyAuthenticator {
        constructor() {
            _PasskeyAuthenticator_abortController.set(this, undefined);
        }
        async register(params) {
            try {
                const typedParams = JSON.parse(params);
                const out = await create(typedParams);
                return JSON.stringify(out);
            }
            catch (e) {
                let error;
                if (e instanceof DOMException) {
                    error = PlatformError.fromDOMException(e);
                }
                else if (e instanceof String) {
                    error = PlatformError.unknownError(e.toString());
                }
                else {
                    error = PlatformError.unknownError('-');
                }
                const serializedError = JSON.stringify(error);
                console.log(serializedError);
                return Promise.reject(serializedError);
            }
        }
        async login(params) {
            try {
                __classPrivateFieldSet(this, _PasskeyAuthenticator_abortController, new AbortController(), "f");
                const typedParams = JSON.parse(params);
                typedParams.signal = __classPrivateFieldGet(this, _PasskeyAuthenticator_abortController, "f").signal;
                const out = await get(typedParams);
                return JSON.stringify(out);
            }
            catch (e) {
                let error;
                if (e instanceof DOMException) {
                    error = PlatformError.fromDOMException(e);
                }
                else if (e instanceof String) {
                    error = PlatformError.unknownError(e.toString());
                }
                else if (e === ABORTED_BY_USER) {
                    error = PlatformError.cancelled();
                }
                else {
                    error = PlatformError.unknownError('-');
                }
                const serializedError = JSON.stringify(error);
                return Promise.reject(serializedError);
            }
        }
        abortCurrentWebAuthnOperation() {
            if (!__classPrivateFieldGet(this, _PasskeyAuthenticator_abortController, "f")) {
                return;
            }
            __classPrivateFieldGet(this, _PasskeyAuthenticator_abortController, "f").abort(ABORTED_BY_USER);
        }
    }
    _PasskeyAuthenticator_abortController = new WeakMap();
    class PlatformError {
        constructor(code, message, details) {
            this.code = code;
            this.message = message;
            this.details = details;
        }
        static fromDOMException(error) {
            switch (error.name) {
                case 'NotAllowedError':
                    return PlatformError.cancelled();
                default:
                    return new PlatformError(error.name, error.message, '');
            }
        }
        static unknownError(error) {
            return new PlatformError('unknown', error, '');
        }
        static cancelled() {
            return new PlatformError('cancelled', 'operation was cancelled by the user.', '');
        }
    }

    let passkeyAuthenticator = new PasskeyAuthenticator();
    async function isUserVerifyingPlatformAuthenticatorAvailable() {
        if (!window.PublicKeyCredential) {
            return undefined;
        }
        try {
            return await window.PublicKeyCredential.isUserVerifyingPlatformAuthenticatorAvailable();
        }
        catch (e) {
            return undefined;
        }
    }
    async function isConditionalMediationAvailable() {
        if (!window.PublicKeyCredential) {
            return undefined;
        }
        try {
            return await window.PublicKeyCredential.isConditionalMediationAvailable();
        }
        catch (e) {
            return undefined;
        }
    }
    function hasPasskeySupport() {
        return Boolean(window.PublicKeyCredential);
    }
    function init() {
        passkeyAuthenticator = new PasskeyAuthenticator();
    }
    function register(params) {
        return passkeyAuthenticator.register(params);
    }
    function login(params) {
        return passkeyAuthenticator.login(params);
    }
    function cancelCurrentAuthenticatorOperation() {
        passkeyAuthenticator.abortCurrentWebAuthnOperation();
    }

    exports.cancelCurrentAuthenticatorOperation = cancelCurrentAuthenticatorOperation;
    exports.hasPasskeySupport = hasPasskeySupport;
    exports.init = init;
    exports.isConditionalMediationAvailable = isConditionalMediationAvailable;
    exports.isUserVerifyingPlatformAuthenticatorAvailable = isUserVerifyingPlatformAuthenticatorAvailable;
    exports.login = login;
    exports.register = register;

    return exports;

})({});
