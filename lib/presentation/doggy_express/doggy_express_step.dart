import 'package:package_flutter/l10n/app_text.dart';
import 'package:flutter/material.dart';

class DoggyExpressStep extends StatelessWidget {
  final String text;
  final Widget? child;
  final Widget? questionMark;
  final EdgeInsetsGeometry? padding;
  final double titleSize;

  const DoggyExpressStep({
    super.key,
    required this.text,
    this.titleSize = 18,
    this.padding,
    this.questionMark,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Divider(
          height: 2,
          color: Color(0xFFD4352F),
          thickness: 4,
        ),
        SizedBox(
          height: 56,
          child: Stack(
            children: [
              Center(
                child: AppText(
                  text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: titleSize,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF333363),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: questionMark,
              )
            ],
          ),
        ),
        Container(
          color: const Color(0xFF333363),
          padding: padding,
          child: child,
        ),
      ],
    );
  }
}
