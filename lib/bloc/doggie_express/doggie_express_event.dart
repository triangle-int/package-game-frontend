part of 'doggie_express_bloc.dart';

@freezed
sealed class DoggieExpressEvent with _$DoggieExpressEvent {
  const factory DoggieExpressEvent.truckTypeUpdated(int truckType) =
      DoggieExpressEventTruckTypeUpdated;
  const factory DoggieExpressEvent.resourceSelected(String name) =
      DoggieExpressEventResourceSelected;
  const factory DoggieExpressEvent.amountEntered(BigInt amount) =
      DoggieExpressEventAmountEntered;
  const factory DoggieExpressEvent.pointASelected(Building point) =
      DoggieExpressEventPointASelected;
  const factory DoggieExpressEvent.pointADeselected() =
      DoggieExpressEventPointADeselected;
  const factory DoggieExpressEvent.pointBSelected(Building point) =
      DoggieExpressEventPointBSelected;
  const factory DoggieExpressEvent.pointBDeselected() =
      DoggieExpressEventPointBDeselected;
  const factory DoggieExpressEvent.scheduleDurationUpdated(int duration) =
      DoggieExpressEventScheduleDurationUpdated;
  const factory DoggieExpressEvent.calculate() = DoggieExpressEventCalculate;
  const factory DoggieExpressEvent.confirm() = DoggieExpressEventConfirm;
  const factory DoggieExpressEvent.reset() = DoggieExpressEventReset;
}
