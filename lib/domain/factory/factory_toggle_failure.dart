import 'package:freezed_annotation/freezed_annotation.dart';

part 'factory_toggle_failure.freezed.dart';

@freezed
class FactoryToggleFailure with _$FactoryToggleFailure {
  const factory FactoryToggleFailure.serverFailure(String message) =
      _ServerFailure;
  const factory FactoryToggleFailure.unexpectedFailure(String message) =
      _UnexpectedFailure;
  const factory FactoryToggleFailure.factoryNotFound() = _FactoryNotFound;
  const factory FactoryToggleFailure.factoryAlreadyToggled() =
      _FactoryAlreadyToggled;
  const factory FactoryToggleFailure.notEnoughMoney() = _NotEnoughMoney;
}
