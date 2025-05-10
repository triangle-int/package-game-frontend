import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_flutter/app_router.dart';
import 'package:package_flutter/bloc/doggie_express/amount_and_product/amount_and_product_bloc.dart';
import 'package:package_flutter/bloc/doggie_express/doggie_express_bloc.dart';
import 'package:package_flutter/bloc/notifications/notifications_bloc.dart';
import 'package:package_flutter/bloc/tutorial/tutorial_bloc.dart';
import 'package:package_flutter/bloc/user/user_provider.dart';
import 'package:package_flutter/domain/building/building_repository.dart';
import 'package:package_flutter/domain/factory/factory_repository.dart';
import 'package:package_flutter/domain/truck/truck_failure.dart';
import 'package:package_flutter/domain/tutorial/tutorial_step.dart';
import 'package:package_flutter/presentation/core/emoji_image.dart';
import 'package:package_flutter/presentation/core/transformers/currency_transformer.dart';
import 'package:package_flutter/presentation/doggy_express/amount_and_product.dart';
import 'package:package_flutter/presentation/doggy_express/amount_confirm.dart';
import 'package:package_flutter/presentation/doggy_express/doggy_express_step.dart';
import 'package:package_flutter/presentation/doggy_express/product_confirm.dart';
import 'package:package_flutter/presentation/noodle/browser_bar.dart';

@RoutePage()
class DoggyExpressPage extends HookConsumerWidget {
  const DoggyExpressPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    useEffect(
      () {
        context.read<DoggieExpressBloc>().add(const DoggieExpressEvent.reset());
        return null;
      },
      [],
    );

    final user = ref.watch(userProvider).value!;

