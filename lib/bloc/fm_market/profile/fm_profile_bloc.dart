import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:package_flutter/domain/core/server_failure.dart';
import 'package:package_flutter/domain/fm_market/fm_market_repository.dart';
import 'package:package_flutter/domain/fm_market/my_trade.dart';

part 'fm_profile_event.dart';
part 'fm_profile_state.dart';
part 'fm_profile_bloc.freezed.dart';

class FmProfileBloc extends Bloc<FmProfileEvent, FmProfileState> {
  final FmMarketRepository _repository;

  FmProfileBloc(this._repository) : super(FmProfileState.initial()) {
    on<FmProfileEvent>((event, emit) async {
      switch (event) {
        case FmProfileEventFetchTradesRequested():
          emit(state.copyWith(isLoading: true, failureOrNull: null));

          final failureOrTrades = await _repository.myTrades();

          emit(
            failureOrTrades.fold(
              (f) => state.copyWith(
                failureOrNull: f,
                trades: [],
                isLoading: false,
              ),
              (trades) => state.copyWith(
                failureOrNull: null,
                trades: trades,
                isLoading: false,
              ),
            ),
          );
        case FmProfileEventPriceChanged(:final tradeId, :final newPrice):
          emit(state.copyWith(isPriceLoading: true, failureOrNull: null));

          final failureOrUnit = await _repository.setPrice(
            tradeId: tradeId,
            price: newPrice,
          );
          final failureOrTrades = await _repository.myTrades();

          emit(
            failureOrUnit.fold(
              (f) => state.copyWith(
                failureOrNull: f,
                isPriceLoading: false,
              ),
              (_) => failureOrTrades.fold(
                (f) => state.copyWith(
                  failureOrNull: f,
                  isPriceLoading: false,
                ),
                (trades) => state.copyWith(
                  failureOrNull: null,
                  isPriceLoading: false,
                  trades: trades,
                ),
              ),
            ),
          );
      }
    });
  }
}
