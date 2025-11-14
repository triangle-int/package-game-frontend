import 'package:flutter/material.dart';

class InventoryLevel extends StatelessWidget {
  const InventoryLevel({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 35,
        width: 371,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.all(Radius.circular(11)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: [
            Expanded(
              child: Container(
                height: 5,
                decoration: const BoxDecoration(
                  color: Color(0xFF2F67FF),
                  borderRadius: BorderRadius.all(Radius.circular(11)),
                ),
              ),
            ),
            const SizedBox(width: 16),
            const Text(
              'Level 1',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
