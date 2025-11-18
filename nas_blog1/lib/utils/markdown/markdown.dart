import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;

class Markdown extends MarkdownWidget{
  
    final EdgeInsets padding;
    final ScrollController? controller;
    final ScrollPhysics? physics;
    final bool shrinkWrap;


    const Markdown({
      //super : 부모의 생성자로 전달.
        super.key,
        required super.data,
        super.selectable,
        super.styleSheet,
        super.styleSheetTheme = null,
        super.syntaxHighlighter,
        super.onSelectionChanged,
        super.onTapLink,
        super.onTapText,
        super.imageDirectory,
        super.blockSyntaxes,
        super.inlineSyntaxes,
        super.extensionSet,
        super.sizedImageBuilder,
        super.checkboxBuilder,
        super.bulletBuilder,
        super.builders,
        super.paddingBuilders,
        super.listItemCrossAxisAlignment,
        this.padding = const EdgeInsets.all(16.0),
        this.controller,
        this.physics,
        this.shrinkWrap = false,
        super.softLineBreak,
    });


    @override
    /*how to draw this widget on the screen as tree */
  Widget build(BuildContext context, List<Widget>? children) {
    return ListView(
      padding: padding,
      controller: controller,
      physics: physics,
      shrinkWrap: shrinkWrap,
      children: children!,
      //!:this value is never null. if "null", runtime error.
    );
  }
}