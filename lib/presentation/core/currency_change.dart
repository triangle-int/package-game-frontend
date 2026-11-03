import 'package:flutter/material.dart';
import 'package:package_flutter/presentation/core/transformers/currency_transformer.dart';

/// Shows a small currency delta at the widget that caused the transaction.
void showCurrencyChange(BuildContext context, BigInt amount) {
  final overlay = Overlay.maybeOf(context);
  final renderObject = context.findRenderObject();
  if (overlay == null || renderObject is! RenderBox) return;
  final overlayRenderObject = overlay.context.findRenderObject();
  if (overlayRenderObject is! RenderBox) return;
  final origin = overlayRenderObject.globalToLocal(
    renderObject.localToGlobal(Offset.zero),
  );
  _showCurrencyChange(overlay, origin, amount);
}

/// Shows a currency delta centered above a position in global coordinates.
void showCurrencyChangeAtGlobalPosition(
  BuildContext context,
  BigInt amount,
  Offset globalPosition,
) {
  final overlay = Overlay.maybeOf(context);
  final overlayRenderObject = overlay?.context.findRenderObject();
  if (overlay == null || overlayRenderObject is! RenderBox) return;
  final origin = overlayRenderObject.globalToLocal(globalPosition);
  _showCurrencyChange(overlay, origin, amount, centered: true);
}

void _showCurrencyChange(
  OverlayState overlay,
  Offset origin,
  BigInt amount, {
  bool centered = false,
}) {
  final entry = OverlayEntry(builder: (context) {
    return _CurrencyChangeBubble(
      origin: origin,
      text: '${amount >= BigInt.zero ? '+' : ''}${amount.toCurrency()} 💵',
      positive: amount >= BigInt.zero,
      centered: centered,
    );
  });
  overlay.insert(entry);
  Future<void>.delayed(const Duration(milliseconds: 1100), entry.remove);
}

class _CurrencyChangeBubble extends StatefulWidget {
  const _CurrencyChangeBubble({
    required this.origin,
    required this.text,
    required this.positive,
    required this.centered,
  });
  final Offset origin;
  final String text;
  final bool positive;
  final bool centered;

  @override
  State<_CurrencyChangeBubble> createState() => _CurrencyChangeBubbleState();
}

class _CurrencyChangeBubbleState extends State<_CurrencyChangeBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1000),
  )..forward();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.origin.dx,
      top: widget.origin.dy - 18,
      child: IgnorePointer(
        child: FractionalTranslation(
          translation: Offset(widget.centered ? -0.5 : 0, 0),
          child: FadeTransition(
            opacity: CurvedAnimation(parent: controller, curve: Curves.easeOut),
            child: SlideTransition(
              position: Tween<Offset>(
                begin: Offset.zero,
                end: const Offset(0, -0.8),
              ).animate(
                CurvedAnimation(parent: controller, curve: Curves.easeOut),
              ),
              child: Text(
                widget.text,
                style: TextStyle(
                  color: widget.positive
                      ? Colors.lightGreenAccent
                      : Colors.redAccent,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  shadows: const [Shadow(blurRadius: 3, color: Colors.black)],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
