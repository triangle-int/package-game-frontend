import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:logger/logger.dart';
import 'package:package_flutter/domain/core/server_failure.dart';
import 'package:package_flutter/domain/fm_market/fm_market_repository.dart';
import 'package:package_flutter/domain/fm_market/trade_item.dart';

part 'fm_search_event.dart';
part 'fm_search_state.dart';
part 'fm_search_bloc.freezed.dart';

class FmSearchBloc extends Bloc<FmSearchEvent, FmSearchState> {
  final FmMarketRepository _fmMarketRepository;

  FmSearchBloc(this._fmMarketRepository) : super(FmSearchState.initial()) {
    on<FmSearchEvent>((event, emit) async {
      await event.map(
        openSearch: (e) async {
          emit(state.copyWith(isSearchOpen: true, failureOrNull: null));
        },
        closeSearch: (e) async {
          emit(state.copyWith(isSearchOpen: false, failureOrNull: null));
        },
        nicknameChanged: (e) async {
          emit(state.copyWith(nickname: e.nickname, failureOrNull: null));
        },
        addFilter: (e) async {
          final filters = List<String>.from(state.filters)..add(e.resourceName);
          emit(state.copyWith(filters: filters, failureOrNull: null));
        },
        removeFilter: (e) async {
          final filters = List<String>.from(state.filters)
            ..remove(e.resourceName);
          emit(state.copyWith(filters: filters, failureOrNull: null));
        },
        clearFilters: (e) async {
          emit(state.copyWith(filters: [], nickname: '', failureOrNull: null));
          add(const FmSearchEvent.search());
        },
        search: (e) async {
          if (state.isSearching) return;

          emit(
            state.copyWith(
              isSearching: true,
              isSearchOpen: false,
              failureOrNull: null,
              isLastPage: false,
              page: 0,
            ),
          );
          final failureOrTrades = await _fmMarketRepository.fetchTrades(
            page: state.page,
            resources: state.filters,
            nickname: state.nickname,
          );

          emit(
            failureOrTrades.fold(
              (f) => state.copyWith(isSearching: false, failureOrNull: f),
              (trades) =>
                  state.copyWith(isSearching: false, searchResults: trades),
            ),
          );
        },
        loadMore: (_) async {
          if (state.isSearching || state.isLastPage) return;

          Logger().d('load more');

          emit(
            state.copyWith(
              isSearching: true,
              failureOrNull: null,
              page: state.page + 1,
            ),
          );
          final failureOrTrades = await _fmMarketRepository.fetchTrades(
            page: state.page,
            resources: state.filters,
            nickname: state.nickname,
          );

          failureOrTrades.fold(
            (f) => emit(state.copyWith(isSearching: false, failureOrNull: f)),
            (trades) => emit(
              state.copyWith(
                isSearching: false,
                isLastPage: trades.length < 20,
                searchResults: List<TradeItem>.from(state.searchResults)
                  ..addAll(trades),
              ),
            ),
          );
        },
      );
    });
  }
}
