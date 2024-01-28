part of 'doggie_express_bloc.dart';

@freezed
class DoggieExpressEvent with _$DoggieExpressEvent {
  const factory DoggieExpressEvent.truckTypeUpdated(int truckType) =
      _TruckTypeUpdated;
  const factory DoggieExpressEvent.resourceSelected(String name) =
      _ResourceSelected;
  const factory DoggieExpressEvent.amountEntered(BigInt amount) =
      _AmountEntered;
  const factory DoggieExpressEvent.pointASelected(Building point) =
      _PointASelected;
  const factory DoggieExpressEvent.pointADeselected() = _PointADeselected;
  const factory DoggieExpressEvent.pointBSelected(Building point) =
      _PointBSelected;
  const factory DoggieExpressEvent.pointBDeselected() = _PointBDeselected;
  const factory DoggieExpressEvent.scheduleDurationUpdated(int duration) =
      _ScheduleDurationUpdated;
  const factory DoggieExpressEvent.calculate() = _Calculate;
  const factory DoggieExpressEvent.confirm() = _Confirm;
  const factory DoggieExpressEvent.reset() = _Reset;
}
