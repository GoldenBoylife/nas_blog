import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart' as fm;
import 'package:nas_blog1/utils/markdown/markdown_header.dart';
/*flutter에서 markdown 글을 보여줄 때 제목/본문/코드블록/인용문/리스트의 스타일을 커스터마이징하는 함수  */
// markdown위젯에 넣을 스타일 세트를 ㅁ나들어서 반환함
///common Markdown style
//fm : flutter markdown
//for markdown style
fm.MarkdownStyleSheet blogMarkdownStyle(BuildContext context) {
  //현재 앱의 테마정보를 가져오기 위해서 context씀

  final base = fm.MarkdownStyleSheet.fromTheme(Theme.of(context));
  //현재 앱의 테마를 기반으로 기본 markdown 스타일 만듬

  return base.copyWith(
    blockSpacing: 8,

    p: const TextStyle(
      fontSize: 16,
      height: 1.65,
      color: gbText,
    ),

    h1: BlogHeaderStyles.h1,
    h2: BlogHeaderStyles.h2,
    h3: BlogHeaderStyles.h3,
    h4: BlogHeaderStyles.h4,
    h5: BlogHeaderStyles.h5,
    h6: BlogHeaderStyles.h6,

    /*for inline CODE part style */
    code: const TextStyle(
      fontFamily: 'JetBrainsMono',
      fontSize: 13.5,
      height: 1.55,
      color: Color(0xFF111827),
      fontWeight: FontWeight.w500,
    ),

    codeblockPadding: const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 14,
    ),

    codeblockDecoration: BoxDecoration(
      color: const Color(0xFFF9FAFB),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: const Color(0xFFE5E7EB),
        width: 1,
      ),
    ),

// blockquote도 같이 조금 예쁘게
    blockquote: const TextStyle(
      fontSize: 15,
      height: 1.6,
      color: Color(0xFF475569),
      fontStyle: FontStyle.italic,
    ),

    blockquoteDecoration: const BoxDecoration(
      color: Color(0xFFF8FAFC),
      border: Border(
        left: BorderSide(
          color: Color(0xFFCBD5E1),
          width: 4,
        ),
      ),
    ),

    // 리스트 간격 조금 여유
    listBullet: const TextStyle(
      fontSize: 16,
      color: Color(0xFF374151),
    ),
  );
}
