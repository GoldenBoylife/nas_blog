// import 'package:nas_blog1/utils/markdown/markdown_spacer.dart';
import 'package:nas_blog1/utils/markdown/markdown_aside.dart';
import 'package:nas_blog1/utils/markdown/markdown_header.dart';
class MarkdownRenderPart {
  final String? markdown;
  final double spacerHeight;
  final BlogAsideData? aside;
  final BlogHeadingData? heading;

  const MarkdownRenderPart.markdown(this.markdown)
      : spacerHeight = 0,
        aside = null,
        heading = null;

  const MarkdownRenderPart.spacer(this.spacerHeight)
      : markdown = null,
        aside = null,
        heading = null;

  const MarkdownRenderPart.aside(this.aside)
      : markdown = null,
        spacerHeight = 0,
        heading = null;

  const MarkdownRenderPart.heading(this.heading)
      : markdown = null,
        spacerHeight = 0,
        aside = null;

  bool get isSpacer => markdown == null && aside == null && heading == null;
  bool get isAside => aside != null;
  bool get isHeading => heading != null;
}

BlogHeadingData? _parseHeading(String trimmed) {
  final match = RegExp(r'^(#{1,4})\s+(.+)$').firstMatch(trimmed);

  if (match == null) return null;

  final level = match.group(1)!.length;
  final text = match.group(2)!.trim();

  if (text.isEmpty) return null;

  return BlogHeadingData(
    level: level,
    text: text,
  );
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

  int i = 0;

  while (i < lines.length) {
    final line = lines[i];
    final trimmed = line.trim();

    if (inCodeFence) {
      buffer.add(line);

      if (trimmed.startsWith('```')) {
        inCodeFence = false;
      }

      i++;
      continue;
    }

    if (trimmed.startsWith('```')) {
      flushBlankLines();

      inCodeFence = true;
      buffer.add(line);
      i++;
      continue;
    }

    final heading = _parseHeading(trimmed);

    if (heading != null) {
      flushBlankLines();
      flushMarkdownBuffer();

      parts.add(
        MarkdownRenderPart.heading(heading),
      );

      i++;
      continue;
    }

    if (_isAsideOpen(trimmed)) {
      flushBlankLines();
      flushMarkdownBuffer();

      final asideLines = <String>[];
      i++;

      while (i < lines.length) {
        final currentLine = lines[i];
        final currentTrimmed = currentLine.trim();

        if (_isAsideClose(currentTrimmed)) {
          break;
        }

        asideLines.add(currentLine);
        i++;
      }

      parts.add(
        MarkdownRenderPart.aside(
          _buildAsideData(asideLines),
        ),
      );

      if (i < lines.length) {
        i++;
      }

      continue;
    }

    if (trimmed.isEmpty) {
      blankCount++;
      i++;
      continue;
    }

    flushBlankLines();
    buffer.add(line);
    i++;
  }

  flushBlankLines();
  flushMarkdownBuffer();

  return parts;
}


/*aside */
bool _isAsideOpen(String trimmed) {
  return trimmed.toLowerCase() == '<aside>';
}

bool _isAsideClose(String trimmed) {
  return trimmed.toLowerCase() == '</aside>';
}

List<String> _trimEmptyEdges(List<String> lines) {
  final result = [...lines];

  while (result.isNotEmpty && result.first.trim().isEmpty) {
    result.removeAt(0);
  }

  while (result.isNotEmpty && result.last.trim().isEmpty) {
    result.removeLast();
  }

  return result;
}
bool _looksLikeIcon(String value) {
  final v = value.trim();

  if (v.isEmpty) return false;
  if (v.length > 8) return false;

  return !RegExp(r'[A-Za-z0-9가-힣]').hasMatch(v);
}

bool _isKeywordTitle(String value) {
  final key = value.trim().toLowerCase().replaceAll(' ', '');

  return {
    'tip',
    'tips',
    'hint',
    'warning',
    'warn',
    'danger',
    'problem',
    'error',
    'info',
    'note',
    'memo',
    'done',
    'success',
    'result',
    '주의',
    '경고',
    '문제',
    '에러',
    '참고',
    '설명',
    '메모',
    '완료',
    '결과',
    '결론',
  }.contains(key);
}

