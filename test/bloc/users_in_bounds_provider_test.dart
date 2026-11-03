import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:package_flutter/bloc/map/map_bounds_provider.dart';
import 'package:package_flutter/bloc/user/users_in_bounds_provider.dart';
import 'package:package_flutter/domain/user/user_on_map.dart';
import 'package:package_flutter/domain/user/user_repository.dart';

class FakeUserRepository extends Fake implements UserRepository {
  final requestedBounds = <LatLng>[];

  @override
  Future<List<UserOnMap>> getUsersInBounds({
    required LatLng minCoords,
    required LatLng maxCoords,
  }) async {
    requestedBounds.add(minCoords);
    return [];
  }
}

void main() {
  testWidgets('moving the map cancels old polling without an unhandled error',
      (tester) async {
    final repository = FakeUserRepository();
    final container = ProviderContainer(overrides: [
      userRepositoryProvider.overrideWith((ref) => repository),
    ]);
    final subscription = container.listen(usersInBoundsProvider, (_, __) {});

    await tester.pump(const Duration(milliseconds: 100));
    container.read(mapBoundsProvider.notifier).setBounds(
          LatLngBounds(const LatLng(10, 10), const LatLng(11, 11)),
        );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    container.read(mapBoundsProvider.notifier).setBounds(
          LatLngBounds(const LatLng(20, 20), const LatLng(21, 21)),
        );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 499));
    expect(repository.requestedBounds, isEmpty);
    await tester.pump(const Duration(milliseconds: 1));
    expect(repository.requestedBounds, [const LatLng(20, 20)]);
    expect(tester.takeException(), isNull);

    subscription.close();
    await tester.pump(const Duration(milliseconds: 1));
    container.dispose();
    await tester.pump(const Duration(milliseconds: 1));
    expect(tester.takeException(), isNull);
  });
}
