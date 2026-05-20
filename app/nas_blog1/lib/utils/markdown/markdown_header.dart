import 'package:flutter/material.dart';

const Color gbText = Color(0xFF111827);
const Color gbSubText = Color(0xFF374151);

const Color gbNavy = Color(0xFF1E293B);
const Color gbBlue = Color(0xFF2563EB);
const Color gbAccent = Color(0xFFF59E0B);
const Color gbAccentSoft = Color(0xFFFFF7E6);

class BlogHeaderStyles {
  static const h1 = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.w900,
    height: 1.25,
    color: gbText,
    letterSpacing: -0.8,
  );

  static const h2 = TextStyle(
    fontSize: 25,
    fontWeight: FontWeight.w900,
    height: 1.35,
    color: gbNavy,
    letterSpacing: -0.5,
  );

  static const h3 = TextStyle(
    fontSize: 21,
    fontWeight: FontWeight.w800,
    height: 1.4,
    color: gbBlue,
    letterSpacing: -0.35,
  );

  static const h4 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w800,
    height: 1.25,
    color: Color(0xFF92400E),
    letterSpacing: -0.2,
  );

  static const h5 = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: gbSubText,
  );

  static const h6 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: Color(0xFF6B7280),
  );
}

class BlogHeadingData {
  final int level;
  final String text;

  const BlogHeadingData({
    required this.level,
    required this.text,
  });
}

class BlogHeading extends StatelessWidget {
  final BlogHeadingData data;

  const BlogHeading({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    switch (data.level) {
      case 1:
        return _buildH1(data.text);
      case 2:
        return _buildH2(data.text);
      case 3:
        return _buildH3(data.text);
      case 4:
        return _buildH4(data.text);
      default:
        return _buildDefault(data.text);
    }
  }

  Widget _buildH1(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 28, bottom: 18),
      child: Text(
        text,
        style: BlogHeaderStyles.h1,
      ),
    );
  }

  Widget _buildH2(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 34, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 9,
                height: 9,
                decoration: const BoxDecoration(
                  color: gbAccent,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  text,
                  style: BlogHeaderStyles.h2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            height: 2,
            width: 72,
            decoration: BoxDecoration(
              color: gbAccent,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildH3(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 28, bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 4,
            height: 24,
            decoration: BoxDecoration(
              color: gbBlue,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: BlogHeaderStyles.h3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildH4(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 22, bottom: 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: gbAccentSoft,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: const Color(0xFFFCD34D),
              width: 1,
            ),
          ),
          child: Text(
            text,
            style: BlogHeaderStyles.h4,
          ),
        ),
      ),
    );
  }

  Widget _buildDefault(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: gbText,
        ),
      ),
    );
  }
}