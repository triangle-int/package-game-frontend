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
      await event.map(
        started: (_) async {
          final failureOrStep = await _repository.getTutorialStep();
          failureOrStep.fold(
            (f) => emit(state.copyWith(step: const TutorialStep.initial())),
            (step) => emit(state.copyWith(step: step)),
          );
        },
        next: (_) async {
          final nextStep = state.step.next();
          await _repository.setStep(nextStep);
          emit(state.copyWith(step: nextStep));
        },
        skip: (_) {
          _repository.setStep(const TutorialStep.hidden());
          emit(state.copyWith(step: const TutorialStep.hidden()));
        },
        buildMenuOpened: (_) async => state.step.maybeMap(
          orElse: () {},
          openBuildMenu: (_) => add(const TutorialEvent.next()),
          openBuildMenu2: (_) => add(const TutorialEvent.next()),
        ),
        factoryPlace: (_) async => state.step.maybeMap(
          orElse: () {},
          placeFactory: (_) => add(const TutorialEvent.next()),
        ),
        storagePlace: (_) async => state.step.maybeMap(
          orElse: () {},
          placeStorage: (_) => add(const TutorialEvent.next()),
        ),
        truckSent: (_) async => state.step.maybeMap(
          orElse: () {},
          openDoggyExpress: (_) => add(const TutorialEvent.next()),
          openDoggyExpress2: (_) => add(const TutorialEvent.next()),
        ),
        resourceSelected: (_) async => state.step.maybeMap(
          orElse: () {},
          selectResource: (_) => add(const TutorialEvent.next()),
        ),
        truckArrived: (_) async => state.step.maybeMap(
          orElse: () {},
          waitTruck: (_) => add(const TutorialEvent.next()),
          waitTruck2: (_) => add(const TutorialEvent.next()),
        ),
        inventoryOpened: (_) async => state.step.maybeMap(
          orElse: () {},
          resourceInfo: (_) => add(const TutorialEvent.next()),
        ),
        businessPlace: (_) async => state.step.maybeMap(
          orElse: () {},
          hidden: (_) => add(const TutorialEvent.next()),
        ),
        priceSet: (_) async => state.step.maybeMap(
          orElse: () {},
          openFMMarket: (_) => add(const TutorialEvent.next()),
        ),
      );
    });
  }
}
