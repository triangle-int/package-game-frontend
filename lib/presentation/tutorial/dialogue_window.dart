import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_flutter/bloc/tutorial/tutorial_bloc.dart';
import 'package:package_flutter/domain/tutorial/tutorial_step.dart';
import 'package:package_flutter/presentation/core/emoji_image.dart';

class DialogueWindow extends StatelessWidget {
  const DialogueWindow({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 12,
      bottom: 119,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 72),
            child: BlocBuilder<TutorialBloc, TutorialState>(
              builder: (context, tutorialState) {
                final canContinue = switch (tutorialState.step) {
                  InitialTutorialStep() => true,
                  SkipTutorial() => true,
                  FactoryInfo() => true,
                  Ending() => true,
                  BusinessBuilt() => true,
                  FactoryResources() => true,
                  MarketResources() => true,
                  _ => false,
                };
                return GestureDetector(
                  onTap: () {
                    if (canContinue) {
                      context
                          .read<TutorialBloc>()
                          .add(const TutorialEvent.next());
                    }
                  },
                  child: Container(
                    width: 239,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(7)),
                    ),
                    padding: const EdgeInsets.only(
                      top: 21,
                      right: 20,
                      left: 20,
                      bottom: 40,
                    ),
                    child: Column(
                      children: [
                        Text(
                          switch (tutorialState.step) {
                            InitialTutorialStep() =>
                              "Hi, I am your new business consultant. I will help you properly manage your uncle's inheritance.",
                            SkipTutorial() =>
                              "If you decide you don't need my help, you can always click on the button above (strongly not recommended)",
                            OpenBuildMenu() =>
                              'According to my calculations, the optimal solution would be to build a factory. To do this, click on any free space in the gray circle.',
                            PlaceFactory() =>
                              'According to my calculations, the optimal solution would be to build a factory. To do this, click on any free space in the gray circle.',
                            Hidden() => 'Hidden dialogue',
                            OpenBuildMenu2() =>
                              "Now let's build a warehouse where we will store your resources",
                            PlaceStorage() =>
                              "Now let's build a warehouse where we will store your resources",
                            Ending() =>
                              'Now you are ready to run your business and grow!',
                            OpenDoggyExpress() =>
                              "Good, let's move the resources from the factory to the warehouse. I recommend you Doggie Express, they have user's manual on the website",
                            FactoryInfo() =>
                              'Cool, the factory will produce a certain amount of resources per minute, but the workers also want to eat, so once every 12 hours you will have to fork out for salaries',
                            SelectResource() =>
                              'Select the resource in the factory to be produced.',
                            ResourceInfo() =>
                              "By the way, resources are divided into five branches, each has its own color. Let's open the inventory and see the resource we need",
                            OpenDoggyExpress2() =>
                              'To sell a resource of a certain type, it must be delivered to a store of the same color. Use doggy express again.',
                            WaitTruck() =>
                              'Now we have to wait for the truck to arrive at the place',
                            WaitTruck2() =>
                              'Now we have to wait for the truck to arrive at the place',
                            BusinessBuilt() =>
                              'Congratulations, you have built your first business. To effectively collect money from businesses, use satellites.',
                            FactoryResources() =>
                              'To upgrade the factory, you need the resources of other players. You can buy them all on the same FM Market',
                            Hidden2TutorialStep() => 'Hidden dialogue',
                            MarketResources() =>
                              'All the resources you buy are sent to the store, the color of which matches the color of the resource.',
                            OpenFMMarket() =>
                              "It's time to set the price for which we will sell the product.",
                          },
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                        if (canContinue) ...[
                          const SizedBox(height: 23),
                          const Text(
                            'Click on the dialog box to continue',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: Color(0xFF7F7F7F),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const Positioned(
            right: 0,
            bottom: 0,
            child: EmojiImage(
              emoji: '👨‍💼',
              size: 110,
            ),
          ),
        ],
      ),
    );
  }
}
