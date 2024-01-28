import 'package:another_flushbar/flushbar.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:auto_route/auto_route.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:logger/logger.dart';
import 'package:package_flutter/bloc/auth/auth_bloc.dart';
import 'package:package_flutter/bloc/ban/ban_provider.dart';
import 'package:package_flutter/bloc/config/config_provider.dart';
import 'package:package_flutter/bloc/emoji/emoji_bloc.dart';
import 'package:package_flutter/bloc/geolocation/geolocation_bloc.dart';
import 'package:package_flutter/bloc/inventory/inventory_bloc.dart';
import 'package:package_flutter/bloc/notifications/notifications_bloc.dart';
import 'package:package_flutter/bloc/purchase/purchases_stream_provider.dart';
import 'package:package_flutter/bloc/socket/socket_connection_provider.dart';
import 'package:package_flutter/bloc/user/user_provider.dart';
import 'package:package_flutter/domain/ban/ban.dart';
import 'package:package_flutter/domain/config/config.dart';
import 'package:package_flutter/domain/core/server_failure.dart';
import 'package:package_flutter/domain/purchase/purchase_repository.dart';
import 'package:package_flutter/domain/user/user.dart';
import 'package:package_flutter/presentation/auth/auth_page.dart';
import 'package:package_flutter/presentation/ban/ban_page.dart';
import 'package:package_flutter/presentation/geolocation/geolocation_page.dart';
import 'package:package_flutter/presentation/loading/loading_page.dart';
import 'package:package_flutter/presentation/map/map_page.dart';
import 'package:package_flutter/presentation/user/create_user_page.dart';

