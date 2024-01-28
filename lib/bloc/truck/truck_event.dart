part of 'truck_bloc.dart';

@freezed
class TruckEvent with _$TruckEvent {
  const factory TruckEvent.listenTrucksRequested() = _ListenTrucksRequested;
  const factory TruckEvent.trucksReceived(
    Either<ServerFailure, List<Truck>> trucksOrFailure,
  ) = _TrucksReceived;
  const factory TruckEvent.truckArrived(Truck truck) = _TruckArrived;
}
