part of 'tutorial_bloc.dart';

@freezed
class TutorialEvent with _$TutorialEvent {
  const factory TutorialEvent.started() = _Started;
  const factory TutorialEvent.next() = _Next;
  const factory TutorialEvent.buildMenuOpened() = _BuildMenuOpened;
  const factory TutorialEvent.factoryPlace() = _FactoryPlace;
  const factory TutorialEvent.resourceSelected() = _ResourceSelected;
  const factory TutorialEvent.storagePlace() = _StoragePlace;
  const factory TutorialEvent.truckSent() = _TruckSent;
  const factory TutorialEvent.truckArrived() = _TruckArrived;
  const factory TutorialEvent.inventoryOpened() = _InventoryOpened;
  const factory TutorialEvent.businessPlace() = _BusinessPlace;
  const factory TutorialEvent.priceSet() = _PriceSet;
  const factory TutorialEvent.skip() = _Skip;
}
