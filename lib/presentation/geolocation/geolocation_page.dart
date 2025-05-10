import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_flutter/bloc/geolocation/geolocation_bloc.dart';
import 'package:package_flutter/domain/geolocation/geolocation_failure.dart';
import 'package:package_flutter/presentation/core/package_title.dart';
import 'package:package_flutter/presentation/geolocation/geolocation_failure_widget.dart';
import 'package:package_flutter/presentation/loading/loader.dart';

class GeolocationPage extends StatelessWidget {
  const GeolocationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<GeolocationBloc, GeolocationState>(
      listener: (context, state) {
        switch (state) {
          case GeolocationStateLoadSuccess():
            break;
          case GeolocationStateLoadFailure():
            break;
          case GeolocationStateLoadInProgress():
            break;
          case GeolocationStateInitial():
            break;
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: PackageTitle(
            child: Column(
              children: [
                const Text(
                  'Satellite access lost',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w500,
                    fontSize: 32,
                  ),
                ),
                const SizedBox(height: 58),
                BlocBuilder<GeolocationBloc, GeolocationState>(
                  builder: (context, state) => switch (state) {
                    GeolocationStateLoadFailure(:final failure) => switch (
                          failure) {
                        GeolocationFailurePermissionDenied() =>
                          GeolocationFailureWidget(
                            onPressed: () => context
                                .read<GeolocationBloc>()
                                .add(
                                    const GeolocationEvent.requestPermission()),
                            errorTitle: 'You may not have provided GPS access.',
                            buttonResolveText: 'Grant access',
                          ),
                        GeolocationFailureServiceDisabled() =>
                          GeolocationFailureWidget(
                            onPressed: () => context
                                .read<GeolocationBloc>()
                                .add(const GeolocationEvent
                                    .openLocationSettings()),
                            errorTitle:
                                'Geolocation may be disabled on the device',
                            buttonResolveText: 'Open settings',
                          ),
                        GeolocationFailurePermissionDeniedForever() =>
                          GeolocationFailureWidget(
                            onPressed: () => context
                                .read<GeolocationBloc>()
                                .add(const GeolocationEvent.openAppSettings()),
                            errorTitle: 'You may not have provided GPS access.',
                            buttonResolveText: 'Open settings',
                          ),
                        GeolocationFailureReducedAccuracy() =>
                          GeolocationFailureWidget(
                            onPressed: () => context
                                .read<GeolocationBloc>()
                                .add(const GeolocationEvent.openAppSettings()),
                            errorTitle:
                                'You may have specified a reduced geolocation',
                            buttonResolveText: 'Open settings',
                          ),
                        GeolocationFailureUnknown() => GeolocationFailureWidget(
                            onPressed: () =>
                                context.read<GeolocationBloc>().add(
                                      const GeolocationEvent
                                          .listenGeolocationRequested(),
                                    ),
                            errorTitle:
                                'Unknown error occurred while trying to access GPS',
                            buttonResolveText: 'Retry',
                          ),
                        GeolocationFailureNoSignal() =>
                          GeolocationFailureWidget(
                            onPressed: () =>
                                context.read<GeolocationBloc>().add(
                                      const GeolocationEvent
                                          .listenGeolocationRequested(),
                                    ),
                            errorTitle:
                                'No signal from the GPS receiver. Please check your connection.',
                            buttonResolveText: 'Retry',
                          ),
                      },
                    GeolocationStateLoadInProgress() => const Loader(),
                    GeolocationStateInitial() => const Loader(),
                    GeolocationStateLoadSuccess() => const Loader(),
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
