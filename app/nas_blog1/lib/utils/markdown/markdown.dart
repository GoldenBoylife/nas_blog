import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart' as fm;

import 'package:nas_blog1/utils/markdown/markdown_style.dart';
import 'package:nas_blog1/utils/markdown/markdown_text.dart';
import 'package:nas_blog1/utils/markdown/markdown_youtube.dart';
import 'package:nas_blog1/utils/markdown/markdown_image_builder.dart';
import 'package:nas_blog1/utils/markdown/markdown_aside.dart';
// import 'package:nas_blog1/utils/markdown/markdown_spacer.dart';
import 'package:nas_blog1/utils/markdown/markdown_header.dart';

class BlogMarkdownScroll extends StatelessWidget {
  final String data;
  final EdgeInsets padding;
  final ScrollController? controller;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final bool selectable;
  final fm.MarkdownStyleSheet? styleSheet;

  const BlogMarkdownScroll({
    super.key,
    required this.data,
    this.padding = const EdgeInsets.all(16.0),
    this.controller,
    this.physics,
    this.shrinkWrap = false,
    this.selectable = false,
    this.styleSheet,
  });

  @override
  Widget build(BuildContext context) {
    final style = styleSheet ?? blogMarkdownStyle(context);
    final parts = splitMarkdownByBlankLines(data);

    return LayoutBuilder(
      builder: (context, constraints) {
        return ListView(
          padding: padding,
          controller: controller,
          physics: physics,
          shrinkWrap: shrinkWrap,
          children: [
          for (final part in parts)
            if (part.isSpacer)
              SizedBox(height: part.spacerHeight)
            else if (part.isHeading)
              BlogHeading(data: part.heading!)
            else if (part.isAside)
              BlogAside(
                data: part.aside!,
                styleSheet: style,
                selectable: selectable,
                maxWidth: constraints.maxWidth,
              )
            else
              fm.MarkdownBody(
                data: preprocessYoutubeLinks(part.markdown!),
                selectable: selectable,
                styleSheet: style,
                softLineBreak: true,
                imageBuilder: (uri, alt, title) => buildMarkdownImage(
                  context: context,
                  uri: uri,
                  alt: alt,
                  title: title,
                  max_width: constraints.maxWidth,
                ),
                onTapLink: (text, href, title) async {
                  if (href == null) return;
                  await handleMarkdownLinkTap(context, href);
                },
              ),
          ],
        );
      },
    );
  }
}

/*스크롤 기능 자체적으로 가진 markdown 화면  */
class BlogMarkdownBody extends StatelessWidget {
  final String data;
  final fm.MarkdownStyleSheet? styleSheet;

  const BlogMarkdownBody({
    super.key,
    required this.data,
    this.styleSheet,
  });

  @override
  Widget build(BuildContext context) {
    final style = styleSheet ?? blogMarkdownStyle(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final parts = splitMarkdownByBlankLines(data);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
            children: [
              for (final part in parts)
              if (part.isSpacer)
                SizedBox(height: part.spacerHeight)
              else if (part.isHeading)
                BlogHeading(data: part.heading!)
              else if (part.isAside)
                BlogAside(
                  data: part.aside!,
                  styleSheet: style,
                  maxWidth: constraints.maxWidth,
                )
              else
                fm.MarkdownBody(
                  data: preprocessYoutubeLinks(part.markdown!),
                  styleSheet: style,
                  softLineBreak: true,
                  imageBuilder: (uri, alt, title) => buildMarkdownImage(
                    context: context,
                    uri: uri,
                    alt: alt,
                    title: title,
                    max_width: constraints.maxWidth,
                  ),
                  onTapLink: (text, href, title) async {
                    if (href == null) return;
                    await handleMarkdownLinkTap(context, href);
                  },
                ),
            ],
        );
      },
    );
  }
}