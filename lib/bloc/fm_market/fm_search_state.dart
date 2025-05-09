part of 'fm_search_bloc.dart';

@freezed
abstract class FmSearchState with _$FmSearchState {
  const factory FmSearchState({
    required bool isSearchOpen,
    required String nickname,
    required List<String> filters,
    required bool isSearching,
    required int page,
    required bool isLastPage,
    required List<TradeItem> searchResults,
    required ServerFailure? failureOrNull,
  }) = _FmSearchState;

  factory FmSearchState.initial() => const FmSearchState(
        isSearchOpen: false,
        nickname: '',
        filters: [],
        isSearching: false,
        searchResults: [],
        page: 0,
        failureOrNull: null,
        isLastPage: false,
      );
}
