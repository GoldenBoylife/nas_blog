import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';

class SiteBrand extends StatelessWidget {
  final bool compact;

  const SiteBrand({
    super.key,
    this.compact = false,
  });

  static const Color golden = Color(0xFFD69A13);
  static const Color boyBlack = Color(0xFF202124);
  static const Color labGray = Color(0xFF777777);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Beamer.of(context).beamToNamed('/'),
      borderRadius: BorderRadius.circular(999),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: compact ? 42 : 50,
              height: compact ? 42 : 50,
              child: Image.asset(
                'assets/logo.png',
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
              ),
            ),
            if (!compact) ...[
              const SizedBox(width: 10),
              RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: 'Golden',
                      style: TextStyle(
                        fontFamily: 'Audiowide',
                        fontSize: 22,
                        color: golden,
                        letterSpacing: -0.8,
                      ),
                    ),
                    TextSpan(
                      text: 'Boy',
                      style: TextStyle(
                        fontFamily: 'Audiowide',
                        fontSize: 22,
                        color: boyBlack,
                        letterSpacing: -0.8,
                      ),
                    ),
                    TextSpan(
                      text: ' Lab',
                      style: TextStyle(
                        fontFamily: 'Audiowide',
                        fontSize: 15,
                        color: labGray,
                        letterSpacing: -0.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}