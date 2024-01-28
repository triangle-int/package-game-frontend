import 'package:audioplayers/audioplayers.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BrowserBar extends StatelessWidget implements PreferredSizeWidget {
  final String link;
  final IconData icon;
  final bool? backButtonDisabled;

  const BrowserBar(
      {super.key,
      required this.link,
      required this.icon,
      this.backButtonDisabled,});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: const Color(0xFFF9F9F9),
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      iconTheme: const IconThemeData(
        color: Color(0xFFC5C5C5),
      ),
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(2.0),
        child: Container(
          color: const Color(0xFFD9D9D9),
          height: 2.0,
        ),
      ),
      title: Row(
        children: [
          IconButton(
            icon: Icon(icon),
            onPressed: () {
              if (!(backButtonDisabled ?? false)) {
                AudioPlayer().play(AssetSource('sounds/mouse_click.wav'));
                context.router.pop();
              }
            },
          ),
          Expanded(
            child: Container(
              height: 35,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFE2E2E2),
                borderRadius: BorderRadius.circular(25),
              ),
              alignment: Alignment.centerLeft,
              child: Text(
                link,
                style: const TextStyle(
                  color: Color(0xFF5B5B5B),
                  fontSize: 18,
                  fontFamily: 'Mukta Mahee',
                ),
              ),
            ),
          ),
          const SizedBox(width: 15)
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
