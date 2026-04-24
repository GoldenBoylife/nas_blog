import 'package:flutter/widgets.dart';
import 'package:flutter_markdown/flutter_markdown.dart' as fm;
import 'package:markdown/markdown.dart' as md;

const String markdown_spacer_token = ':::gb-spacer:::';
const String markdown_spacer_tag = 'gb-spacer';

class MarkdownSpacerSyntax extends md.BlockSyntax {
  @override
  RegExp get pattern => RegExp(r'^:::gb-spacer:::$');

  @override
  md.Node parse(md.BlockParser parser) {
    parser.advance();
    return md.Element(markdown_spacer_tag, []);
  }
}

class MarkdownSpacerBuilder extends fm.MarkdownElementBuilder {
  final double height;

  MarkdownSpacerBuilder({
    this.height = 16,
  });

  @override
  Widget? visitElementAfter(
    md.Element element,
    TextStyle? preferredStyle,
  ) {
    return SizedBox(height: height);
  }
}