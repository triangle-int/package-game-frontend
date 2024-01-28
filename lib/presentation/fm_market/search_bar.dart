import 'package:audioplayers/audioplayers.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_flutter/app_router.dart';
import 'package:package_flutter/bloc/fm_market/fm_search_bloc.dart';
import 'package:package_flutter/bloc/tutorial/tutorial_bloc.dart';
import 'package:showcaseview/showcaseview.dart';

class SearchBar extends StatefulWidget {
  const SearchBar({
    super.key,
  });

  @override
  State<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  final _profileKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<TutorialBloc>().state.step.maybeMap(
            openFMMarket: (_) async {
              await Future.delayed(const Duration(milliseconds: 400));
              if (!context.mounted) return;
              ShowCaseWidget.of(context).startShowCase([_profileKey]);
            },
            orElse: () async {},
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FmSearchBloc, FmSearchState>(
      builder: (context, fmSearchState) {
        return Container(
          height: 62,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                IconButton(
                  onPressed: fmSearchState.isSearchOpen
                      ? () {
                          AudioPlayer()
                              .play(AssetSource('sounds/mouse_click.wav'));
                          context
                              .read<FmSearchBloc>()
                              .add(const FmSearchEvent.closeSearch());
                        }
                      : (fmSearchState.filters.isEmpty &&
                              fmSearchState.nickname.isEmpty
                          ? null
                          : () {
                              AudioPlayer()
                                  .play(AssetSource('sounds/mouse_click.wav'));
                              context
                                  .read<FmSearchBloc>()
                                  .add(const FmSearchEvent.clearFilters());
                            }),
                  color: Colors.black,
                  disabledColor: Colors.black.withOpacity(0.25),
                  iconSize: 30,
                  icon: const Icon(
                    Icons.close,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: fmSearchState.isSearchOpen
                      ? Container()
                      : ElevatedButton(
                          onPressed: () {
                            AudioPlayer()
                                .play(AssetSource('sounds/mouse_click.wav'));
                            context
                                .read<FmSearchBloc>()
                                .add(const FmSearchEvent.openSearch());
                          },
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: const Text('Search'),
                        ),
                ),
                const SizedBox(width: 20),
                Showcase(
                  key: _profileKey,
                  description: 'Tap on profile button',
                  disposeOnTap: true,
                  onTargetClick: () =>
                      context.router.push(const ProfileRoute()),
                  child: IconButton(
                    onPressed: fmSearchState.isSearchOpen
                        ? () {
                            AudioPlayer()
                                .play(AssetSource('sounds/mouse_click.wav'));
                            context
                                .read<FmSearchBloc>()
                                .add(const FmSearchEvent.search());
                          }
                        : () {
                            AudioPlayer()
                                .play(AssetSource('sounds/mouse_click.wav'));
                            context.router.push(const ProfileRoute());
                          },
                    color: Colors.black,
                    iconSize: 30,
                    icon: Icon(
                      fmSearchState.isSearchOpen
                          ? Icons.search
                          : Icons.account_circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
