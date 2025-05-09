import 'package:freezed_annotation/freezed_annotation.dart';

part 'inventory_failure.freezed.dart';

@freezed
sealed class InventoryFailure with _$InventoryFailure {
  const factory InventoryFailure.serverFailure(String message) = _ServerFailure;
}
