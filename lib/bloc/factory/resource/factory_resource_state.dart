part of 'factory_resource_bloc.dart';

@freezed
abstract class FactoryResourceState with _$FactoryResourceState {
  const factory FactoryResourceState({
    required String resource,
    required bool isLoading,
    required FactoryResourceSelectFailure? failureOrNull,
    required FactoryBuilding? factoryOrNull,
  }) = _FactoryResourceState;

  factory FactoryResourceState.initial() => const FactoryResourceState(
        resource: '',
        isLoading: false,
        failureOrNull: null,
        factoryOrNull: null,
      );
}
