import 'package:cached_network_image/cached_network_image.dart';
// ignore: implementation_imports
import 'package:flutter/src/painting/image_provider.dart';
import 'package:flutter_map/flutter_map.dart';

class CachedTileProvider extends TileProvider {
  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) {
    final url = getTileUrl(coordinates, options);
    return CachedNetworkImageProvider(
      url,
      // Blocked OSM tiles were returned as PNGs and cached as successful
      // images. Change their cache identity so those old images are bypassed.
      cacheKey: Uri.tryParse(url)?.host == 'tile.openstreetmap.org'
          ? 'osm-identified-v1:$url'
          : null,
      headers: headers,
    );
  }
}
