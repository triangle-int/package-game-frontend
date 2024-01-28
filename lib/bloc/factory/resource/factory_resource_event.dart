part of 'factory_resource_bloc.dart';

@freezed
class FactoryResourceEvent with _$FactoryResourceEvent {
  const factory FactoryResourceEvent.resourceSelected(String resource) =
      _ResourceSelected;
  const factory FactoryResourceEvent.confirmed(int factoryId) = _Confirmed;
}
