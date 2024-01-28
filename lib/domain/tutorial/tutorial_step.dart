import 'package:freezed_annotation/freezed_annotation.dart';

part 'tutorial_step.freezed.dart';
part 'tutorial_step.g.dart';

@Freezed(fallbackUnion: 'hidden2')
class TutorialStep with _$TutorialStep {
  const TutorialStep._();

  @FreezedUnionValue('0')
  const factory TutorialStep.initial() = InitialTutorialStep;
  @FreezedUnionValue('1')
  const factory TutorialStep.skipTutorial() = _SkipTutorial;
  @FreezedUnionValue('2')
  const factory TutorialStep.openBuildMenu() = _OpenBuildMenu;
  @FreezedUnionValue('3')
  const factory TutorialStep.placeFactory() = _PlaceFactory;
  @FreezedUnionValue('4')
  const factory TutorialStep.selectResource() = _SelectResource;
  @FreezedUnionValue('5')
  const factory TutorialStep.factoryInfo() = _FactoryInfo;
  @FreezedUnionValue('6')
  const factory TutorialStep.openBuildMenu2() = _OpenBuildMenu2;
  @FreezedUnionValue('7')
  const factory TutorialStep.placeStorage() = _PlaceStorage;
  @FreezedUnionValue('8')
  const factory TutorialStep.openDoggyExpress() = _OpenDoggyExpress;
  @FreezedUnionValue('9')
  const factory TutorialStep.waitTruck() = _WaitTruck;
  @FreezedUnionValue('10')
  const factory TutorialStep.resourceInfo() = _ResourceInfo;
  @FreezedUnionValue('11')
  const factory TutorialStep.openDoggyExpress2() = _OpenDoggyExpress2;
  @FreezedUnionValue('12')
  const factory TutorialStep.waitTruck2() = _WaitTruck2;
  @FreezedUnionValue('13')
  const factory TutorialStep.openFMMarket() = _OpenFMMarket;
  @FreezedUnionValue('14')
  const factory TutorialStep.factoryResources() = _FactoryResources;
  @FreezedUnionValue('15')
  const factory TutorialStep.marketResources() = _MarketResources;
  @FreezedUnionValue('16')
  const factory TutorialStep.ending() = _Ending;
  @FreezedUnionValue('17')
  const factory TutorialStep.hidden() = _Hidden;
  @FreezedUnionValue('18')
  const factory TutorialStep.businessBuilt() = _BusinessBuilt;
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
