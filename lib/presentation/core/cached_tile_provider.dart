import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/src/painting/image_provider.dart';
import 'package:flutter_map/flutter_map.dart';

class CachedTileProvider extends TileProvider {
  @override
  ImageProvider getImage(Coords<num> coords, TileLayer options) {
    return CachedNetworkImageProvider(getTileUrl(coords, options));
  }
}
