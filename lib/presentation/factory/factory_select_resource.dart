import 'package:package_flutter/l10n/app_text.dart';
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
              AppText(
                'Choose the production line. You cannot change it later; upgrades can change the resource produced. Send output to a warehouse, then to a market. Running the factory has a recurring fee.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              const Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  SelectResourceButton(resourceName: 'wheel'),
                  SelectResourceButton(resourceName: 'long_drum'),
                  SelectResourceButton(resourceName: 'mail'),
                  SelectResourceButton(resourceName: 'ring_buoy'),
                  SelectResourceButton(resourceName: 'wheat'),
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
                  onPressed: state.resource.isEmpty
                      ? null
                      : () => context.read<FactoryResourceBloc>().add(
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
                  child: const AppText(
                    'Confirm resource',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 9),
              const AppText(
                'Select a resource, then confirm',
                style: TextStyle(
                  fontSize: 14,
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
