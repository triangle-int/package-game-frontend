import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_flutter/presentation/core/cached_tile_provider.dart';

void main() {
  test('map tiles carry the application identity into HTTP requests', () {
    final provider = CachedTileProvider();
    final layer = TileLayer(
      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      userAgentPackageName: 'com.TriangleInteractive.Package',
      tileProvider: provider,
    );

    final image = provider.getImage(const TileCoordinates(1, 2, 3), layer)
        as CachedNetworkImageProvider;

    expect(image.url, 'https://tile.openstreetmap.org/3/1/2.png');
    expect(image.cacheKey,
        'osm-identified-v1:https://tile.openstreetmap.org/3/1/2.png');
    expect(image.headers?['User-Agent'],
        'flutter_map (com.TriangleInteractive.Package)');
  });
}
