import 'package:flutter/material.dart';
import 'package:nas_blog1/ui/pages/common/theme/my_color.dart';
import 'package:nas_blog1/ui/pages/common/theme/text_util.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  static const String version = 'v0.1.0';
  static const String email = 'hwidong0102@naver.com';
  // static const String github = 'GoldenBoylife';

  @override
  Widget build(BuildContext context) {
    return Container(
      color: MyColor.white,
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(40, 42, 40, 36),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(color: Colors.black.withOpacity(0.08)),
          const SizedBox(height: 28),

          Text(
            'GoldenBoy Lab',
            style: TextUtil.get24(context, Colors.black).copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: -0.4,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            'SLAM · Robotics · Embedded Systems · PetBot',
            style: TextUtil.get16(context, MyColor.gray80),
          ),

          const SizedBox(height: 22),

          Wrap(
            spacing: 18,
            runSpacing: 8,
            children: [
              _FooterText(text: 'Personal Dev Lab · $version'),
              const _FooterText(text: 'South Korea'),
              _FooterText(text: 'Email: $email'),
              // _FooterText(text: 'text: $text'),
            ],
          ),

          const SizedBox(height: 24),

          Text(
            '© 2026 GoldenBoy Lab. All rights reserved.',
            style: TextUtil.get14(context, MyColor.gray80),
          ),
        ],
      ),
    );
  }
}

class _FooterText extends StatelessWidget {
  final String text;

  const _FooterText({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextUtil.get14(context, MyColor.gray80),
    );
  }
}