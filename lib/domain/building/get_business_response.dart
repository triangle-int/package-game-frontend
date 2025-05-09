import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:package_flutter/domain/building/building.dart';

part 'get_business_response.freezed.dart';
part 'get_business_response.g.dart';

@freezed
abstract class GetBusinessResponse with _$GetBusinessResponse {
  const factory GetBusinessResponse({
    required BusinessBuilding business,
    required double tax,
  }) = _GetBusinessResponse;

  factory GetBusinessResponse.fromJson(Map<String, dynamic> json) =>
      _$GetBusinessResponseFromJson(json);
}
