import 'package:freezed_annotation/freezed_annotation.dart';

part 'tutorial_step.freezed.dart';
part 'tutorial_step.g.dart';

@Freezed(fallbackUnion: 'hidden2')
sealed class TutorialStep with _$TutorialStep {
  const TutorialStep._();

  @FreezedUnionValue('0')
  const factory TutorialStep.initial() = InitialTutorialStep;
  @FreezedUnionValue('1')
  const factory TutorialStep.skipTutorial() = SkipTutorial;
  @FreezedUnionValue('2')
  const factory TutorialStep.openBuildMenu() = OpenBuildMenu;
  @FreezedUnionValue('3')
  const factory TutorialStep.placeFactory() = PlaceFactory;
  @FreezedUnionValue('4')
  const factory TutorialStep.selectResource() = SelectResource;
  @FreezedUnionValue('5')
  const factory TutorialStep.factoryInfo() = FactoryInfo;
  @FreezedUnionValue('6')
  const factory TutorialStep.openBuildMenu2() = OpenBuildMenu2;
  @FreezedUnionValue('7')
  const factory TutorialStep.placeStorage() = PlaceStorage;
  @FreezedUnionValue('8')
  const factory TutorialStep.openDoggyExpress() = OpenDoggyExpress;
  @FreezedUnionValue('9')
  const factory TutorialStep.waitTruck() = WaitTruck;
  @FreezedUnionValue('10')
  const factory TutorialStep.resourceInfo() = ResourceInfo;
  @FreezedUnionValue('11')
  const factory TutorialStep.openDoggyExpress2() = OpenDoggyExpress2;
  @FreezedUnionValue('12')
  const factory TutorialStep.waitTruck2() = WaitTruck2;
  @FreezedUnionValue('13')
  const factory TutorialStep.openFMMarket() = OpenFMMarket;
  @FreezedUnionValue('14')
  const factory TutorialStep.factoryResources() = FactoryResources;
  @FreezedUnionValue('15')
  const factory TutorialStep.marketResources() = MarketResources;
  @FreezedUnionValue('16')
  const factory TutorialStep.ending() = Ending;
  @FreezedUnionValue('17')
  const factory TutorialStep.hidden() = Hidden;
  @FreezedUnionValue('18')
  const factory TutorialStep.businessBuilt() = BusinessBuilt;
  @FreezedUnionValue('1000')
  const factory TutorialStep.hidden2() = Hidden2TutorialStep;

  factory TutorialStep.fromJson(Map<String, dynamic> json) =>
      _$TutorialStepFromJson(json);

  TutorialStep next() {
    final nextStepInt = int.parse(toJson()['runtimeType'] as String) + 1;
    return TutorialStep.fromJson({'runtimeType': '$nextStepInt'});
  }

  bool isAfterOrEqual(TutorialStep step) {
    final a = int.parse(toJson()['runtimeType'] as String);
    final b = int.parse(step.toJson()['runtimeType'] as String);

    return a >= b;
  }
}
