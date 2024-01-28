import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:package_flutter/bloc/fm_market/fm_search_bloc.dart';
import 'package:package_flutter/presentation/fm_market/fm_market_logo.dart';
import 'package:package_flutter/presentation/fm_market/fm_market_trades.dart';
import 'package:package_flutter/presentation/fm_market/search_bar.dart'
    as search;
import 'package:package_flutter/presentation/noodle/browser_bar.dart';
import 'package:showcaseview/showcaseview.dart';

@RoutePage()
class FMMarketPage extends HookWidget {
  const FMMarketPage({super.key});

  @override
  Widget build(BuildContext context) {
    useEffect(
      () {
        context.read<FmSearchBloc>().add(const FmSearchEvent.search());
        return null;
      },
      [],
    );

    return ShowCaseWidget(
      disableBarrierInteraction: true,
      builder: Builder(
        builder: (context) {
          return const Scaffold(
            backgroundColor: Color(0xFFEEEEEE),
            appBar: BrowserBar(
              icon: Icons.arrow_back,
              link: 'httgs://razvoda.net/F&M-Market',
            ),
            body: Column(
              children: [
                Stack(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 89),
                      child: search.SearchBar(),
                    ),
                    FMMarketLogo(),
                  ],
                ),
                Expanded(
                  child: FMMarketTrades(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
