part of 'doggie_express_bloc.dart';

@freezed
abstract class DoggieExpressState with _$DoggieExpressState {
  const factory DoggieExpressState({
    required Building? pointA,
    required Building? pointB,
    required int scheduleDuration,
    required int truckType,
    required String resource,
    required BigInt amount,
    required bool isLoading,
    required TruckFailure? failureOrNull,
    required CalculatedPath? path,
    required bool success,
  }) = _DoggieExpressState;

  factory DoggieExpressState.initial() => DoggieExpressState(
        pointA: null,
        pointB: null,
        scheduleDuration: -1,
        truckType: -1,
        resource: '',
        amount: BigInt.from(0),
        isLoading: false,
        failureOrNull: null,
        path: null,
        success: false,
      );
}
