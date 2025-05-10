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
          switch (context.read<InventoryBloc>().state) {
            case InventoryStateInitial():
              context
                  .read<InventoryBloc>()
                  .add(const InventoryEvent.listenInventoryRequested());
            default:
              break;
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
          Logger().e("Can't load config!", error: e, stackTrace: st);
          if (e is DioException) {
            final f = ServerFailure.fromError(e);
            switch (f) {
              case ServerFailureConnectionRefused():
                // context.router.replace(const OnMaintenanceRoute()),
                break;
              default:
                context
                    .read<NotificationsBloc>()
                    .add(NotificationsEvent.warningAdded(f.getMessage()));
            }
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
          error: (e, st) =>
              Logger().e('Purchase stream failure', error: e, stackTrace: st),
          loading: () {},
        );
      },
    );

    ServerFailure? failure;

    return MultiBlocListener(
      listeners: [
        BlocListener<NotificationsBloc, NotificationsState>(
          listener: (context, state) {
            switch (state) {
              case NotificationsStateInitial():
                break;
              case NotificationsStateSuccessReceived(:final message):
                Flushbar(
                  title: 'Success',
                  message: message,
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

              case NotificationsStateWarningReceived(:final message):
                Flushbar(
                  title: 'Warning',
                  message: message,
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

              case NotificationsStateReceived(:final title, :final message):
                Flushbar(
                  title: title,
                  message: message,
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
            }
          },
        ),
        BlocListener<GeolocationBloc, GeolocationState>(
          listener: (context, geolocationState) {
            switch (geolocationState) {
              case GeolocationStateInitial():
                break;
              case GeolocationStateLoadInProgress():
                break;
              case GeolocationStateLoadFailure():
                //    context.router.replace(const GeolocationRoute()),
                break;
              case GeolocationStateLoadSuccess():
                break;
            }
          },
        ),
        BlocListener<AuthBloc, AuthState>(
          listener: (context, authState) {
            switch (authState) {
              case AuthStateInitial():
                break;
              case AuthStateLoadInProgress():
                break;
              case AuthStateLoadFailure():
                // context.router.replace(const AuthRoute()),
                break;
              case AuthStateLoadSuccess():
                ref.invalidate(socketConnectionProvider);
            }
          },
        ),
        BlocListener<InventoryBloc, InventoryState>(
          listener: (context, state) {
            switch (state) {
              case InventoryStateInitial():
                break;
              case InventoryStateLoadInProgress():
                break;
              case InventoryStateLoadFailure():
                context.read<NotificationsBloc>().add(
                      const NotificationsEvent.warningAdded(
                        'Something went wrong on server',
                      ),
                    );
              case InventoryStateLoadSuccess():
                Logger().d('Inventory got successfully ✅');
            }
          },
        ),
      ],
      child: BlocBuilder<InventoryBloc, InventoryState>(
        builder: (context, inventoryState) {
          return BlocBuilder<AuthBloc, AuthState>(
            builder: (context, authState) =>
                BlocBuilder<GeolocationBloc, GeolocationState>(
              builder: (context, geoState) =>
                  BlocBuilder<EmojiBloc, EmojiState>(
                builder: (context, emojiState) {
                  final text = switch (authState) {
                    AuthStateInitial() => 'Login to your account...',
                    AuthStateLoadFailure() => 'Login to your account failed',
                    AuthStateLoadInProgress() => 'Login to your account...',
                    AuthStateLoadSuccess() => switch (geoState) {
                        GeolocationStateInitial() => 'Enable geolocation...',
                        GeolocationStateLoadInProgress() =>
                          'Enable geolocation...',
                        GeolocationStateLoadFailure() =>
                          'Enable geolocation failed',
                        GeolocationStateLoadSuccess() => switch (emojiState) {
                            EmojiStateInitial() => 'Loading emoji...',
                            EmojiStateLoadInProgress() => 'Loading emoji...',
                            EmojiStateLoadFailure() => 'Loading emoji failed',
                            EmojiStateLoadSuccess() => configState.map(
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
                                  data: (_) {
                                    return switch (inventoryState) {
                                      InventoryStateInitial() =>
                                        'Loading inventory...',
                                      InventoryStateLoadInProgress() =>
                                        'Loading inventory...',
                                      InventoryStateLoadFailure() =>
                                        'Loading inventory failed',
                                      InventoryStateLoadSuccess() =>
                                        socketConnectionState.when(
                                          error: (e, __) =>
                                              "Can't connect to the socket, reason: $e",
                                          loading: () =>
                                              'Connecting to the socket...',
                                          data: (_) => banState.when(
                                            data: (ban) {
                                              if (ban == null) return 'Done ✅';
                                              failure = ServerFailure.banned(
                                                  ban.reason);
                                              return failure!.getMessage();
                                            },
                                            error: (e, __) =>
                                                "Can't check user on bans, $e",
                                            loading: () => 'Done ✅',
                                          ),
                                        ),
                                    };
                                  },
                                ),
                              ),
                          }
                      },
                  };
                  Widget animatedWidget = switch (failure) {
                    ServerFailureBanned(:final reason) =>
                      BanPage(reason: reason),
                    _ => LoadingPage(text: text),
                  };

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
