part of 'tutorial_bloc.dart';

@freezed
sealed class TutorialEvent with _$TutorialEvent {
  const factory TutorialEvent.started() = TutorialEventStarted;
  const factory TutorialEvent.next() = TutorialEventNext;
  const factory TutorialEvent.buildMenuOpened() = TutorialEventBuildMenuOpened;
  const factory TutorialEvent.factoryPlace() = TutorialEventFactoryPlace;
  const factory TutorialEvent.resourceSelected() =
      TutorialEventResourceSelected;
  const factory TutorialEvent.storagePlace() = TutorialEventStoragePlace;
  const factory TutorialEvent.truckSent() = TutorialEventTruckSent;
  const factory TutorialEvent.truckArrived() = TutorialEventTruckArrived;
  const factory TutorialEvent.inventoryOpened() = TutorialEventInventoryOpened;
  const factory TutorialEvent.businessPlace() = TutorialEventBusinessPlace;
  const factory TutorialEvent.priceSet() = TutorialEventPriceSet;
  const factory TutorialEvent.skip() = TutorialEventSkip;
}
