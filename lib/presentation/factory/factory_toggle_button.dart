import 'package:package_flutter/l10n/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_flutter/bloc/factory/toggle/factory_toggle_bloc.dart';
import 'package:package_flutter/domain/building/building.dart';

class FactoryToggleButton extends StatelessWidget {
  const FactoryToggleButton({
    super.key,
    required this.factoryBuilding,
    required this.hasProductionItem,
    required this.enabled,
  });

  final FactoryBuilding factoryBuilding;
  final bool hasProductionItem;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message:
          translate(context, enabled ? 'Pause production' : 'Start production'),
      child: Switch(
        onChanged: hasProductionItem
            ? (_) => context.read<FactoryToggleBloc>().add(
                  FactoryToggleEvent.toggled(factoryBuilding),
                )
            : null,
        value: enabled,
      ),
    );
  }
}
