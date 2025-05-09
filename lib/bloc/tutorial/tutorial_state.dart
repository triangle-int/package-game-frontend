part of 'tutorial_bloc.dart';

@freezed
abstract class TutorialState with _$TutorialState {
  const factory TutorialState({
    required TutorialStep step,
  }) = _TutorialState;

  factory TutorialState.initial() => const TutorialState(
        step: TutorialStep.hidden(),
      );
}
