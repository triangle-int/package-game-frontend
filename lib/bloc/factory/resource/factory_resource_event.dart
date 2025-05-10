part of 'factory_resource_bloc.dart';

@freezed
sealed class FactoryResourceEvent with _$FactoryResourceEvent {
  const factory FactoryResourceEvent.resourceSelected(String resource) =
      FactoryResourceEventResourceSelected;
  const factory FactoryResourceEvent.confirmed(int factoryId) =
      FactoryResourceEventConfirmed;
}
