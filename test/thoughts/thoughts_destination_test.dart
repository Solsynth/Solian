import 'package:flutter_test/flutter_test.dart';
import 'package:island/core/navigation/conditional_bottom_nav.dart';
import 'package:island/core/navigation/tab_destinations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Thoughts is a root tab at the index the shell routes it to', () {
    final destinations = allTabDestinations;
    final thoughts = destinations.firstWhere((d) => d.id == 'thoughts');

    // `setActiveIndex` addresses the shell's stack by declaration order, so the
    // destination's index and the route's position have to agree.
    expect(destinations.indexOf(thoughts), thoughts.routeIndex);
    expect(thoughts.routePath, '/thoughts');
    expect(kTabRoutes, contains('/thoughts'));
  });

  test('Thoughts stays out of the default bars; it is opt-in there', () {
    expect(kDefaultBottomNavIds, isNot(contains('thoughts')));
  });
}
