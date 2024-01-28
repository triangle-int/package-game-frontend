import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:logger/logger.dart';
import 'package:package_flutter/domain/building/building.dart';
import 'package:package_flutter/domain/building/building_repository.dart';
import 'package:package_flutter/domain/core/server_failure.dart';

part 'market_event.dart';
part 'market_state.dart';
part 'market_bloc.freezed.dart';

class MarketBloc extends Bloc<MarketEvent, MarketState> {
  final BuildingRepository _buildingRepository;

  MarketBloc(this._buildingRepository) : super(const MarketState.initial()) {
    on<MarketEvent>((event, emit) async {
      await event.map(
        marketRequested: (e) async {
          emit(const MarketState.loadInProgress());
          final marketOrFailure =
              await _buildingRepository.getMarket(marketId: e.marketId);
          Logger().d(marketOrFailure);
          emit(
            marketOrFailure.fold(
              (f) => MarketState.loadFailure(f),
              (market) => MarketState.loadSuccess(market),
            ),
          );
        },
      );
    });
  }
}
