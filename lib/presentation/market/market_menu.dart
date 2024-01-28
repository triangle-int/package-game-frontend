import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_flutter/bloc/market/market_bloc.dart';
import 'package:package_flutter/domain/building/building_repository.dart';
import 'package:package_flutter/presentation/market/market_body.dart';

class MarketMenu extends HookConsumerWidget {
  final int marketId;

  const MarketMenu({required this.marketId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BlocProvider(
      create: (context) => MarketBloc(ref.watch(buildingRepositoryProvider))
        ..add(MarketEvent.marketRequested(marketId)),
      child: Center(
        child: Container(
          width: 334,
          height: 424,
          padding: const EdgeInsets.only(
            top: 27,
            left: 18,
            right: 18,
            bottom: 27,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.background,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const MarketBody(),
        ),
      ),
    );
  }
}
