import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart' as fm;

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

    p: const TextStyle(fontSize: 16, height: 1.6),
    h1: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold,color: Color.fromARGB(255, 168, 98, 6) ),
    h2: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold,color: Color.fromARGB(255, 57, 91, 241)), //22
    h3: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold,color: Color.fromARGB(255, 171, 39, 197)), //20
    h4: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 29, 219, 38)), //20
    h5: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), //20
    h6: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold), //20

    /*for inline CODE part style */
    code: const TextStyle(
      fontFamily: 'JetBrainsMono',
      fontSize:13.5,
      height: 1.55,
      color: Color(0xFF111827),
      fontWeight: FontWeight.w500,
    ),
    codeblockPadding: const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 14,
    ),
    
    codeblockDecoration: BoxDecoration(
      color: const Color(0xFFF9F9F9),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: const Color(0xFFEAEAEA),
        width: 1,
      )
    ),
// blockquote도 같이 조금 예쁘게
    blockquote: const TextStyle(
      fontSize: 15,
      height: 1.6,
      color: Color(0xFF475569),
      fontStyle: FontStyle.italic,
    ),
    blockquoteDecoration: BoxDecoration(
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
