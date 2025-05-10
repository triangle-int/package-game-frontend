import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_flutter/app_router.dart';
import 'package:package_flutter/bloc/auth/auth_bloc.dart';
import 'package:package_flutter/bloc/building/building_bloc.dart';
import 'package:package_flutter/bloc/connection/connection_bloc.dart';
import 'package:package_flutter/bloc/doggie_express/doggie_express_bloc.dart';
import 'package:package_flutter/bloc/emoji/emoji_bloc.dart';
import 'package:package_flutter/bloc/factory/upgrade/factory_upgrade_bloc.dart';
import 'package:package_flutter/bloc/fm_market/fm_search_bloc.dart';
import 'package:package_flutter/bloc/geolocation/geolocation_bloc.dart';
import 'package:package_flutter/bloc/inventory/inventory_bloc.dart';
import 'package:package_flutter/bloc/map/build_mode/build_mode_bloc.dart';
import 'package:package_flutter/bloc/notifications/notifications_bloc.dart';
import 'package:package_flutter/bloc/satellite/satellite_bloc.dart';
import 'package:package_flutter/bloc/truck/remove_schedule.dart/remove_schedule_bloc.dart';
import 'package:package_flutter/bloc/truck/truck_bloc.dart';
import 'package:package_flutter/bloc/tutorial/tutorial_bloc.dart';
import 'package:package_flutter/bloc/user/user_provider.dart';
import 'package:package_flutter/domain/auth/auth_repository.dart';
import 'package:package_flutter/domain/building/building_repository.dart';
import 'package:package_flutter/domain/connection/connection_repository.dart';
import 'package:package_flutter/domain/core/env_provider.dart';
import 'package:package_flutter/domain/emoji/emoji_repository.dart';
import 'package:package_flutter/domain/factory/factory_repository.dart';
import 'package:package_flutter/domain/fm_market/fm_market_repository.dart';
import 'package:package_flutter/domain/geolocation/geolocation_repository.dart';
import 'package:package_flutter/domain/inventory/inventory_repository.dart';
import 'package:package_flutter/domain/notifications/notifications_repository.dart';
import 'package:package_flutter/domain/satellite/satellite_repository.dart';
import 'package:package_flutter/domain/truck/truck_repository.dart';
import 'package:package_flutter/domain/tutorial/tutorial_repository.dart';
import 'package:package_flutter/domain/user/user_repository.dart';
import 'package:package_flutter/firebase_options.dart';
import 'package:package_flutter/presentation/core/root/sfx_volume.dart';
import 'package:package_flutter/theme.dart';
import 'package:wiredash/wiredash.dart';

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  // Caching
  // await FlutterMapTileCaching.initialise();

  // Firebase services
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  if (!kDebugMode) {
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  }
  // Audio settings
  // await AudioPlayer.global.changeLogLevel(LogLevel.none);
  final config = AudioContext(
    android: AudioContextAndroid(
      audioFocus: AndroidAudioFocus.none,
      contentType: AndroidContentType.sonification,
      isSpeakerphoneOn: false,
      usageType: AndroidUsageType.game,
    ),
    iOS: AudioContextIOS(
      category: AVAudioSessionCategory.ambient,
      options: {},
    ),
  );
  await AudioPlayer.global.setAudioContext(config);

  runApp(ProviderScope(child: App()));
}

class App extends HookConsumerWidget {
  App({super.key});

  final _appRouter = AppRouter();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              NotificationsBloc(ref.watch(notificationsRepositoryProvider)),
        ),
        BlocProvider(
          create: (context) => AuthBloc(ref.watch(authRepositoryProvider))
            ..add(const AuthEvent.listenAuthStatusRequested()),
        ),
        BlocProvider(
          create: (context) => GeolocationBloc(
            ref.watch(geolocationRepositoryProvider),
            ref.watch(userRepositoryProvider),
          )..add(const GeolocationEvent.listenGeolocationRequested()),
        ),
        BlocProvider(
          create: (context) => EmojiBloc(ref.watch(emojiRepositoryProvider))
            ..add(const EmojiEvent.emojisRequested()),
        ),
        BlocProvider(
          create: (context) =>
              InventoryBloc(ref.watch(inventoryRepositoryProvider)),
        ),
        BlocProvider(
          create: (context) =>
              BuildingBloc(ref.watch(buildingRepositoryProvider)),
        ),
        BlocProvider(
          create: (context) =>
              DoggieExpressBloc(ref.watch(truckRepositoryProvider)),
        ),
        BlocProvider(
          create: (context) => TruckBloc(ref.watch(truckRepositoryProvider))
            ..add(const TruckEvent.listenTrucksRequested()),
        ),
        BlocProvider(
          create: (context) =>
              ConnectionBloc(ref.watch(connectionRepositoryProvider)),
        ),
        BlocProvider(
          create: (context) =>
              RemoveScheduleBloc(ref.watch(truckRepositoryProvider)),
        ),
        BlocProvider(
          create: (context) =>
              FmSearchBloc(ref.watch(fmMarketRepositoryProvider)),
        ),
        BlocProvider(
          create: (context) =>
              FactoryUpgradeBloc(ref.watch(factoryRepositoryProvider)),
        ),
        BlocProvider(
          create: (context) =>
              BuildModeBloc(ref.watch(buildingRepositoryProvider)),
        ),
        BlocProvider(
          create: (context) =>
              SatelliteBloc(ref.watch(satelliteRepositoryProvider)),
        ),
        BlocProvider(
          create: (context) =>
              TutorialBloc(ref.watch(tutorialRepositoryProvider))
                ..add(const TutorialEvent.started()),
        ),
      ],
      child: Builder(
        builder: (context) {
          return Wiredash(
            projectId: ref.watch(envProvider).wiredashProjectId,
            secret: ref.watch(envProvider).wiredashSecretToken,
            theme: WiredashThemeData.fromColor(
              primaryColor: appTheme.primaryColor,
              brightness: Brightness.dark,
            ),
            feedbackOptions: WiredashFeedbackOptions(
              email: EmailPrompt.optional,
              collectMetaData: (metaData) async {
                final user = ref.read(userProvider).when(
                      loading: () => null,
                      error: (_, __) => null,
                      data: (data) => data,
                    );

                return metaData
                  ..userId = user?.id.toString()
                  ..custom['username'] = '${user?.avatar} ${user?.nickname}'
                  ..custom['user'] = user?.toString();
              },
            ),
            child: SfxVolumeWidget(
              child: MaterialApp.router(
                theme: appTheme,
                routerDelegate: _appRouter.delegate(),
                routeInformationParser: _appRouter.defaultRouteParser(),
              ),
            ),
          );
        },
      ),
    );
  }
}
