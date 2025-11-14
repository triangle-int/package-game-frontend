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
    _setupAppLifecycleHandling(ref);
    _setupStateListeners(ref, context);

    return MultiBlocListener(
      listeners: _buildBlocListeners(context),
      child: _buildBootstrapUI(context),
    );
  }

  // ============================================================================
  // App Lifecycle Management
  // ============================================================================

  void _setupAppLifecycleHandling(WidgetRef ref) {
    useOnAppLifecycleStateChange((previous, current) {
      if (current == AppLifecycleState.paused) {
        _handleAppPaused(ref);
      }
      if (current == AppLifecycleState.resumed &&
          previous == AppLifecycleState.paused) {
        _handleAppResumed(ref);
      }
    });
  }

  void _handleAppPaused(WidgetRef ref) {
    Logger().d('App paused - disconnecting socket');
    ref.read(socketConnectionProvider.notifier).disconnect();
    ref.invalidate(userProvider);
  }

  void _handleAppResumed(WidgetRef ref) {
    Logger().d('App resumed - reconnecting socket');
    ref.read(socketConnectionProvider.notifier).connect();
  }

  // ============================================================================
  // State Listeners Setup
  // ============================================================================

  void _setupStateListeners(WidgetRef ref, BuildContext context) {
    _listenToSocketConnection(ref);
    _listenToUser(ref, context);
    _listenToBan(ref);
    _listenToConfig(ref, context);
    _listenToPurchases(ref, context);
  }

  void _listenToSocketConnection(WidgetRef ref) {
    ref.listen<AsyncValue<void>>(socketConnectionProvider, (previous, next) {
      next.whenData((_) {
        ref.invalidate(banProvider);
        ref.invalidate(configProvider);
      });
    });
  }

  void _listenToUser(WidgetRef ref, BuildContext context) {
    ref.listen<AsyncValue<User>>(userProvider, (previous, next) {
      next.whenData((_) {
        // Only setup on initial user load, not subsequent updates
        if (previous?.hasValue ?? false) return;

        context
            .read<NotificationsBloc>()
            .add(const NotificationsEvent.setup());

        if (context.read<InventoryBloc>().state is InventoryStateInitial) {
          context
              .read<InventoryBloc>()
              .add(const InventoryEvent.listenInventoryRequested());
        }
      });
    });
  }

  void _listenToBan(WidgetRef ref) {
    ref.listen<AsyncValue<Ban?>>(banProvider, (previous, next) {
      if (next.value == null) {
        ref.invalidate(userProvider);
      }
    });
  }

  void _listenToConfig(WidgetRef ref, BuildContext context) {
    ref.listen<AsyncValue<Config>>(configProvider, (previous, next) {
      next.when(
        data: (_) => ref.invalidate(userProvider),
        error: (error, stackTrace) =>
            _handleConfigError(context, error, stackTrace),
        loading: () {},
      );
    });
  }

  void _handleConfigError(
      BuildContext context, Object error, StackTrace stackTrace) {
    Logger().e('Failed to load config', error: error, stackTrace: stackTrace);

    if (error is DioException) {
      final failure = ServerFailure.fromError(error);
      if (failure is! ServerFailureConnectionRefused) {
        _showWarning(context, failure.getMessage());
      }
    } else {
      _showWarning(context, error.toString());
    }
  }

  void _listenToPurchases(WidgetRef ref, BuildContext context) {
    ref.listen<AsyncValue<List<PurchaseDetails>>>(
      purchasesStreamProvider,
      (previous, next) {
        next.when(
          data: (purchases) => _handlePurchases(ref, context, purchases),
          error: (error, stackTrace) => Logger()
              .e('Purchase stream failure', error: error, stackTrace: stackTrace),
          loading: () {},
        );
      },
    );
  }

  Future<void> _handlePurchases(
    WidgetRef ref,
    BuildContext context,
    List<PurchaseDetails> purchases,
  ) async {
    final notificationsBloc = context.read<NotificationsBloc>();

    for (final purchase in purchases) {
      if (purchase.status == PurchaseStatus.pending) {
        continue;
      }

      await _processPurchase(ref, notificationsBloc, purchase);

      if (purchase.pendingCompletePurchase) {
        await InAppPurchase.instance.completePurchase(purchase);
      }
    }
  }

  Future<void> _processPurchase(
    WidgetRef ref,
    NotificationsBloc notificationsBloc,
    PurchaseDetails purchase,
  ) async {
    if (purchase.status == PurchaseStatus.error) {
      notificationsBloc.add(
        NotificationsEvent.warningAdded(purchase.error!.message),
      );
      return;
    }

    if (purchase.status == PurchaseStatus.purchased ||
        purchase.status == PurchaseStatus.restored) {
      final isValid = await ref
          .read(purchaseRepositoryProvider)
          .validateReceipt(purchase);

      if (!isValid) {
        notificationsBloc.add(
          const NotificationsEvent.warningAdded('Ya tvou mamu gebal'),
        );
      }
    }
  }

  // ============================================================================
  // BLoC Listeners
  // ============================================================================

  List<BlocListener> _buildBlocListeners(BuildContext context) {
    return [
      _buildNotificationsListener(),
      _buildGeolocationListener(),
      _buildAuthListener(context),
      _buildInventoryListener(context),
    ];
  }

  BlocListener<NotificationsBloc, NotificationsState>
      _buildNotificationsListener() {
    return BlocListener<NotificationsBloc, NotificationsState>(
      listener: (context, state) {
        switch (state) {
          case NotificationsStateSuccessReceived(:final message):
            _showNotificationFlushbar(
              context,
              title: 'Success',
              message: message,
              icon: const Icon(Icons.check_circle_outline,
                  color: Colors.green, size: 65),
            );
          case NotificationsStateWarningReceived(:final message):
            _showNotificationFlushbar(
              context,
              title: 'Warning',
              message: message,
              icon: Icon(Icons.error_outline,
                  color: Theme.of(context).primaryColor, size: 65),
            );
          case NotificationsStateReceived(:final title, :final message):
            _showNotificationFlushbar(
              context,
              title: title,
              message: message,
              icon: Icon(Icons.notifications,
                  color: Theme.of(context).primaryColor, size: 65),
            );
          case NotificationsStateInitial():
            break;
        }
      },
    );
  }

  BlocListener<GeolocationBloc, GeolocationState> _buildGeolocationListener() {
    return BlocListener<GeolocationBloc, GeolocationState>(
      listener: (context, state) {
        // Currently no special handling needed for geolocation state changes
        // Navigation is handled by _determineCurrentPage
      },
    );
  }

  BlocListener<AuthBloc, AuthState> _buildAuthListener(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, authState) {
        // Socket connection is invalidated in the listener to reconnect with new auth
        // This listener is intentionally left without implementation for now
        // as the invalidation happens in _setupStateListeners
      },
    );
  }

  BlocListener<InventoryBloc, InventoryState> _buildInventoryListener(
      BuildContext context) {
    return BlocListener<InventoryBloc, InventoryState>(
      listener: (context, state) {
        switch (state) {
          case InventoryStateLoadFailure():
            _showWarning(context, 'Something went wrong on server');
          case InventoryStateLoadSuccess():
            Logger().d('Inventory loaded successfully');
          default:
            break;
        }
      },
    );
  }

  // ============================================================================
  // UI Building
  // ============================================================================

  Widget _buildBootstrapUI(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) =>
          BlocBuilder<GeolocationBloc, GeolocationState>(
        builder: (context, geoState) =>
            BlocBuilder<EmojiBloc, EmojiState>(
          builder: (context, emojiState) =>
              BlocBuilder<InventoryBloc, InventoryState>(
            builder: (context, inventoryState) {
              return Consumer(
                builder: (context, ref, child) {
                  final configState = ref.watch(configProvider);
                  final userState = ref.watch(userProvider);
                  final socketState = ref.watch(socketConnectionProvider);
                  final banState = ref.watch(banProvider);

                  final bootstrapStep = _determineBootstrapStep(
                    authState: authState,
                    geoState: geoState,
                    emojiState: emojiState,
                    configState: configState,
                    userState: userState,
                    inventoryState: inventoryState,
                    socketState: socketState,
                    banState: banState,
                  );

                  return _buildPageForBootstrapStep(bootstrapStep);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  BootstrapStep _determineBootstrapStep({
    required AuthState authState,
    required GeolocationState geoState,
    required EmojiState emojiState,
    required AsyncValue<Config> configState,
    required AsyncValue<User> userState,
    required InventoryState inventoryState,
    required AsyncValue<void> socketState,
    required AsyncValue<Ban?> banState,
  }) {
    // Step 1: Authentication
    if (authState is AuthStateInitial || authState is AuthStateLoadInProgress) {
      return BootstrapStep.authenticating('Login to your account...');
    }
    if (authState is AuthStateLoadFailure) {
      return BootstrapStep.authFailed();
    }

    // Step 2: Socket connection (connect immediately after auth)
    return socketState.when(
      error: (error, _) => BootstrapStep.loading(
          "Can't connect to the socket, reason: $error"),
      loading: () =>
          BootstrapStep.connectingSocket('Connecting to the socket...'),
      data: (_) {
        // Step 3: Config
        return configState.when(
          loading: () => BootstrapStep.loadingConfig('Loading config...'),
          error: (_, __) => BootstrapStep.loading('Loading config failed'),
          data: (_) {
            // Step 4: Geolocation
            if (geoState is GeolocationStateInitial ||
                geoState is GeolocationStateLoadInProgress) {
              return BootstrapStep.enablingGeolocation('Enable geolocation...');
            }
            if (geoState is GeolocationStateLoadFailure) {
              return BootstrapStep.geolocationFailed();
            }

            // Step 5: Emoji
            if (emojiState is EmojiStateInitial ||
                emojiState is EmojiStateLoadInProgress) {
              return BootstrapStep.loadingEmoji('Loading emoji...');
            }
            if (emojiState is EmojiStateLoadFailure) {
              return BootstrapStep.loading('Loading emoji failed');
            }

            // Step 6: User
            return userState.when(
              loading: () => BootstrapStep.loadingUser('Loading user...'),
              error: (error, _) {
                if (error is DioException) {
                  final failure = ServerFailure.fromError(error);
                  if (failure is ServerFailurePlayerNotFound) {
                    return BootstrapStep.userNotFound();
                  }
                  return BootstrapStep.loadingWithFailure(
                      failure.getMessage(), failure);
                }
                return BootstrapStep.loading('Loading user failed: $error');
              },
              data: (_) {
                // Step 7: Inventory
                if (inventoryState is InventoryStateInitial ||
                    inventoryState is InventoryStateLoadInProgress) {
                  return BootstrapStep.loadingInventory('Loading inventory...');
                }
                if (inventoryState is InventoryStateLoadFailure) {
                  return BootstrapStep.loading('Loading inventory failed');
                }

                // Step 8: Ban check (final check before entering app)
                return banState.when(
                  data: (ban) {
                    if (ban != null) {
                      return BootstrapStep.banned(ban.reason);
                    }
                    return BootstrapStep.complete();
                  },
                  error: (error, _) =>
                      BootstrapStep.loading("Can't check user on bans, $error"),
                  // If ban status is still loading, allow user to proceed
                  // The ban will be checked in real-time via the socket stream
                  loading: () => BootstrapStep.complete(),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildPageForBootstrapStep(BootstrapStep step) {
    return switch (step) {
      BootstrapStepComplete() => const MapPage(),
      BootstrapStepAuthFailed() => const AuthPage(),
      BootstrapStepGeolocationFailed() => const GeolocationPage(),
      BootstrapStepUserNotFound() => const CreateUserPage(),
      BootstrapStepBanned(:final reason) => BanPage(reason: reason),
      BootstrapStepLoading(:final message) => LoadingPage(text: message),
      BootstrapStepLoadingWithFailure(:final message) =>
        LoadingPage(text: message),
    };
  }

  // ============================================================================
  // Helper Methods
  // ============================================================================

  void _showNotificationFlushbar(
    BuildContext context, {
    required String title,
    required String message,
    required Icon icon,
  }) {
    Flushbar(
      title: title,
      message: message,
      messageSize: 18,
      titleSize: 18,
      shouldIconPulse: false,
      icon: icon,
      padding: const EdgeInsets.only(top: 23, bottom: 23, left: 35),
      borderRadius: BorderRadius.circular(10),
      margin: const EdgeInsets.all(12),
      duration: const Duration(seconds: 5),
      flushbarPosition: FlushbarPosition.TOP,
    ).show(context);

    AudioPlayer().play(AssetSource('sounds/notification.wav'));
  }

  void _showWarning(BuildContext context, String message) {
    context
        .read<NotificationsBloc>()
        .add(NotificationsEvent.warningAdded(message));
  }
}

// ============================================================================
// Bootstrap Step Model
// ============================================================================

sealed class BootstrapStep {
  const BootstrapStep();

  factory BootstrapStep.authenticating(String message) =>
      BootstrapStepLoading(message);
  factory BootstrapStep.authFailed() => const BootstrapStepAuthFailed();
  factory BootstrapStep.enablingGeolocation(String message) =>
      BootstrapStepLoading(message);
  factory BootstrapStep.geolocationFailed() =>
      const BootstrapStepGeolocationFailed();
  factory BootstrapStep.loadingEmoji(String message) =>
      BootstrapStepLoading(message);
  factory BootstrapStep.loadingConfig(String message) =>
      BootstrapStepLoading(message);
  factory BootstrapStep.loadingUser(String message) =>
      BootstrapStepLoading(message);
  factory BootstrapStep.userNotFound() => const BootstrapStepUserNotFound();
  factory BootstrapStep.loadingInventory(String message) =>
      BootstrapStepLoading(message);
  factory BootstrapStep.connectingSocket(String message) =>
      BootstrapStepLoading(message);
  factory BootstrapStep.banned(String reason) =>
      BootstrapStepBanned(reason: reason);
  factory BootstrapStep.complete() => const BootstrapStepComplete();
  factory BootstrapStep.loading(String message) =>
      BootstrapStepLoading(message);
  factory BootstrapStep.loadingWithFailure(
          String message, ServerFailure failure) =>
      BootstrapStepLoadingWithFailure(message, failure);
}

class BootstrapStepLoading extends BootstrapStep {
  final String message;
  const BootstrapStepLoading(this.message);
}

class BootstrapStepLoadingWithFailure extends BootstrapStep {
  final String message;
  final ServerFailure failure;
  const BootstrapStepLoadingWithFailure(this.message, this.failure);
}

class BootstrapStepAuthFailed extends BootstrapStep {
  const BootstrapStepAuthFailed();
}

class BootstrapStepGeolocationFailed extends BootstrapStep {
  const BootstrapStepGeolocationFailed();
}

class BootstrapStepUserNotFound extends BootstrapStep {
  const BootstrapStepUserNotFound();
}

class BootstrapStepBanned extends BootstrapStep {
  final String reason;
  const BootstrapStepBanned({required this.reason});
}

class BootstrapStepComplete extends BootstrapStep {
  const BootstrapStepComplete();
}
