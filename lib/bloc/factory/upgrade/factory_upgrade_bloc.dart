import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:package_flutter/domain/building/building.dart';
import 'package:package_flutter/domain/core/server_failure.dart';
import 'package:package_flutter/domain/factory/factory_repository.dart';

part 'factory_upgrade_event.dart';
part 'factory_upgrade_state.dart';
part 'factory_upgrade_bloc.freezed.dart';

class FactoryUpgradeBloc
    extends Bloc<FactoryUpgradeEvent, FactoryUpgradeState> {
  final FactoryRepository _factoryRepository;

  FactoryUpgradeBloc(this._factoryRepository)
      : super(const FactoryUpgradeState.initial()) {
    on<FactoryUpgradeEvent>((event, emit) async {
      await event.map(
        factoryUpgraded: (e) async {
          emit(const FactoryUpgradeState.loadInProgress());
          final buildingOrFailure =
              await _factoryRepository.upgradeFactory(e.factoryBuilding.id);
          buildingOrFailure.fold(
            (f) => emit(FactoryUpgradeState.loadFailure(f)),
            (building) => emit(FactoryUpgradeState.loadSuccess(building)),
          );
        },
      );
    });
  }
}
