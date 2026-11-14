import 'package:flutter/foundation.dart';
import 'package:solar_network_foundation/solar_network_foundation.dart';
import 'package:passkeys/authenticator.dart';
import 'package:passkeys/types.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

/// Island's WebAuthn assertion ceremony for the shared step-up elevation sheet.
///
/// Stargate never lists the passkey in a challenge's factor picker: a passkey
/// is presented through the challenge's dedicated assertion endpoints
/// (`POST /auth/challenge/{id}/passkey/start` and `.../complete`), and one
/// assertion settles the single elevation step the challenge demanded. The
/// shared sheet therefore runs the ceremony through this seam instead of
/// growing a WebAuthn dependency every client would have to take on.
///
/// The assertion rides the app's one authenticated client, so it carries the
/// same session token the elevation is granted to.
AuthPasskeyCeremony passkeyCeremony(SolarNetworkClient client) {
  return AuthPasskeyCeremony(
    isAvailable: () async => passkeyCeremonyAvailable(),
    run: (challenge) => _assertPasskey(client, challenge),
  );
}

/// Whether this target can run a WebAuthn ceremony right now.
///
/// Desktop targets besides macOS have no passkey plugin, so the sheet must not
/// offer an action that would only fail; the platforms that do have one answer
/// with their own availability query (biometry present, browser support).
Future<bool> passkeyCeremonyAvailable() async {
  final availability = PasskeyAuthenticator().getAvailability();
  if (kIsWeb) {
    return (await availability.web()).hasPasskeySupport;
  }
  return switch (defaultTargetPlatform) {
    TargetPlatform.android => (await availability.android()).hasPasskeySupport,
    TargetPlatform.iOS ||
    TargetPlatform.macOS => (await availability.iOS()).hasPasskeySupport,
    _ => false,
  };
}

Future<SnAuthChallenge> _assertPasskey(
  SolarNetworkClient client,
  SnAuthChallenge challenge,
) async {
  final options = await client.auth.startPasskeyAuthentication(
    challengeId: challenge.id,
  );
  final authenticator = PasskeyAuthenticator(debugMode: kDebugMode);
  final credential = await authenticator.authenticate(
    AuthenticateRequestType(
      challenge: options['challenge'] as String,
      relyingPartyId: options['rp_id'] as String,
      allowCredentials:
          (options['allow_credentials'] as List<dynamic>? ?? [])
              .map(
                (e) => CredentialType(
                  type: e['type'] as String,
                  id: e['id'] as String,
                  transports: List<String>.from(
                    e['transports'] as List<dynamic>? ?? const <String>[],
                  ),
                ),
              )
              .toList(),
      userVerification: options['user_verification'] as String? ?? 'required',
      mediation: MediationType.Optional,
      preferImmediatelyAvailableCredentials: false,
    ),
  );

  return client.auth.completePasskeyAuthentication(
    challengeId: challenge.id,
    credentialId: credential.id,
    clientDataJson: credential.clientDataJSON,
    authenticatorData: credential.authenticatorData,
    signature: credential.signature,
    userHandle: credential.userHandle.isEmpty ? null : credential.userHandle,
  );
}
