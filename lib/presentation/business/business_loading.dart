import 'package:flutter/material.dart';
import 'package:package_flutter/presentation/core/emoji_image.dart';
import 'package:shimmer/shimmer.dart';

class BusinessLoading extends StatelessWidget {
  const BusinessLoading({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    const baseColor = Color(0xFF585858);
    const highlightColor = Color(0xFF777777);

    return SizedBox(
      height: 312 + 60,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            color: Theme.of(context).colorScheme.background,
            height: 312,
            width: double.infinity,
            padding: const EdgeInsets.only(top: 60 + 12),
            child: Shimmer.fromColors(
              baseColor: baseColor,
              highlightColor: highlightColor,
              child: Column(
                children: [
                  // const Text(
                  //   'Level 21',
                  //   textAlign: TextAlign.center,
                  //   style: TextStyle(
                  //     fontFamily: 'Sansation',
                  //     fontSize: 48,
                  //   ),
                  // ),
                  const SizedBox(height: 10),
                  Container(
                    height: 48,
                    width: 250,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 15),
                  // const Text(
                  //   'income: 20K(2K taxes)',
                  //   style: TextStyle(
                  //     fontWeight: FontWeight.w500,
                  //     fontSize: 24,
                  //   ),
                  // ),
                  Container(
                    height: 24,
                    width: 280,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 15),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 22, vertical: 10,),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(37),
                      ),
                    ),
                    child: const Text(
                      'upgrade 999M🍄',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 24,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          Positioned(
            top: 0,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.background,
                border: Border.all(
                  width: 12,
                  color: baseColor,
                ),
              ),
              padding: const EdgeInsets.all(20),
              child: Shimmer.fromColors(
                baseColor: baseColor,
                highlightColor: highlightColor,
                child: const EmojiImage(emoji: '🏠'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
