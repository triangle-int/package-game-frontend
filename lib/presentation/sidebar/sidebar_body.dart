import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_flutter/app_router.dart';
import 'package:package_flutter/bloc/auth/auth_bloc.dart';
import 'package:package_flutter/bloc/sidebar/sidebar_bloc.dart';
import 'package:package_flutter/presentation/sidebar/sidebar_item.dart';
import 'package:package_flutter/presentation/sidebar/sidebar_settings.dart';
import 'package:showcaseview/showcaseview.dart';

class SidebarBody extends StatelessWidget {
  const SidebarBody({
    super.key,
    required this.doggyExpressKey,
    required this.noodleKey,
  });

  final GlobalKey doggyExpressKey;
  final GlobalKey noodleKey;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SidebarBloc, SidebarState>(
      builder: (context, state) {
        return Expanded(
          child: ListView(
            padding: const EdgeInsets.only(top: 16),
            children: [
              Showcase(
                description: 'Open Noodle',
                key: noodleKey,
                disposeOnTap: true,
                onTargetClick: () => context.router.push(const NoodleRoute()),
                child: SidebarItem(
                  text: 'Noodle',
                  emoji: '🍜',
                  onTap: () {
                    context.router.push(const NoodleRoute());
                  },
                ),
              ),
              const SizedBox(height: 16),
              Showcase(
                description: 'Open Doggy Express',
                key: doggyExpressKey,
                disposeOnTap: true,
                onTargetClick: () =>
                    context.router.push(const DoggyExpressRoute()),
                child: SidebarItem(
                  text: 'Doggie Express',
                  emoji: '🦮',
                  onTap: () {
                    context.router.push(const DoggyExpressRoute());
                  },
                ),
              ),
              const SizedBox(height: 16),
              SidebarItem(
                text: 'Routes',
                emoji: '🚚',
                onTap: () {
                  context
                      .read<SidebarBloc>()
                      .add(const SidebarEvent.routesSelected());
                },
              ),
              const SizedBox(height: 16),
              ExpansionPanelList(
                elevation: 0,
                expandedHeaderPadding: EdgeInsets.zero,
                children: [
                  ExpansionPanel(
                    backgroundColor: Theme.of(context).colorScheme.background,
                    headerBuilder: (context, isOpen) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      alignment: Alignment.centerLeft,
                      child: const Text(
                        '⚙️ Settings',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ),
                    body: const SidebarSettings(),
                    isExpanded: state.map(
                      initial: (s) => s.isSettingsOpened,
                      routes: (_) => false,
                    ),
                    canTapOnHeader: true,
                  ),
                ],
                expansionCallback: (panelIndex, isExpanded) => context
                    .read<SidebarBloc>()
                    .add(const SidebarEvent.settingsToggled()),
              ),
              if (kDebugMode) ...[
                const SizedBox(height: 16),
                SidebarItem(
                  text: 'Log out',
                  emoji: '🚪',
                  onTap: () {
                    context.read<AuthBloc>().add(const AuthEvent.signedOut());
                  },
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
