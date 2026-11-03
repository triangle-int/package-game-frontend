import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:package_flutter/domain/building/building.dart';
import 'package:package_flutter/domain/building/building_repository.dart';
import 'package:package_flutter/domain/config/config.dart';
import 'package:package_flutter/domain/config/item.dart';
import 'package:package_flutter/domain/core/server_failure.dart';
import 'package:package_flutter/domain/factory/factory_repository.dart';
import 'package:package_flutter/domain/inventory/inventory_item.dart';

part 'amount_and_product_event.dart';
part 'amount_and_product_state.dart';
part 'amount_and_product_bloc.freezed.dart';

class AmountAndProductBloc
    extends Bloc<AmountAndProductEvent, AmountAndProductState> {
  final BuildingRepository _buildingRepository;
  final FactoryRepository _factoryRepository;
  int _request = 0;

  AmountAndProductBloc(this._buildingRepository, this._factoryRepository)
      : super(const AmountAndProductState.initial()) {
    on<AmountAndProductEvent>((event, emit) async {
      final request = ++_request;
      switch (event) {
        case AmountAndProductEventInitialOpened():
          emit(const AmountAndProductState.initial());
        case AmountAndProductEventProductOpened(
            :final pointA,
            :final pointB,
            :final config
          ):
          emit(const AmountAndProductState.loadInProgress());

          switch (pointA) {
            case BusinessBuilding():
              emit(const AmountAndProductState.productSelectionSuccess([]));
            case SatelliteBuilding():
              emit(const AmountAndProductState.productSelectionSuccess([]));
            case StorageBuilding(:final id):
              final buildingOrFailure =
                  await _buildingRepository.getStorage(storageId: id);
              if (request != _request) return;
              return buildingOrFailure.fold(
                (f) => emit(AmountAndProductState.productSelectionFailure(f)),
                (building) => emit(
                  AmountAndProductState.productSelectionSuccess(
                    buildingItems(building, pointB, config),
                  ),
                ),
              );
            case FactoryBuilding(:final id):
              final buildingOrFailure =
                  await _factoryRepository.getFactory(factoryId: id);
              if (request != _request) return;
              buildingOrFailure.fold(
                (f) => emit(AmountAndProductState.productSelectionFailure(f)),
                (building) => emit(
                  AmountAndProductState.productSelectionSuccess(
                    buildingItems(building, pointB, config),
                  ),
                ),
              );
            case MarketBuilding(:final id):
              final buildingOrFailure =
                  await _buildingRepository.getMarket(marketId: id);
              if (request != _request) return;
              buildingOrFailure.fold(
                (f) => emit(AmountAndProductState.productSelectionFailure(f)),
                (building) => emit(
                  AmountAndProductState.productSelectionSuccess(
                    buildingItems(building, pointB, config),
                  ),
                ),
              );
          }
        case AmountAndProductEventAmountOpened(:final pointA, :final itemName):
          emit(const AmountAndProductState.loadInProgress());

          switch (pointA) {
            case BusinessBuilding():
              emit(
                const AmountAndProductState.amountSelectionFailure(
                  ServerFailure.buildingNotFound(),
                ),
              );
            case SatelliteBuilding():
              emit(
                const AmountAndProductState.amountSelectionFailure(
                  ServerFailure.buildingNotFound(),
                ),
              );
            case StorageBuilding(:final id):
              final buildingOrFailure =
                  await _buildingRepository.getStorage(storageId: id);
              if (request != _request) return;
              buildingOrFailure.fold(
                (f) => emit(AmountAndProductState.amountSelectionFailure(f)),
                (b) => emit(
                  AmountAndProductState.amountSelectionSuccess(
                    _availableAmount(b.inventory, itemName),
                  ),
                ),
              );
            case FactoryBuilding(:final id):
              final buildingOrFailure =
                  await _factoryRepository.getFactory(factoryId: id);
              if (request != _request) return;
              buildingOrFailure.fold(
                (f) => emit(AmountAndProductState.amountSelectionFailure(f)),
                (b) => emit(
                  AmountAndProductState.amountSelectionSuccess(
                    _availableAmount(b.inventory, itemName),
                  ),
                ),
              );
            case MarketBuilding(:final id):
              final buildingOrFailure =
                  await _buildingRepository.getMarket(marketId: id);
              if (request != _request) return;
              buildingOrFailure.fold(
                (f) => emit(AmountAndProductState.amountSelectionFailure(f)),
                (b) => emit(
                  AmountAndProductState.amountSelectionSuccess(
                    _availableAmount(b.inventory, itemName),
                  ),
                ),
              );
          }
      }
    });
  }

  BigInt _availableAmount(List<InventoryItem>? inventory, String name) {
    final items = (inventory ?? <InventoryItem>[]).where((i) => i.name == name);
    return items.isEmpty ? BigInt.zero : items.first.count;
  }

  List<Item> buildingItems(Building pointA, Building pointB, Config config) {
    final inventory = switch (pointA) {
      BusinessBuilding() => <InventoryItem>[],
      SatelliteBuilding() => <InventoryItem>[],
      StorageBuilding(:final inventory) => inventory ?? <InventoryItem>[],
      FactoryBuilding(:final inventory) => inventory ?? <InventoryItem>[],
      MarketBuilding(:final inventory) => inventory ?? <InventoryItem>[],
    };

    final whitelistItems = switch (pointB) {
      BusinessBuilding() => <ItemResource>[],
      SatelliteBuilding() => <ItemResource>[],
      StorageBuilding() => config.items.whereType<ItemResource>(),
      FactoryBuilding() => <ItemResource>[],
      MarketBuilding(:final level) =>
        config.items.whereType<ItemResource>().where((e) => e.group == level),
    };

    final availableNames = inventory
        .where((item) => item.count > BigInt.zero)
        .map((item) => item.name)
        .toSet();
    final result = whitelistItems
        .where((item) => availableNames.contains(item.name))
        .toList();

    return result;
  }
}
