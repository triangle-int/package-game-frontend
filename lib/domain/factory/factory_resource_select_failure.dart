import 'package:freezed_annotation/freezed_annotation.dart';

part 'factory_resource_select_failure.freezed.dart';

@freezed
class FactoryResourceSelectFailure with _$FactoryResourceSelectFailure {
  const factory FactoryResourceSelectFailure.factoryNotFound() =
      _FactoryNotFound;
  const factory FactoryResourceSelectFailure.resourceNotSelected() =
      _ResourceNotSelected;
  const factory FactoryResourceSelectFailure.serverFailure(String message) =
      _ServerFailure;
  const factory FactoryResourceSelectFailure.unexpectedFailure(String message) =
      _UnexpectedFailure;
}
