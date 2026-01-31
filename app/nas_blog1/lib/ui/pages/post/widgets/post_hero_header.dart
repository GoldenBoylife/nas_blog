import 'package:flutter/material.dart';

class PostHeroHeader extends StatelessWidget {
  final String title;
  final String categoryName;
  // final String? coverUrl;

  const PostHeroHeader({
    required this.title,
    required this.categoryName,
    // this.coverUrl,
  });

  @override
  Widget build(BuildContext context) {
    // coverUrl이 있으면 NetworkImage로 바꾸고,
    // 없으면 단색/기본 이미지로 처리
    return Container(
      height: 240,
      width: double.infinity,
      decoration: BoxDecoration(
        // image: coverUrl == null ? null : DecorationImage(...)
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
        ),
      ),
      child: Stack(
        children: [
          // 어두운 오버레이 느낌
          Container(color: Colors.black.withOpacity(0.20)),

          Align(
            alignment: Alignment.bottomCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 980),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 카테고리 라벨
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        categoryName,
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // 타이틀
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
