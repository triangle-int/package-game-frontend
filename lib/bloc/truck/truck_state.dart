part of 'truck_bloc.dart';

@freezed
class TruckState with _$TruckState {
  const factory TruckState.initial() = _Initial;
  const factory TruckState.loadInProgress() = _LoadInProgress;
  const factory TruckState.loadFailure(ServerFailure failure) = _LoadFailure;
  const factory TruckState.loadSuccess(List<Truck> trucks) = _LoadSuccess;
}
