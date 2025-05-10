import 'package:freezed_annotation/freezed_annotation.dart';

part 'factory_resource_select_failure.freezed.dart';

@freezed
sealed class FactoryResourceSelectFailure with _$FactoryResourceSelectFailure {
  const factory FactoryResourceSelectFailure.factoryNotFound() =
      FactoryResourceSelectFailureFactoryNotFound;
  const factory FactoryResourceSelectFailure.resourceNotSelected() =
      FactoryResourceSelectFailureResourceNotSelected;
  const factory FactoryResourceSelectFailure.serverFailure(String message) =
      FactoryResourceSelectFailureServerFailure;
  const factory FactoryResourceSelectFailure.unexpectedFailure(String message) =
      FactoryResourceSelectFailureUnexpectedFailure;
}
