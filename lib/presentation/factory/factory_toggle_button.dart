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
    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: SizedBox(
        width: 100,
        height: 50,
        child: FittedBox(
          fit: BoxFit.fitWidth,
          child: Switch(
            onChanged: hasProductionItem
                ? (_) {
                    context.read<FactoryToggleBloc>().add(
                          FactoryToggleEvent.toggled(factoryBuilding),
                        );
                  }
                : null,
            // style: ElevatedButton.styleFrom(
            //   backgroundColor: hasProductionItem
            //       ? Theme.of(context).primaryColor
            //       : Theme.of(context).disabledColor,
            //   shape: RoundedRectangleBorder(
            //     borderRadius: BorderRadius.circular(130),
            //   ),
            //   fixedSize: const Size(145, 30),
            // ),
            value: enabled,
          ),
        ),
      ),
    );
  }
}
