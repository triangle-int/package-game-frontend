import 'package:latlong2/latlong.dart';

class MapCurrencyChange {
  const MapCurrencyChange({
    required this.id,
    required this.location,
    required this.amount,
  });

  final int id;
  final LatLng location;
  final BigInt amount;
}
