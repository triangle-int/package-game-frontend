part of 'truck_bloc.dart';

@freezed
sealed class TruckState with _$TruckState {
  const factory TruckState.initial() = TruckStateInitial;
  const factory TruckState.loadInProgress() = TruckStateLoadInProgress;
  const factory TruckState.loadFailure(ServerFailure failure) =
      TruckStateLoadFailure;
  const factory TruckState.loadSuccess(List<Truck> trucks) =
      TruckStateLoadSuccess;
}
