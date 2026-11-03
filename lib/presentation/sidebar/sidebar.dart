import 'package:package_flutter/l10n/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_flutter/bloc/sidebar/sidebar_bloc.dart';
import 'package:package_flutter/bloc/tutorial/tutorial_bloc.dart';
import 'package:package_flutter/bloc/user/user_provider.dart';
import 'package:package_flutter/domain/truck/truck_repository.dart';
import 'package:package_flutter/domain/tutorial/tutorial_step.dart';
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
      if (mounted) {
        switch (context.read<TutorialBloc>().state.step) {
          case OpenDoggyExpress():
            await Future.delayed(const Duration(milliseconds: 400));
            if (!mounted) return;
            ShowCaseWidget.of(context).startShowCase([_doggyExpress]);
          case OpenFMMarket():
            await Future.delayed(const Duration(milliseconds: 400));
            if (!mounted) return;
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

    return Drawer(
      child: Material(
        color: Theme.of(context).colorScheme.surface,
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
                          AppText(
                            '📦',
                            style: TextStyle(fontSize: 34),
                          ),
                          SizedBox(width: 10),
                          AppText(
                            'Package',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 26,
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
                      return SafeArea(
                        top: false,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 20,
                          ),
                          child: AppText(
                            '${user.avatar} ${user.nickname}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                            ),
                          ),
                        ),
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