@RoutePage()
class LandingPage extends HookConsumerWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    useOnAppLifecycleStateChange((previous, current) {
      if (current == AppLifecycleState.paused) {
        Logger().d('Paused');
        ref.read(socketConnectionProvider.notifier).disconnect();
        ref.invalidate(userProvider);
      }
      if (current == AppLifecycleState.resumed &&
          previous == AppLifecycleState.paused) {
        Logger().d('Resumed after pausing');
        ref.read(socketConnectionProvider.notifier).connect();
      }
    });

    final userState = ref.watch(userProvider);
    final socketConnectionState = ref.watch(socketConnectionProvider);
    final banState = ref.watch(banProvider);
    final configState = ref.watch(configProvider);

    ref.listen<AsyncValue<void>>(socketConnectionProvider, (previous, next) {
      next.when(
        data: (data) {
          ref.invalidate(banProvider);
          ref.invalidate(configProvider);
        },
        error: (_, __) {},
        loading: () {},
      );
    });

    ref.listen<AsyncValue<User>>(userProvider, (previous, next) {
      next.map(
        loading: (_) {},
        error: (_) {},
        data: (_) {
          if (previous?.hasValue ?? false) return;

          context
              .read<NotificationsBloc>()
              .add(const NotificationsEvent.setup());
          if (context
              .read<InventoryBloc>()
              .state
              .maybeMap(initial: (_) => true, orElse: () => false)) {
            context
                .read<InventoryBloc>()
                .add(const InventoryEvent.listenInventoryRequested());
          }
        },
      );
    });

    ref.listen<AsyncValue<Ban?>>(banProvider, (previous, next) {
      if (next.value == null) {
        ref.invalidate(userProvider);
      }
    });

    ref.listen<AsyncValue<Config>>(configProvider, (previous, next) {
      next.when(
        data: (d) {
          ref.invalidate(userProvider);
        },
        error: (e, st) {
          Logger().e("Can't load config!", e, st);
          if (e is DioException) {
            final f = ServerFailure.fromError(e);
            f.maybeMap(
              connectionRefused: (_) {},
              // context.router.replace(const OnMaintenanceRoute()),
              orElse: () => context
                  .read<NotificationsBloc>()
                  .add(NotificationsEvent.warningAdded(f.getMessage())),
            );
            return;
          }

          context
              .read<NotificationsBloc>()
              .add(NotificationsEvent.warningAdded(e.toString()));
        },
        loading: () {},
      );
    });

    ref.listen<AsyncValue<List<PurchaseDetails>>>(
      purchasesStreamProvider,
      (previous, next) {
        next.when(
          data: (data) async {
            for (PurchaseDetails purchaseDetails in data) {
              if (purchaseDetails.status == PurchaseStatus.pending) {
                // _showPendingUI();
              } else {
                final notificationBloc = context.read<NotificationsBloc>();
                if (purchaseDetails.status == PurchaseStatus.error) {
                  notificationBloc.add(
                    NotificationsEvent.warningAdded(
                      purchaseDetails.error!.message,
                    ),
                  );
                } else if (purchaseDetails.status == PurchaseStatus.purchased ||
                    purchaseDetails.status == PurchaseStatus.restored) {
                  final valid = await ref
                      .read(purchaseRepositoryProvider)
                      .validateReceipt(purchaseDetails);
                  if (!valid) {
                    notificationBloc.add(
                      const NotificationsEvent.warningAdded(
                        'Ya tvou mamu gebal',
                      ),
                    );
                  }
                }
                if (purchaseDetails.pendingCompletePurchase) {
                  await InAppPurchase.instance
                      .completePurchase(purchaseDetails);
                }
              }
            }
          },
          error: (e, st) => Logger().e('Purchase stream failure', e, st),
          loading: () {},
        );
      },
    );

    ServerFailure? failure;

    return MultiBlocListener(
      listeners: [
        BlocListener<NotificationsBloc, NotificationsState>(
          listener: (context, state) {
            state.map(
              initial: (_) {},
              successNotificationReceived: (s) {
                Flushbar(
                  title: 'Success',
                  message: s.message,
                  messageSize: 18,
                  titleSize: 18,
                  shouldIconPulse: false,
                  icon: const Icon(
                    Icons.check_circle_outline,
                    color: Colors.green,
                    size: 65,
                  ),
                  padding: const EdgeInsets.only(
                    top: 23,
                    bottom: 23,
                    left: 35,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  margin: const EdgeInsets.all(12),
                  duration: const Duration(seconds: 5),
                  flushbarPosition: FlushbarPosition.TOP,
                ).show(context);
                AudioPlayer().play(AssetSource('sounds/notification.wav'));
              },
              warningNotificationReceived: (s) {
                Flushbar(
                  title: 'Warning',
                  message: s.message,
                  messageSize: 18,
                  titleSize: 18,
                  shouldIconPulse: false,
                  icon: Icon(
                    Icons.error_outline,
                    color: Theme.of(context).primaryColor,
                    size: 65,
                  ),
                  padding: const EdgeInsets.only(
                    top: 23,
                    bottom: 23,
                    left: 35,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  margin: const EdgeInsets.all(12),
                  duration: const Duration(seconds: 5),
                  flushbarPosition: FlushbarPosition.TOP,
                ).show(context);
                AudioPlayer().play(AssetSource('sounds/notification.wav'));
              },
              notificationReceived: (s) {
                Flushbar(
                  title: s.title,
                  message: s.message,
                  messageSize: 18,
                  titleSize: 18,
                  shouldIconPulse: false,
                  icon: Icon(
                    Icons.notifications,
                    color: Theme.of(context).primaryColor,
                    size: 65,
                  ),
                  padding: const EdgeInsets.only(
                    top: 23,
                    bottom: 23,
                    left: 35,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  margin: const EdgeInsets.all(12),
                  duration: const Duration(seconds: 5),
                  flushbarPosition: FlushbarPosition.TOP,
                ).show(context);
                AudioPlayer().play(AssetSource('sounds/notification.wav'));
              },
            );
          },
        ),
        BlocListener<GeolocationBloc, GeolocationState>(
          listener: (context, geolocationState) {
            geolocationState.map(
              initial: (_) {},
              loadInProgress: (_) {},
              loadFailure: (s) {},
              //    context.router.replace(const GeolocationRoute()),
              loadSuccess: (_) {},
            );
          },
        ),
        BlocListener<AuthBloc, AuthState>(
          listener: (context, authState) {
            authState.map(
              initial: (_) {},
              loadInProgress: (_) {},
              loadFailure: (_) {}, // context.router.replace(const AuthRoute()),
              loadSuccess: (_) {
                ref.invalidate(socketConnectionProvider);
              },
            );
          },
        ),
        BlocListener<InventoryBloc, InventoryState>(
          listener: (context, state) => state.map<void>(
            initial: (s) {},
            loadInProgress: (s) {},
            loadFailure: (s) => s.failure.map<void>(
              serverFailure: (_) => context.read<NotificationsBloc>().add(
                    const NotificationsEvent.warningAdded(
                      'Something went wrong on server',
                    ),
                  ),
            ),
            loadSuccess: (s) {
              Logger().d('Inventory got successfully ✅');
            },
          ),
        )
      ],
      child: BlocBuilder<InventoryBloc, InventoryState>(
        builder: (context, inventoryState) {
          return BlocBuilder<AuthBloc, AuthState>(
            builder: (context, authState) =>
                BlocBuilder<GeolocationBloc, GeolocationState>(
              builder: (context, geoState) =>
                  BlocBuilder<EmojiBloc, EmojiState>(
                builder: (context, emojiState) {
                  final text = authState.map(
                    initial: (_) => 'Login to your account...',
                    loadFailure: (_) => 'Login to your account failed',
                    loadInProgress: (_) => 'Login to your account...',
                    loadSuccess: (_) => geoState.map(
                      initial: (_) => 'Enable geolocation...',
                      loadInProgress: (_) => 'Enable geolocation...',
                      loadFailure: (_) => 'Enable geolocation failed',
                      loadSuccess: (_) => emojiState.map(
                        initial: (_) => 'Loading emoji...',
                        loadInProgress: (_) => 'Loading emoji...',
                        loadFailure: (_) => 'Loading emoji failed',
                        loadSuccess: (_) => configState.map(
                          loading: (_) => 'Loading config...',
                          error: (_) => 'Loading config failed',
                          data: (_) => userState.map(
                            loading: (_) => 'Loading user...',
                            error: (s) {
                              if (s.error is DioException) {
                                final f = ServerFailure.fromError(
                                  s.error as DioException,
                                );

                                failure = f;

                                return f.getMessage();
                              }
                              return 'Loading user failed: ${s.error}';
                            },
                            data: (_) => inventoryState.map(
                              initial: (_) => 'Loading inventory...',
                              loadInProgress: (_) => 'Loading inventory...',
                              loadFailure: (_) => 'Loading inventory failed',
                              loadSuccess: (_) => socketConnectionState.when(
                                error: (e, __) =>
                                    "Can't connect to the socket, reason: $e",
                                loading: () => 'Connecting to the socket...',
                                data: (_) => banState.when(
                                  data: (ban) {
                                    if (ban == null) return 'Done ✅';
                                    failure = ServerFailure.banned(ban.reason);
                                    return failure!.getMessage();
                                  },
                                  error: (e, __) =>
                                      "Can't check user on bans, $e",
                                  loading: () => 'Done ✅',
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                  Widget animatedWidget = failure?.mapOrNull(
                        banned: (f) => BanPage(reason: f.reason),
                      ) ??
                      LoadingPage(text: text);

                  if (text == 'Done ✅') {
                    animatedWidget = const MapPage();
                  }

                  if (text == 'Login to your account failed') {
                    animatedWidget = const AuthPage();
                  }

                  if (text == 'Enable geolocation failed') {
                    animatedWidget = const GeolocationPage();
                  }

                  if (text == 'Player not found') {
                    animatedWidget = const CreateUserPage();
                  }

                  return animatedWidget;
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
