import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:package_flutter/domain/tutorial/tutorial_repository.dart';
import 'package:package_flutter/domain/tutorial/tutorial_step.dart';

part 'tutorial_event.dart';
part 'tutorial_state.dart';
part 'tutorial_bloc.freezed.dart';

class TutorialBloc extends Bloc<TutorialEvent, TutorialState> {
  final TutorialRepository _repository;

  TutorialBloc(this._repository) : super(TutorialState.initial()) {
    on<TutorialEvent>((event, emit) async {
      switch (event) {
        case TutorialEventStarted():
          final failureOrStep = await _repository.getTutorialStep();
          failureOrStep.fold(
            (f) => emit(state.copyWith(step: const TutorialStep.initial())),
            (step) => emit(state.copyWith(step: step)),
          );
        case TutorialEventNext():
          final nextStep = state.step.next();
          await _repository.setStep(nextStep);
          emit(state.copyWith(step: nextStep));
        case TutorialEventSkip():
          _repository.setStep(const TutorialStep.hidden());
          emit(state.copyWith(step: const TutorialStep.hidden()));
        case TutorialEventBuildMenuOpened():
          switch (state.step) {
            case OpenBuildMenu():
              add(const TutorialEvent.next());
            case OpenBuildMenu2():
              add(const TutorialEvent.next());
            default:
              break;
          }
        case TutorialEventFactoryPlace():
          switch (state.step) {
            case PlaceFactory():
              add(const TutorialEvent.next());
            default:
              break;
          }
        case TutorialEventStoragePlace():
          switch (state.step) {
            case PlaceStorage():
              add(const TutorialEvent.next());
            default:
              break;
          }
        case TutorialEventTruckSent():
          switch (state.step) {
            case OpenDoggyExpress():
              add(const TutorialEvent.next());
            case OpenDoggyExpress2():
              add(const TutorialEvent.next());
            default:
              break;
          }
        case TutorialEventResourceSelected():
          switch (state.step) {
            case SelectResource():
              add(const TutorialEvent.next());
            default:
              break;
          }
        case TutorialEventTruckArrived():
          switch (state.step) {
            case WaitTruck():
              add(const TutorialEvent.next());
            case WaitTruck2():
              add(const TutorialEvent.next());
            default:
              break;
          }
        case TutorialEventInventoryOpened():
          switch (state.step) {
            case ResourceInfo():
              add(const TutorialEvent.next());
            default:
              break;
          }
        case TutorialEventBusinessPlace():
          switch (state.step) {
            case Hidden():
              add(const TutorialEvent.next());
            default:
              break;
          }
        case TutorialEventPriceSet():
          switch (state.step) {
            case OpenFMMarket():
              add(const TutorialEvent.next());
            default:
              break;
          }
      }
    });
  }
}
