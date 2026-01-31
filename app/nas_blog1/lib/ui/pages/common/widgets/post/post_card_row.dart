import 'package:flutter/material.dart';
import 'package:nas_blog1/models/post_meta.dart';
import 'package:nas_blog1/ui/pages/common/widgets/post/post_card.dart';

class PostCardRow extends StatelessWidget {
  final String title;
  final String? sub_title;

  final List<PostMeta> posts;
  final ValueChanged<PostMeta> on_tap;

  /// 한 줄에 보여줄 개수 제한(넘치면 가로 스크롤)
  final int limit;

  /// 카드 폭(고정)
  final double cardWidth;

  /// 카드 높이(고정)
  final double cardHeight;

  final double spacing;

  const PostCardRow({
    super.key,
    required this.title,
    this.sub_title,
    required this.posts,
    required this.on_tap,
    this.limit = 8,
    this.cardWidth = 320,
    this.cardHeight = 270,
    this.spacing = 16,
  });

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) return const SizedBox.shrink();

    final show = posts.take(limit).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Header(title: title, subtitle: sub_title),
        const SizedBox(height: 14),

        SizedBox(
          height: cardHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: show.length,
            separatorBuilder: (_, __) => SizedBox(width: spacing),
            itemBuilder: (context, i) {
              final p = show[i];
              return SizedBox(
                width: cardWidth,
                child: PostCard(
                  post: p,
                  on_tap: () => on_tap(p),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  final String title;
  final String? subtitle;
  const _Header({required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: t.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
        if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(subtitle!, style: t.bodyMedium?.copyWith(color: Colors.grey[700])),
        ],
      ],
    );
  }
}
