import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:package_flutter/domain/fm_market/buy_failure.dart';
import 'package:package_flutter/domain/fm_market/fm_market_repository.dart';

part 'buy_event.dart';
part 'buy_state.dart';
part 'buy_bloc.freezed.dart';

class BuyBloc extends Bloc<BuyEvent, BuyState> {
  final FMMarketRepository _repository;

  BuyBloc(this._repository) : super(BuyState.initial()) {
    on<BuyEvent>((event, emit) async {
      await event.map(
        amountUpdated: (e) async => emit(
          state.copyWith(
            amount: e.newAmount,
            failureOrNull: null,
            success: false,
          ),
        ),
        bought: (e) async {
          emit(
            state.copyWith(
              isLoading: true,
              failureOrNull: null,
              success: false,
            ),
          );

          if (state.amount <= BigInt.from(0)) {
            emit(
              state.copyWith(
                isLoading: false,
                failureOrNull: const BuyFailure.invalidAmount(),
                success: false,
              ),
            );
            return;
          }

          final failureOrUnit = await _repository.buyTrade(
            tradeId: e.tradeId,
            resourcesCount: state.amount.toInt(),
          );

          failureOrUnit.fold(
            (f) => emit(
              state.copyWith(
                isLoading: false,
                failureOrNull: BuyFailure.serverFailure(f),
                success: false,
              ),
            ),
            (_) => emit(
              state.copyWith(
                isLoading: false,
                failureOrNull: null,
                success: true,
              ),
            ),
          );
        },
      );
    });
  }
}