    return BlocConsumer<DoggieExpressBloc, DoggieExpressState>(
      listener: (context, doggieExpressState) {
        if (doggieExpressState.failureOrNull != null) {
          context.read<NotificationsBloc>().add(
                NotificationsEvent.warningAdded(
                  switch (doggieExpressState.failureOrNull!) {
                    TruckFailureResourceNotSelected() =>
                      'Resource not selected',
                    TruckFailurePointANotSelected() =>
                      'First building not selected',
                    TruckFailurePointBNotSelected() =>
                      'Second building not selected',
                    TruckFailureAmountIsZero() => 'Amount is invalid',
                    TruckFailurePathNotCalculated() => 'Path not calculated',
                    TruckFailureServerFailure(:final f) => f.getMessage(),
                  },
                ),
              );
        }
        if (doggieExpressState.success) {
          context.router.popUntilRoot();
          context.router.pop();
          context.read<TutorialBloc>().add(const TutorialEvent.truckSent());
          context.read<NotificationsBloc>().add(
                const NotificationsEvent.successAdded(
                  'Route created successfully!',
                ),
              );
        }
      },
      builder: (context, doggyState) =>
          BlocBuilder<TutorialBloc, TutorialState>(
        builder: (context, tutorialState) {
          return GestureDetector(
            onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
            child: Scaffold(
              backgroundColor: Colors.white,
              appBar: BrowserBar(
                icon: Icons.arrow_back,
                link: 'httgs://doggie-express.com',
                backButtonDisabled: switch (tutorialState.step) {
                  OpenDoggyExpress() => true,
                  _ => false,
                },
              ),
              body: ListView(
                padding: EdgeInsets.zero,
                children: [
                  const SizedBox(
                    height: 89,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Doggie',
                          style: TextStyle(
                            fontFamily: 'Piazzolla',
                            fontSize: 36,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF333363),
                          ),
                        ),
                        SizedBox(width: 10),
                        EmojiImage(
                          emoji: '🦮',
                          size: 73,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Express',
                          style: TextStyle(
                            fontFamily: 'Piazzolla',
                            fontSize: 36,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF333363),
                          ),
                        ),
                      ],
                    ),
                  ),
                  DoggyExpressStep(
                    text: 'Your balance: ${user.money.toCurrency()} 💵',
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 20,
                    ),
                    child: const Column(
                      children: [
                        Row(
                          children: [
                            Expanded(child: EmojiImage(emoji: '🏞')),
                            SizedBox(width: 10),
                            Expanded(child: EmojiImage(emoji: '🌃')),
                            SizedBox(width: 10),
                            Expanded(child: EmojiImage(emoji: '🌄')),
                            SizedBox(width: 10),
                            Expanded(child: EmojiImage(emoji: '🌁')),
                          ],
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Shipping all around the world',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  DoggyExpressStep(
                    text: 'Step 1',
                    padding: const EdgeInsets.only(
                      right: 20,
                      left: 20,
                      top: 20,
                      bottom: 50,
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Choose a route',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 13),
                        const Text(
                          'First select the starting point, then the final destination',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 13),
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(184, 45),
                            foregroundColor: Colors.white,
                            side: const BorderSide(
                              color: Colors.white,
                              width: 2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          onPressed: () {
                            context.router.push(const DoggyExpressRouteRoute());
                          },
                          child: const Text(
                            'ROUTE',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  AnimatedOpacity(
                    opacity:
                        doggyState.pointA != null && doggyState.pointB != null
                            ? 1
                            : 0,
                    duration: const Duration(milliseconds: 300),
                    child: DoggyExpressStep(
                      text: 'Step 2',
                      padding: const EdgeInsets.only(
                        right: 20,
                        left: 20,
                        top: 20,
                        bottom: 50,
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Choose your product',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 13),
                          const Text(
                            'Select, what do you want to deliver from the list of things contained in your destination point',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 13),
                          BlocProvider(
                            create: (context) => AmountAndProductBloc(
                              ref.watch(buildingRepositoryProvider),
                              ref.watch(factoryRepositoryProvider),
                            ),
                            child: BlocListener<DoggieExpressBloc,
                                DoggieExpressState>(
                              listener: (context, doggieExpressState) {
                                if (doggieExpressState.pointA == null ||
                                    doggieExpressState.pointB == null) {
                                  context.read<AmountAndProductBloc>().add(
                                        const AmountAndProductEvent
                                            .initialOpened(),
                                      );
                                }
                              },
                              child: BlocBuilder<AmountAndProductBloc,
                                  AmountAndProductState>(
                                builder: (context, amountAndProductState) =>
                                    switch (amountAndProductState) {
                                  AmountAndProductStateInitial() =>
                                    const AmountAndProduct(),
                                  AmountAndProductStateLoadInProgress() =>
                                    const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  AmountAndProductStateProductSelectionSuccess(
                                    :final items
                                  ) =>
                                    ProductConfirm(items: items),
                                  AmountAndProductStateProductSelectionFailure(
                                    :final failure
                                  ) =>
                                    Text(
                                      'Failure: ${failure.getMessage()}',
                                    ),
                                  AmountAndProductStateAmountSelectionSuccess(
                                    :final maxAmount
                                  ) =>
                                    AmountConfirm(maxAmount: maxAmount),
                                  AmountAndProductStateAmountSelectionFailure(
                                    :final failure
                                  ) =>
                                    Text(
                                      'Failure: ${failure.getMessage()}',
                                    ),
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  AnimatedOpacity(
                    opacity: doggyState.amount != BigInt.from(0) &&
                            doggyState.resource.isNotEmpty
                        ? 1
                        : 0,
                    duration: const Duration(milliseconds: 300),
                    child: DoggyExpressStep(
                      text: 'Step 3',
                      padding: const EdgeInsets.only(
                        right: 20,
                        left: 20,
                        top: 20,
                        bottom: 31,
                      ),
                      questionMark: Padding(
                        padding: const EdgeInsets.only(right: 15),
                        child: IconButton(
                          iconSize: 45,
                          padding: EdgeInsets.zero,
                          color: const Color(0xFF333363),
                          icon: const Icon(Icons.help_outline),
                          onPressed: () {
                            context.router.push(const TruckTypeHelpRoute());
                          },
                        ),
                      ),
                      child: const Column(
                        children: [
                          Text(
                            'Choose your delivery type',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 13),
                          Text(
                            'Select, what truck do you want to use',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              TruckTypeButton(emoji: '🦮', truckType: 0),
                              TruckTypeButton(emoji: '🚚', truckType: 1),
                              TruckTypeButton(emoji: '🛩', truckType: 2),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  AnimatedOpacity(
                    opacity: doggyState.truckType != -1 ? 1 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: const DoggyExpressStep(
                      text: 'Step 4',
                      padding: EdgeInsets.only(
                        right: 20,
                        left: 20,
                        top: 20,
                        bottom: 31,
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Choose your delivery schedule',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 13),
                          Text(
                            'Select, how often your route will repeat',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 22),
                          ScheduleButton(
                            text: 'One time',
                            scheduleType: 0,
                            padding: EdgeInsets.symmetric(horizontal: 12),
                          ),
                          SizedBox(height: 13),
                          Text(
                            'Or once every',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 22),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ScheduleButton(
                                text: '1h',
                                scheduleType: 1,
                                padding: EdgeInsets.all(1),
                              ),
                              ScheduleButton(
                                text: '6h',
                                scheduleType: 2,
                                padding: EdgeInsets.all(1),
                              ),
                              ScheduleButton(
                                text: '12h',
                                scheduleType: 3,
                                padding: EdgeInsets.all(1),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  AnimatedOpacity(
                    opacity: doggyState.scheduleDuration != -1 ? 1 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: DoggyExpressStep(
                      text: 'Step 5',
                      padding: const EdgeInsets.only(
                        right: 20,
                        left: 20,
                        top: 20,
                        bottom: 108,
                      ),
                      child: BlocBuilder<DoggieExpressBloc, DoggieExpressState>(
                        builder: (context, doggieExpressState) {
                          final cost =
                              doggieExpressState.path?.cost.toCurrency() ??
                                  '???';
                          final costPerTruck = doggieExpressState
                                  .path?.costPerTruck
                                  .toCurrency() ??
                              '???';
                          return Column(
                            children: [
                              const Text(
                                'Check final cost',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 13),
                              const Text(
                                'Calculate total shipping cost',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 22),
                              OutlinedButton(
                                onPressed: () => context
                                    .read<DoggieExpressBloc>()
                                    .add(const DoggieExpressEvent.calculate()),
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size.square(45),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 18,
                                    vertical: 8,
                                  ),
                                  foregroundColor: Colors.white,
                                  side: const BorderSide(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                child: const Text(
                                  'CALCULATE',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 18),
                              if (doggieExpressState.isLoading) ...[
                                const SizedBox(
                                  height: 100,
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                              ] else ...[
                                Text(
                                  'Cost of 1 courier: $costPerTruck 💵',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 13),
                                Text(
                                  'Total: $cost 💵',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 26),
                                OutlinedButton(
                                  onPressed: doggieExpressState.path == null
                                      ? null
                                      : () => context
                                          .read<DoggieExpressBloc>()
                                          .add(
                                            const DoggieExpressEvent.confirm(),
                                          ),
                                  style: OutlinedButton.styleFrom(
                                    minimumSize: const Size.square(45),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 18,
                                      vertical: 8,
                                    ),
                                    foregroundColor: Colors.white,
                                    disabledForegroundColor:
                                        const Color(0xFF8D8D8D),
                                    side: BorderSide(
                                      color: doggieExpressState.path == null
                                          ? const Color(0xFF8D8D8D)
                                          : Colors.white,
                                      width: 2,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  child: const Text(
                                    'CONFIRM',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class TruckTypeButton extends StatelessWidget {
  const TruckTypeButton({
    super.key,
    required this.emoji,
    required this.truckType,
  });

  final String emoji;
  final int truckType;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BlocBuilder<DoggieExpressBloc, DoggieExpressState>(
          builder: (context, state) {
            return AnimatedContainer(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: state.truckType == truckType
                    ? Colors.white
                    : Colors.transparent,
                shape: BoxShape.circle,
              ),
              duration: const Duration(milliseconds: 200),
            );
          },
        ),
        const SizedBox(height: 7),
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            fixedSize: const Size.square(45),
            minimumSize: const Size.square(45),
            padding: const EdgeInsets.all(7),
            foregroundColor: Colors.white,
            side: const BorderSide(
              color: Colors.white,
              width: 2,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          onPressed: () {
            context
                .read<DoggieExpressBloc>()
                .add(DoggieExpressEvent.truckTypeUpdated(truckType));
          },
          child: EmojiImage(
            emoji: emoji,
          ),
        ),
      ],
    );
  }
}

class ScheduleButton extends StatelessWidget {
  const ScheduleButton({
    super.key,
    required this.text,
    required this.scheduleType,
    required this.padding,
  });

  final String text;
  final int scheduleType;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Transform(
          transform: Matrix4.translationValues(-25, 45 / 2 - 9, 0),
          child: BlocBuilder<DoggieExpressBloc, DoggieExpressState>(
            builder: (context, state) {
              return AnimatedContainer(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: state.scheduleDuration == scheduleType
                      ? Colors.white
                      : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                duration: const Duration(milliseconds: 200),
              );
            },
          ),
        ),
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.square(45),
            padding: padding,
            foregroundColor: Colors.white,
            side: const BorderSide(
              color: Colors.white,
              width: 2,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          onPressed: () {
            context
                .read<DoggieExpressBloc>()
                .add(DoggieExpressEvent.scheduleDurationUpdated(scheduleType));
          },
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
