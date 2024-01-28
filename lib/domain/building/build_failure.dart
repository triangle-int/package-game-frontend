import 'package:freezed_annotation/freezed_annotation.dart';

part 'build_failure.freezed.dart';

@freezed
class BuildFailure with _$BuildFailure {
  const factory BuildFailure.serverFailure(String message) = _ServerFailure;
  const factory BuildFailure.unexpectedFailure(String message) =
      _UnexpectedFailure;
  const factory BuildFailure.zoneIsBusy() = _ZoneIsBusy;
  const factory BuildFailure.tooManyFactories() = _TooManyFactories;
  const factory BuildFailure.storageAlreadyExists() = _StorageAlreadyExists;
  const factory BuildFailure.notEnoughCurrency() = _NotEnoughCurrency;
}
