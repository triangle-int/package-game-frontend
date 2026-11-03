import 'package:flutter_test/flutter_test.dart';
import 'package:package_flutter/domain/building/building.dart';

void main() {
  test('map building payload keeps the public owner summary', () {
    final building = Building.fromJson({
      'discriminator': 'storage',
      'id': 7,
      'level': 2,
      'geohex': 'XM488541',
      'geohash': 'ucfv',
      'ownerId': 42,
      'owner': {
        'id': 42,
        'nickname': 'Builder',
        'avatar': '🧑‍🔧',
      },
    });

    expect(building, isA<StorageBuilding>());
    final storage = building as StorageBuilding;
    expect(storage.owner?.id, 42);
    expect(storage.owner?.nickname, 'Builder');
    expect(storage.owner?.avatar, '🧑‍🔧');
  });
}