BlogAsideKind _kindFromTitle(String value) {
  final key = value.trim().toLowerCase().replaceAll(' ', '');

  switch (key) {
    case 'warning':
    case 'warn':
    case 'danger':
    case '주의':
    case '경고':
      return BlogAsideKind.warning;

    case 'problem':
    case 'error':
    case '문제':
    case '에러':
      return BlogAsideKind.problem;

    case 'info':
    case '참고':
    case '설명':
      return BlogAsideKind.info;

    case 'note':
    case 'memo':
    case '메모':
      return BlogAsideKind.note;

    case 'done':
    case 'success':
    case '완료':
      return BlogAsideKind.done;

    case 'result':
    case '결과':
    case '결론':
      return BlogAsideKind.result;

    case 'tip':
    case 'tips':
    case 'hint':
    default:
      return BlogAsideKind.tip;
  }
}

String _titleFromKeyword(String value) {
  final key = value.trim().toLowerCase().replaceAll(' ', '');

  switch (key) {
    case 'warning':
    case 'warn':
    case 'danger':
    case '주의':
    case '경고':
      return 'Warning';

    case 'problem':
    case 'error':
    case '문제':
    case '에러':
      return 'Problem';

    case 'info':
    case '참고':
    case '설명':
      return 'Info';

    case 'note':
    case 'memo':
    case '메모':
      return 'Note';

    case 'done':
    case 'success':
    case '완료':
      return 'Done';

    case 'result':
    case '결과':
    case '결론':
      return 'Result';

    case 'tip':
    case 'tips':
    case 'hint':
    default:
      return 'Tip';
  }
}

String _iconFromKind(BlogAsideKind kind) {
  switch (kind) {
    case BlogAsideKind.warning:
      return '⚠️';

    case BlogAsideKind.problem:
      return '🚨';

    case BlogAsideKind.info:
      return 'ℹ️';

    case BlogAsideKind.note:
      return '📝';

    case BlogAsideKind.done:
    case BlogAsideKind.result:
      return '✅';

    case BlogAsideKind.tip:
    case BlogAsideKind.simple:
    default:
      return '💡';
  }
}

BlogAsideData _buildAsideData(List<String> rawLines) {
  var lines = _trimEmptyEdges(rawLines);

  var icon = '💡';

  // Notion에서 복사한 경우 첫 줄에 💡만 있을 수 있음
  if (lines.isNotEmpty && _looksLikeIcon(lines.first.trim())) {
    icon = lines.first.trim();
    lines = _trimEmptyEdges(lines.sublist(1));
  }

  if (lines.isEmpty) {
    return const BlogAsideData(
      kind: BlogAsideKind.simple,
      title: '',
      icon: '💡',
      body: '',
      hasTitle: false,
    );
  }

  final blankIndex = lines.indexWhere((line) => line.trim().isEmpty);

  // 빈 줄이 없으면 한 줄짜리 aside
  if (blankIndex < 0) {
    return BlogAsideData(
      kind: BlogAsideKind.simple,
      title: '',
      icon: icon,
      body: lines.join('\n').trim(),
      hasTitle: false,
    );
  }

  final titleRaw = lines.sublist(0, blankIndex).join(' ').trim();

  var bodyLines = lines.sublist(blankIndex + 1);
  bodyLines = _trimEmptyEdges(bodyLines);

  // 제목만 있고 본문이 없으면 simple 처리
  if (titleRaw.isEmpty || bodyLines.isEmpty) {
    return BlogAsideData(
      kind: BlogAsideKind.simple,
      title: '',
      icon: icon,
      body: lines.join('\n').trim(),
      hasTitle: false,
    );
  }

  // tip / warning / info 같은 키워드 제목
  if (_isKeywordTitle(titleRaw)) {
    final kind = _kindFromTitle(titleRaw);

    return BlogAsideData(
      kind: kind,
      title: _titleFromKeyword(titleRaw),
      icon: _iconFromKind(kind),
      body: bodyLines.join('\n').trim(),
      hasTitle: true,
    );
  }

  // 일반 제목
  return BlogAsideData(
    kind: BlogAsideKind.tip,
    title: titleRaw,
    icon: icon,
    body: bodyLines.join('\n').trim(),
    hasTitle: true,
  );
}
/*    aside */

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