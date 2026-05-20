import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart' as fm;

import 'package:nas_blog1/utils/markdown/markdown_youtube.dart';
import 'package:nas_blog1/utils/markdown/markdown_image_builder.dart';


enum BlogAsideKind {
  simple,
  tip,
  warning,
  info,
  problem,
  note,
  done,
  result,
}


class BlogAsideData {
  final BlogAsideKind kind;
  final String title;
  final String icon;
  final String body;
  final bool hasTitle;

  const BlogAsideData({
    required this.kind,
    required this.title,
    required this.icon,
    required this.body,
    required this.hasTitle,
  });
}


class BlogAside extends StatelessWidget {
  final BlogAsideData data;
  final fm.MarkdownStyleSheet styleSheet;
  final bool selectable;
  final double maxWidth;

  const BlogAside({
    super.key,
    required this.data,
    required this.styleSheet,
    required this.maxWidth,
    this.selectable = false,
  });

  @override
  Widget build(BuildContext context) {
    if (!data.hasTitle) {
      return _SimpleAside(
        data: data,
        styleSheet: styleSheet,
        selectable: selectable,
        maxWidth: maxWidth,
      );
    }

    return _TitledAside(
      data: data,
      styleSheet: styleSheet,
      selectable: selectable,
      maxWidth: maxWidth,
    );
  }
}

class _AsidePalette {
  final Color accent;
  final Color headerBg;
  final Color bodyBg;
  final Color titleText;
  final Color bodyText;

  const _AsidePalette({
    required this.accent,
    required this.headerBg,
    required this.bodyBg,
    required this.titleText,
    required this.bodyText,
  });
}

_AsidePalette _palette(BlogAsideKind kind) {
  switch (kind) {
    case BlogAsideKind.warning:
    case BlogAsideKind.problem:
      return const _AsidePalette(
        accent: Color(0xFFEF4444),
        headerBg: Color(0xFFFFF1F2),
        bodyBg: Color(0xFFFFFBFB),
        titleText: Color(0xFFDC2626),
        bodyText: Color(0xFF374151),
      );

    case BlogAsideKind.info:
      return const _AsidePalette(
        accent: Color(0xFF3B82F6),
        headerBg: Color(0xFFEFF6FF),
        bodyBg: Color(0xFFF8FBFF),
        titleText: Color(0xFF2563EB),
        bodyText: Color(0xFF374151),
      );

    case BlogAsideKind.done:
    case BlogAsideKind.result:
      return const _AsidePalette(
        accent: Color(0xFF22C55E),
        headerBg: Color(0xFFF0FDF4),
        bodyBg: Color(0xFFFBFFFC),
        titleText: Color(0xFF16A34A),
        bodyText: Color(0xFF374151),
      );

    case BlogAsideKind.note:
      return const _AsidePalette(
        accent: Color(0xFF8B5CF6),
        headerBg: Color(0xFFF5F3FF),
        bodyBg: Color(0xFFFCFBFF),
        titleText: Color(0xFF7C3AED),
        bodyText: Color(0xFF374151),
      );

    case BlogAsideKind.tip:
    case BlogAsideKind.simple:
    default:
      return const _AsidePalette(
        accent: Color(0xFFF97316),
        headerBg: Color(0xFFFFF3E0),
        bodyBg: Color(0xFFFFFCF5),
        titleText: Color(0xFFEA580C),
        bodyText: Color(0xFF374151),
      );
  }
}

class _SimpleAside extends StatelessWidget {
  final BlogAsideData data;
  final fm.MarkdownStyleSheet styleSheet;
  final bool selectable;
  final double maxWidth;

  const _SimpleAside({
    required this.data,
    required this.styleSheet,
    required this.selectable,
    required this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _palette(data.kind);

    final simpleStyle = styleSheet.copyWith(
      p: const TextStyle(
        fontSize: 15,
        height: 1.7,
        color: Color(0xFF111827),
      ),
      blockSpacing: 8,
    );
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 18),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data.icon,
            style: const TextStyle(fontSize: 15),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: fm.MarkdownBody(
              data: preprocessYoutubeLinks(data.body),
              selectable: selectable,
              styleSheet: simpleStyle,
              softLineBreak: true,
              imageBuilder: (uri, alt, title) => buildMarkdownImage(
                context: context,
                uri: uri,
                alt: alt,
                title: title,
                max_width: maxWidth,
              ),
              onTapLink: (text, href, title) async {
                if (href == null) return;
                await handleMarkdownLinkTap(context, href);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TitledAside extends StatelessWidget {
  final BlogAsideData data;
  final fm.MarkdownStyleSheet styleSheet;
  final bool selectable;
  final double maxWidth;

  const _TitledAside({
    required this.data,
    required this.styleSheet,
    required this.selectable,
    required this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _palette(data.kind);

    final bodyStyle = styleSheet.copyWith(
      p: TextStyle(
        fontSize: 15,
        height: 1.75,
        color: colors.bodyText,
      ),
      blockSpacing: 8,
      listBullet: TextStyle(
        fontSize: 15,
        color: colors.bodyText,
      ),
    );

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: colors.bodyBg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        // crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: 4,
            color: colors.accent,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  color: colors.headerBg,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Text(
                        data.icon,
                        style: const TextStyle(fontSize: 15),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          data.title,
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.4,
                            fontWeight: FontWeight.w800,
                            color: colors.titleText,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                /*data body 비어 있으면 애매해지니  */
                if (data.body.trim().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
                    child: fm.MarkdownBody(
                      data: preprocessYoutubeLinks(data.body),
                      selectable: selectable,
                      styleSheet: bodyStyle,
                      softLineBreak: true,
                      imageBuilder: (uri, alt, title) => buildMarkdownImage(
                        context: context,
                        uri: uri,
                        alt: alt,
                        title: title,
                        max_width: maxWidth,
                      ),
                      onTapLink: (text, href, title) async {
                        if (href == null) return;
                        await handleMarkdownLinkTap(context, href);
                      },
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}