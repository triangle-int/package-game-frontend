import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_flutter/bloc/factory/factory_bloc.dart';
import 'package:package_flutter/bloc/factory/resource/factory_resource_bloc.dart';
import 'package:package_flutter/bloc/notifications/notifications_bloc.dart';
import 'package:package_flutter/bloc/tutorial/tutorial_bloc.dart';
import 'package:package_flutter/domain/factory/factory_repository.dart';
import 'package:package_flutter/domain/factory/factory_resource_select_failure.dart';
import 'package:package_flutter/presentation/factory/select_resource_button.dart';

class FactorySelectResource extends HookConsumerWidget {
  final int factoryId;

  const FactorySelectResource({super.key, required this.factoryId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BlocProvider(
      create: (context) =>
          FactoryResourceBloc(ref.watch(factoryRepositoryProvider)),
      child: BlocConsumer<FactoryResourceBloc, FactoryResourceState>(
        listener: (context, state) {
          if (state.failureOrNull != null) {
            context.read<NotificationsBloc>().add(
                  NotificationsEvent.warningAdded(
                    switch (state.failureOrNull!) {
                      FactoryResourceSelectFailureFactoryNotFound() =>
                        'Resource for this factory already selected',
                      FactoryResourceSelectFailureResourceNotSelected() =>
                        'Resource not selected',
                      FactoryResourceSelectFailureServerFailure() =>
                        'Something went wrong on server',
                      FactoryResourceSelectFailureUnexpectedFailure() =>
                        'Something went wrong on client',
                    },
                  ),
                );
          }
          if (state.factoryOrNull != null) {
            context
                .read<TutorialBloc>()
                .add(const TutorialEvent.resourceSelected());
            context
                .read<FactoryBloc>()
                .add(FactoryEvent.factoryGot(state.factoryOrNull!));
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              const SizedBox(height: 18),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SelectResourceButton(
                    resourceName: 'wheel',
                  ),
                  SizedBox(width: 20),
                  SelectResourceButton(
                    resourceName: 'long_drum',
                  ),
                  SizedBox(width: 20),
                  SelectResourceButton(
                    resourceName: 'mail',
                  ),
                ],
              ),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SelectResourceButton(
                    resourceName: 'ring_buoy',
                  ),
                  SizedBox(width: 20),
                  SelectResourceButton(
                    resourceName: 'wheat',
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (state.isLoading) ...[
                const SizedBox(
                  height: 49,
                  width: 49,
                  child: CircularProgressIndicator(),
                ),
              ] else ...[
                ElevatedButton(
                  onPressed: () => context.read<FactoryResourceBloc>().add(
                        FactoryResourceEvent.confirmed(
                          factoryId,
                        ),
                      ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(130),
                    ),
                    fixedSize: const Size(240, 49),
                  ),
                  child: const Text(
                    'Choose',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 9),
              const Text(
                'Choose a branch to produce',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
