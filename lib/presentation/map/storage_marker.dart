import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_flutter/bloc/user/user_provider.dart';
import 'package:package_flutter/domain/building/building.dart';

class StorageMarker extends HookConsumerWidget {
  const StorageMarker({
    super.key,
    required this.iconName,
    required this.storage,
  });

  final StorageBuilding storage;
  final String iconName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider).value!;

    return Stack(
      alignment: AlignmentDirectional.topCenter,
      children: [
        if (user.id == storage.ownerId)
          Text(
            (storage.level + 1).toString(),
            style: const TextStyle(
              fontSize: 10,
            ),
          ),
        Image.asset(
          'assets/images/buildings/$iconName.png',
        ),
      ],
    );
  }
}
