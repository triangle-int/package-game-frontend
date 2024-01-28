import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_flutter/bloc/geolocation/geolocation_bloc.dart';
import 'package:package_flutter/presentation/core/package_title.dart';
import 'package:package_flutter/presentation/geolocation/geolocation_failure_widget.dart';
import 'package:package_flutter/presentation/loading/loader.dart';

class GeolocationPage extends StatelessWidget {
  const GeolocationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<GeolocationBloc, GeolocationState>(
      listener: (context, state) {
        state.maybeMap(
          loadSuccess: (_) {},
          orElse: () {},
        );
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
                  builder: (context, state) => state.maybeMap(
                    loadFailure: (state) => state.failure.when(
                      permissionDenied: () => GeolocationFailureWidget(
                        onPressed: () => context
                            .read<GeolocationBloc>()
                            .add(const GeolocationEvent.requestPermission()),
                        errorTitle: 'You may not have provided GPS access.',
                        buttonResolveText: 'Grant access',
                      ),
                      serviceDisabled: () => GeolocationFailureWidget(
                        onPressed: () => context
                            .read<GeolocationBloc>()
                            .add(const GeolocationEvent.openLocationSettings()),
                        errorTitle: 'Geolocation may be disabled on the device',
                        buttonResolveText: 'Open settings',
                      ),
                      permissionDeniedForever: () => GeolocationFailureWidget(
                        onPressed: () => context
                            .read<GeolocationBloc>()
                            .add(const GeolocationEvent.openAppSettings()),
                        errorTitle: 'You may not have provided GPS access.',
                        buttonResolveText: 'Open settings',
                      ),
                      reducedAccuracy: () => GeolocationFailureWidget(
                        onPressed: () => context
                            .read<GeolocationBloc>()
                            .add(const GeolocationEvent.openAppSettings()),
                        errorTitle:
                            'You may have specified a reduced geolocation',
                        buttonResolveText: 'Open settings',
                      ),
                      unknown: () => GeolocationFailureWidget(
                        onPressed: () => context.read<GeolocationBloc>().add(
                              const GeolocationEvent
                                  .listenGeolocationRequested(),
                            ),
                        errorTitle:
                            'Unknown error occurred while trying to access GPS',
                        buttonResolveText: 'Retry',
                      ),
                      noSignal: () => GeolocationFailureWidget(
                        onPressed: () => context.read<GeolocationBloc>().add(
                              const GeolocationEvent
                                  .listenGeolocationRequested(),
                            ),
                        errorTitle:
                            'No signal from the GPS receiver. Please check your connection.',
                        buttonResolveText: 'Retry',
                      ),
                    ),
                    orElse: () => const Loader(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
