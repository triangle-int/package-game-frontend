import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_flutter/bloc/config/config_provider.dart';
import 'package:package_flutter/bloc/sidebar/sidebar_bloc.dart';
import 'package:package_flutter/bloc/tutorial/tutorial_bloc.dart';
import 'package:package_flutter/bloc/user/user_provider.dart';
import 'package:package_flutter/domain/truck/truck_repository.dart';
import 'package:package_flutter/domain/tutorial/tutorial_step.dart';
import 'package:package_flutter/domain/user/user.dart';
import 'package:package_flutter/presentation/core/transformers/currency_transformer.dart';
import 'package:package_flutter/presentation/sidebar/sidebar_body.dart';
import 'package:package_flutter/presentation/sidebar/sidebar_routes.dart';
import 'package:showcaseview/showcaseview.dart';

class Sidebar extends StatefulHookConsumerWidget {
  const Sidebar({super.key});

  @override
  ConsumerState<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends ConsumerState<Sidebar> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (context.mounted) {
        switch (context.read<TutorialBloc>().state.step) {
          case OpenDoggyExpress():
            await Future.delayed(const Duration(milliseconds: 400));
            if (!context.mounted) return;
            ShowCaseWidget.of(context).startShowCase([_doggyExpress]);
          case OpenFMMarket():
            await Future.delayed(const Duration(milliseconds: 400));
            if (!context.mounted) return;
            ShowCaseWidget.of(context).startShowCase([_noodle]);
          default:
            break;
        }
      }
    });
  }

  final _doggyExpress = GlobalKey();
  final _noodle = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider).value!;
    final money = user.money.toCurrency();
    final gems = user.gems.toCurrency();
    final level = (user.level + 1).toCurrency();
    final nextLevel = (user.level + 2).toCurrency();

    return Drawer(
      child: Material(
        color: Theme.of(context).colorScheme.background,
        child: BlocProvider(
          create: (context) => SidebarBloc(ref.watch(truckRepositoryProvider)),
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding:
                      EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                  child: Column(
                    children: <Widget>[
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            '📦',
                            style: TextStyle(fontSize: 58),
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Package',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 40,
                            ),
                          ),
                          SizedBox(width: 5),
                        ],
                      ),
                      const Divider(
                        color: Color(0xFF6C6C6C),
                        thickness: 2,
                      ),
                      BlocBuilder<SidebarBloc, SidebarState>(
                        builder: (context, sidebarState) {
                          switch (sidebarState) {
                            case SidebarStateInitial():
                              return SidebarBody(
                                noodleKey: _noodle,
                                doggyExpressKey: _doggyExpress,
                              );
                            case SidebarStateRoutes():
                              return const SidebarRoutes();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              BlocBuilder<SidebarBloc, SidebarState>(
                builder: (context, sidebarState) {
                  switch (sidebarState) {
                    case SidebarStateInitial():
                      return BottomSidebar(
                        user: user,
                        level: level,
                        nextLevel: nextLevel,
                        gems: gems,
                        money: money,
                      );
                    case SidebarStateRoutes():
                      return Container();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BottomSidebar extends HookConsumerWidget {
  const BottomSidebar({
    super.key,
    required this.user,
    required this.level,
    required this.nextLevel,
    required this.gems,
    required this.money,
  });

  final User user;
  final String level;
  final String nextLevel;
  final String gems;
  final String money;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(configProvider).value!;
    final expForCurrentLevel =
        BigInt.from(config.expreienceForLevel[user.level]);
    final progress = clampDouble(user.experience / expForCurrentLevel, 0, 1);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
      child: Column(
        children: [
          Text(
            '${user.avatar} ${user.nickname}',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 24,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                level,
                style: const TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 24,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: FractionallySizedBox(
                    widthFactor: progress,
                    alignment: Alignment.centerLeft,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFB800),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                nextLevel,
                style: const TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 24,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$gems 💎',
                style: const TextStyle(
                  fontSize: 24,
                  fontFamily: 'Montserrat',
                ),
              ),
              Text(
                '$money 💵',
                style: const TextStyle(
                  fontSize: 24,
                  fontFamily: 'Montserrat',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(expForCurrentLevel - user.experience).toCurrency()} 🎖️ left',
                style: const TextStyle(
                  fontSize: 24,
                  fontFamily: 'Montserrat',
                ),
              ),
              const Text(
                '00:00 ☕',
                style: TextStyle(
                  fontSize: 24,
                  fontFamily: 'Montserrat',
                ),
              ),
            ],
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}
