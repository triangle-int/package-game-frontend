import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_flutter/bloc/doggie_express/delivery_buildings/delivery_buildings_bloc.dart';
import 'package:package_flutter/domain/truck/truck_repository.dart';
import 'package:package_flutter/presentation/doggy_express/doggy_express_route_header.dart';
import 'package:package_flutter/presentation/doggy_express/doggy_express_route_map.dart';
import 'package:package_flutter/presentation/noodle/browser_bar.dart';

@RoutePage()
class DoggyExpressRoutePage extends HookConsumerWidget {
  const DoggyExpressRoutePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BlocProvider(
      create: (context) =>
          DeliveryBuildingsBloc(ref.watch(truckRepositoryProvider))
            ..add(const DeliveryBuildingsEvent.buildingsRequested()),
      child: const Scaffold(
        appBar: BrowserBar(
          icon: Icons.arrow_back,
          link: 'httgs://doggie-express.com/route',
        ),
        body: Column(
          children: [
            DoggyExpressRouteHeader(),
            DoggyExpressRouteMap(),
          ],
        ),
      ),
    );
  }
}
