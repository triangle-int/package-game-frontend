import 'package:audioplayers/audioplayers.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_flutter/app_router.dart';
import 'package:package_flutter/bloc/tutorial/tutorial_bloc.dart';
import 'package:package_flutter/presentation/noodle/browser_bar.dart';
import 'package:package_flutter/presentation/noodle/noodle_site.dart';
import 'package:showcaseview/showcaseview.dart';

@RoutePage()
class NoodlePage extends StatelessWidget {
  const NoodlePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ShowCaseWidget(
      disableBarrierInteraction: true,
      builder: Builder(
        builder: (context) {
          return const NoodleBody();
        },
      ),
    );
  }
}

class NoodleBody extends StatefulWidget {
  const NoodleBody({
    super.key,
  });

  @override
  State<NoodleBody> createState() => _NoodleBodyState();
}

class _NoodleBodyState extends State<NoodleBody> {
  final _fmMarketKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<TutorialBloc>().state.step.maybeMap(
            openFMMarket: (_) async {
              await Future.delayed(const Duration(milliseconds: 400));
              ShowCaseWidget.of(context).startShowCase([_fmMarketKey]);
            },
            orElse: () async {},
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const BrowserBar(
        icon: Icons.close,
        link: 'httgs://noodle.xyz',
      ),
      body: RefreshIndicator(
        backgroundColor: Colors.white,
        onRefresh: () => Future.delayed(const Duration(seconds: 1)),
        child: ListView(
          children: [
            Image.asset('assets/images/ui/new_noodle_logo.png'),
            const Divider(
              color: Color(0xFFD9D9D9),
              thickness: 1,
            ),
            const SizedBox(height: 15),
            Showcase(
              key: _fmMarketKey,
              description: 'Open FM Market',
              disposeOnTap: true,
              onTargetClick: () => context.router.push(const FMMarketRoute()),
              child: NoodleSite(
                title: 'F&M market',
                description:
                    'Decentralized NFT cryptomarket: no state, no slavery, no guarantee. And remember, FORTUNE FAVOURS THE BRAVE!',
                link: '📻 httgs://razvoda.net',
                onPressed: () {
                  AudioPlayer().play(AssetSource('sounds/mouse_click.wav'));
                  context.router.push(const FMMarketRoute());
                },
              ),
            ),
            const SizedBox(height: 15),
            NoodleSite(
              title: 'Doggie Express',
              description:
                  'The largest intergalactic delivery service. Speed and no problems with access!',
              link: '🦮 httgs://joycasino.com',
              onPressed: () {
                AudioPlayer().play(AssetSource('sounds/mouse_click.wav'));
                context.router.push(const DoggyExpressRoute());
              },
            ),
            const SizedBox(height: 15),
            NoodleSite(
              title: 'State National Marketplace',
              description:
                  'Goods produced by the state for businessmen. Our motto: quality and durability. Returns under warranty only.',
              link: '🗽 httgs://state-national-marketplace.net',
              onPressed: () {
                AudioPlayer().play(AssetSource('sounds/mouse_click.wav'));
                context.router.push(const SNMRoute());
              },
            ),
            // const SizedBox(height: 15),
            // NoodleSite(
            //   title: 'Torbes',
            //   description:
            //       "The largest businessmen and philanthropists compete here for the most valuable prizes. Well, for the opportunity to wipe everyone's nose.",
            //   link: '🐏 httgs://iotrazrabov.net',
            //   onPressed: () {},
            // ),
          ],
        ),
      ),
    );
  }
}
