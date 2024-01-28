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

  AmountAndProductBloc(this._buildingRepository, this._factoryRepository)
      : super(const AmountAndProductState.initial()) {
    on<AmountAndProductEvent>((event, emit) async {
      await event.map(
        initialOpened: (_) async => emit(const AmountAndProductState.initial()),
        productOpened: (e) async {
          emit(const AmountAndProductState.loadInProgress());

          await e.pointA.map(
            business: (_) async =>
                emit(const AmountAndProductState.productSelectionSuccess([])),
            satellite: (_) async =>
                emit(const AmountAndProductState.productSelectionSuccess([])),
            storage: (b) async {
              final buildingOrFailure =
                  await _buildingRepository.getStorage(storageId: b.id);
              return buildingOrFailure.fold(
                (f) => emit(AmountAndProductState.productSelectionFailure(f)),
                (building) => emit(
                  AmountAndProductState.productSelectionSuccess(
                    buildingItems(building, e.pointB, e.config),
                  ),
                ),
              );
            },
            factory: (b) async {
              final buildingOrFailure =
                  await _factoryRepository.getFactory(factoryId: b.id);
              buildingOrFailure.fold(
                (f) => emit(AmountAndProductState.productSelectionFailure(f)),
                (building) => emit(
                  AmountAndProductState.productSelectionSuccess(
                    buildingItems(building, e.pointB, e.config),
                  ),
                ),
              );
            },
            market: (b) async {
              final buildingOrFailure =
                  await _buildingRepository.getMarket(marketId: b.id);
              buildingOrFailure.fold(
                (f) => emit(AmountAndProductState.productSelectionFailure(f)),
                (building) => emit(
                  AmountAndProductState.productSelectionSuccess(
                    buildingItems(building, e.pointB, e.config),
                  ),
                ),
              );
            },
          );
        },
        amountOpened: (e) async {
          emit(const AmountAndProductState.loadInProgress());

          await e.pointA.map(
            business: (_) async => emit(
              const AmountAndProductState.amountSelectionFailure(
                ServerFailure.buildingNotFound(),
              ),
            ),
            satellite: (_) async => emit(
              const AmountAndProductState.amountSelectionFailure(
                ServerFailure.buildingNotFound(),
              ),
            ),
            storage: (b) async {
              final buildingOrFailure =
                  await _buildingRepository.getStorage(storageId: b.id);
              buildingOrFailure.fold(
                (f) => emit(AmountAndProductState.amountSelectionFailure(f)),
                (b) => emit(
                  AmountAndProductState.amountSelectionSuccess(
                    b.inventory!.firstWhere((i) => i.name == e.itemName).count,
                  ),
                ),
              );
            },
            factory: (b) async {
              final buildingOrFailure =
                  await _factoryRepository.getFactory(factoryId: b.id);
              buildingOrFailure.fold(
                (f) => emit(AmountAndProductState.amountSelectionFailure(f)),
                (b) => emit(
                  AmountAndProductState.amountSelectionSuccess(
                    b.inventory!.firstWhere((i) => i.name == e.itemName).count,
                  ),
                ),
              );
            },
            market: (b) async {
              final buildingOrFailure =
                  await _buildingRepository.getMarket(marketId: b.id);
              buildingOrFailure.fold(
                (f) => emit(AmountAndProductState.amountSelectionFailure(f)),
                (b) => emit(
                  AmountAndProductState.amountSelectionSuccess(
                    b.inventory!.firstWhere((i) => i.name == e.itemName).count,
                  ),
                ),
              );
            },
          );
        },
      );
    });
  }

  List<Item> buildingItems(Building pointA, Building pointB, Config config) {
    final inventory = pointA.map(
      business: (_) => <InventoryItem>[],
      satellite: (_) => <InventoryItem>[],
      storage: (b) => b.inventory!,
      factory: (b) => b.inventory!,
      market: (b) => b.inventory!,
    );

    final whitelistItems = pointB
        .map(
          business: (_) => <ItemResource>[],
          storage: (_) => config.items.whereType<ItemResource>(),
          factory: (_) => <ItemResource>[],
          market: (b) => config.items
              .whereType<ItemResource>()
              .where((e) => e.group == b.level),
          satellite: (_) => <ItemResource>[],
        )
        .toList();

    final result = inventory
        .map((i) => config.items.firstWhere((i2) => i2.name == i.name))
        .where((i) => whitelistItems.any((i2) => i.name == i2.name))
        .toList();

    return result;
  }
}
