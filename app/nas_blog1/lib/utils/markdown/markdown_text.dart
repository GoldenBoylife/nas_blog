// import 'package:nas_blog1/utils/markdown/markdown_spacer.dart';

class MarkdownRenderPart {
  final String? markdown;
  final double spacerHeight;

  const MarkdownRenderPart.markdown(this.markdown) : spacerHeight = 0;
  const MarkdownRenderPart.spacer(this.spacerHeight) : markdown = null;

  bool get isSpacer => markdown == null;
}

String preprocessMarkdownText(String input) 
{
  var result = input;
  result = normalizeLineEndings(result);
  result = normalizeHtmlBreaks(result);
  // result = normalizeMarkdownLineBreaks(result);

  return result;

}
/*줄바꿈은 운영체제마다 다르므로, 통일한다. */
String normalizeLineEndings(String input) {
  return input.replaceAll('\r\n', '\n');
  //window식(\r\n)을 linux식(\n)으로 변경
}

/* 사용자가 혹시 <br>을 넣었을 때 markdown 줄바꿈으로 바꿔준다. */
String normalizeHtmlBreaks(String input) {
  return input.replaceAll(
    RegExp(r'<br\s*/?>', caseSensitive: false),
    '  \n',
  );
}

/*
  사용자가 입력한 빈 줄 개수를 Flutter 위젯 spacer로 바꾸기 위한 분리 함수.

  핵심:
  - markdown 내용은 MarkdownRenderPart.markdown
  - 빈 줄은 MarkdownRenderPart.spacer
  - 코드블록 내부의 빈 줄은 절대 분리하지 않음
*/
List<MarkdownRenderPart> splitMarkdownByBlankLines(
  String input, {
  double blankLineHeight = 18,
}) {
  final normalized = normalizeLineEndings(input);
  final lines = normalized.split('\n');

  final parts = <MarkdownRenderPart>[];
  final buffer = <String>[];

  bool inCodeFence = false;
  int blankCount = 0;

  void flushMarkdownBuffer() {
    final text = buffer.join('\n').trimRight();
    buffer.clear();

    if (text.trim().isEmpty) return;

    parts.add(
      MarkdownRenderPart.markdown(
        preprocessMarkdownText(text),
      ),
    );
  }

  void flushBlankLines() {
    if (blankCount <= 0) return;

    flushMarkdownBuffer();

    parts.add(
      MarkdownRenderPart.spacer(blankCount * blankLineHeight),
    );

    blankCount = 0;
  }

  for (final line in lines) {
    final trimmed = line.trim();

    if (inCodeFence) {
      buffer.add(line);

      if (trimmed.startsWith('```')) {
        inCodeFence = false;
      }

      continue;
    }

    if (trimmed.startsWith('```')) {
      flushBlankLines();

      inCodeFence = true;
      buffer.add(line);
      continue;
    }

    if (trimmed.isEmpty) {
      blankCount++;
      continue;
    }

    flushBlankLines();
    buffer.add(line);
  }

  flushBlankLines();
  flushMarkdownBuffer();

  return parts;
}


// /*줄바꿈 정리 */
// String normalizeMarkdownLineBreaks(String input) 
// {
//   final lines = input.split('\n'); 
//   //입력 문자열을 줄단위로 바꿈 
//   //예를 들어서, 
//   // 변경전) 안녕하세요\n반갑습니다. 
//   // 변경후) 안녕하세요. 
//   //        반갑습니다.
//   // ['안녕하세요','반갑습니다'] 로 나뉨
//   /* 바뀐 것2
//    markdown렌더러는 \n가 여러개 있어도 \n 한번만 한다. 그래서 두번재 빈줄부터는 \u00A0(non-breaking space)를 넣ㅇ어서 빈공간 렌더링한다.

//    */

//   final out = <String>[];
//   //결과 넣을 빈줄들 

//   bool in_code_fence = false; //현재 코드 블록이 안에 있는지 표시
//   int blank_count =0;

//   for(final line in lines) 
//   {
//     final trimmed = line.trim();

//     /*코드 블록 시작/끝은 그대로둔다. */
//     if(trimmed.startsWith('```'))
//     {
//       in_code_fence = !in_code_fence;
//       out.add(line);
//       blank_count = 0;
//       continue;
//     }

//     if(in_code_fence) 
//     {
//       out.add(line);
//       continue;
//     }
//     /*
//       빈 줄처리.
//       첫 번째 빈 줄은 Markdown의 기본 문단 구분으로 둔다.
//       두 번째 빈 줄부터는 실제 빈 문단처럼 보존한다. 
      
//      */

//     if(trimmed.isEmpty) {
//       blank_count++;

//       if(blank_count ==1) {
        
//         out.add('');
//         //첫 번째 빈줄은 markdown 기본 문단 구분으로 둔다.

//       } else {
//         out.add('<br>');
//         // 두번재 빈 줄부터는 실제 spacer block으로 바꾼다.
//       }
//       continue;
//     }
//     /**
//      일반 내용 줄이 나오면 blank_count를 초기화하고그대로 추가한다. 
//      여기서 일반 줄바꿈을 강제로 \n\n로 바꾸어도 markdown랜더러는 그냥 \n로 인식하니 안된다.
//      */
//     blank_count = 0;
//     out.add(line);
//   }
//   return out.join('\n');
//   //결과 리스트를 다시 하나의 문자열로 합치고, 줄 사이에는 \n 넣는다.
//   //out이 '안녕하세요','반갑습니다.','','# 제목','내용입니다.' 라면

//   //out.join('\n')통해서
//   // 안녕하세요.
//   // 반갑습니다.
//   // 
//   // # 제목
//   // 내용입니다.

// }