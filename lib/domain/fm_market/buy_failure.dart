import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:package_flutter/domain/core/server_failure.dart';

part 'buy_failure.freezed.dart';

@freezed
class BuyFailure with _$BuyFailure {
  const factory BuyFailure.invalidAmount() = _InvalidAmount;
  const factory BuyFailure.serverFailure(ServerFailure failure) =
      _ServerFailure;
}
