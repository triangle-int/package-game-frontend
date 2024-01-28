import 'package:auto_route/annotations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:package_flutter/domain/fm_market/trade_item.dart';
import 'package:package_flutter/domain/truck/truck.dart';
import 'package:package_flutter/domain/truck/truck_schedule.dart';
import 'package:package_flutter/presentation/doggy_express/doggy_express_page.dart';
import 'package:package_flutter/presentation/doggy_express/doggy_express_route_page.dart';
import 'package:package_flutter/presentation/doggy_express/truck_type_help_page.dart';
import 'package:package_flutter/presentation/fm_market/buy_page.dart';
import 'package:package_flutter/presentation/fm_market/fm_market_page.dart';
import 'package:package_flutter/presentation/fm_market/profile_page.dart';
import 'package:package_flutter/presentation/landing/landing_page.dart';
import 'package:package_flutter/presentation/map/route_map_page.dart';
import 'package:package_flutter/presentation/noodle/noodle_page.dart';
import 'package:package_flutter/presentation/state_national_marketplace/snm_page.dart';

part 'app_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends _$AppRouter {
  @override
  RouteType get defaultRouteType => RouteType.material();

  @override
  List<AutoRoute> get routes => [
        AutoRoute(page: LandingRoute.page, initial: true),
        AutoRoute(page: NoodleRoute.page),
        AutoRoute(page: FMMarketRoute.page),
        AutoRoute(page: ProfileRoute.page),
        AutoRoute(page: BuyRoute.page),
        AutoRoute(page: DoggyExpressRoute.page),
        AutoRoute(page: DoggyExpressRouteRoute.page),
        AutoRoute(page: TruckTypeHelpRoute.page),
        AutoRoute(page: RouteMapRoute.page),
        AutoRoute(page: SNMRoute.page),
      ];
}
