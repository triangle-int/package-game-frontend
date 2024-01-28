import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:package_flutter/presentation/doggy_express/route_button.dart';

class DoggyExpressRouteHeader extends StatelessWidget {
  const DoggyExpressRouteHeader({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 182,
      color: const Color(0xFF333363),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Choose a route',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
            ),
            const Text(
              'First select the starting point, then the final destination',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const RouteButton(
                  isStart: true,
                ),
                const SizedBox(width: 30),
                OutlinedButton(
                  onPressed: () => context.router.pop(),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(184, 45),
                    foregroundColor: Colors.white,
                    side: const BorderSide(
                      color: Colors.white,
                      width: 2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: const Text(
                    'CONFIRM',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 30),
                const RouteButton(
                  isStart: false,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
