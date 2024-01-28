import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_flutter/bloc/tutorial/tutorial_bloc.dart';
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
                final canContinue = tutorialState.step.maybeMap(
                  initial: (_) => true,
                  skipTutorial: (_) => true,
                  factoryInfo: (_) => true,
                  ending: (_) => true,
                  businessBuilt: (_) => true,
                  factoryResources: (_) => true,
                  marketResources: (_) => true,
                  orElse: () => false,
                );
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
                          tutorialState.step.map(
                            initial: (_) =>
                                "Hi, I am your new business consultant. I will help you properly manage your uncle's inheritance.",
                            skipTutorial: (_) =>
                                "If you decide you don't need my help, you can always click on the button above (strongly not recommended)",
                            openBuildMenu: (_) =>
                                'According to my calculations, the optimal solution would be to build a factory. To do this, click on any free space in the gray circle.',
                            placeFactory: (_) =>
                                'According to my calculations, the optimal solution would be to build a factory. To do this, click on any free space in the gray circle.',
                            hidden: (_) => 'Hidden dialogue',
                            openBuildMenu2: (_) =>
                                "Now let's build a warehouse where we will store your resources",
                            placeStorage: (_) =>
                                "Now let's build a warehouse where we will store your resources",
                            ending: (_) =>
                                'Now you are ready to run your business and grow!',
                            openDoggyExpress: (_) =>
                                "Good, let's move the resources from the factory to the warehouse. I recommend you Doggie Express, they have user's manual on the website",
                            factoryInfo: (_) =>
                                'Cool, the factory will produce a certain amount of resources per minute, but the workers also want to eat, so once every 12 hours you will have to fork out for salaries',
                            selectResource: (_) =>
                                'Select the resource in the factory to be produced.',
                            resourceInfo: (_) =>
                                "By the way, resources are divided into five branches, each has its own color. Let's open the inventory and see the resource we need",
                            openDoggyExpress2: (_) =>
                                'To sell a resource of a certain type, it must be delivered to a store of the same color. Use doggy express again.',
                            waitTruck: (_) =>
                                'Now we have to wait for the truck to arrive at the place',
                            waitTruck2: (_) =>
                                'Now we have to wait for the truck to arrive at the place',
                            businessBuilt: (_) =>
                                'Congratulations, you have built your first business. To effectively collect money from businesses, use satellites.',
                            factoryResources: (_) =>
                                'To upgrade the factory, you need the resources of other players. You can buy them all on the same FM Market',
                            hidden2: (_) => 'Hidden dialogue',
                            marketResources: (_) =>
                                'All the resources you buy are sent to the store, the color of which matches the color of the resource.',
                            openFMMarket: (_) =>
                                "It's time to set the price for which we will sell the product.",
                          ),
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
