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
        ..add(MarketEvent.requested(marketId)),
      child: const SizedBox(
        height: 424,
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: MarketBody(),
        ),
      ),
    );
  }
}
