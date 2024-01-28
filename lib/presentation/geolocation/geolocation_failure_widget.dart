import 'package:flutter/material.dart';

class GeolocationFailureWidget extends StatelessWidget {
  final String errorTitle;
  final String buttonResolveText;
  final VoidCallback onPressed;

  const GeolocationFailureWidget({
    super.key,
    required this.onPressed,
    required this.errorTitle,
    required this.buttonResolveText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 58),
        Text(
          errorTitle,
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w500,
            fontSize: 18,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 22),
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(64),
            backgroundColor: Theme.of(context).primaryColor,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(130),
            ),
          ),
          child: Text(
            buttonResolveText,
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w500,
              fontSize: 32,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }
}
