import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:package_flutter/domain/core/server_failure.dart';

part 'buy_failure.freezed.dart';

@freezed
sealed class BuyFailure with _$BuyFailure {
  const factory BuyFailure.invalidAmount() = BuyFailureInvalidAmount;
  const factory BuyFailure.serverFailure(ServerFailure failure) =
      BuyFailureServerFailure;
}
