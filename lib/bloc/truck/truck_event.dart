part of 'truck_bloc.dart';

@freezed
sealed class TruckEvent with _$TruckEvent {
  const factory TruckEvent.listenTrucksRequested() =
      TruckEventListenTrucksRequested;
  const factory TruckEvent.trucksReceived(
    Either<ServerFailure, List<Truck>> trucksOrFailure,
  ) = TruckEventTrucksReceived;
  const factory TruckEvent.truckArrived(Truck truck) = TruckEventTruckArrived;
}
