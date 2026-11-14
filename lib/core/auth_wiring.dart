import 'package:solar_network_foundation/solar_network_foundation.dart';

import 'package:island/core/network.dart';
import 'package:island/core/passkey_ceremony.dart';
import 'package:island/shared/widgets/alert.dart';

/// Binds the shared elevation flow (`solar_network_foundation`) to Island's
/// client and alert surface.
///
/// The sudo sheet never reaches into app state directly; everything it needs
/// from the host flows through these overrides.
///
/// The return type is inferred because Riverpod keeps `Override` out of its
/// public API surface, so it cannot be named here.
// ignore: strict_top_level_inference
authHostOverrides() {
  return [
    authClientProvider.overrideWith(
      (ref) => ref.watch(solarNetworkClientProvider),
    ),
    authErrorReporterProvider.overrideWithValue(showErrorAlert),
    // The elevation sheet never lists a passkey as a pickable factor: Stargate
    // settles it through the challenge's own assertion endpoints, so the host
    // runs that ceremony here.
    authPasskeyCeremonyProvider.overrideWith(
      (ref) => passkeyCeremony(ref.watch(solarNetworkClientProvider)),
    ),
  ];
}
