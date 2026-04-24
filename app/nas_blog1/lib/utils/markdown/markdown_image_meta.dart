import 'package:flutter/material.dart';



/// title 문자열에서 size/align 정보 꺼내기
class MarkdownImageMeta {
  final String size;   // small, medium, large, full
  final String align;  // left, center, right
  final String? caption;
  const MarkdownImageMeta({this.size='medium', this.align='center',  this.caption});


/*문자열로 저장된 이미지 옵션을 다시 객체로 복원하기 위해서 */
//title영역에 size=...;caption=... 이런 것을 넣어서 나중에 parse해서 씀
//예시로 들면, title = 'size=large;align=center;caption=%EB%A1%9C%EB%B4%87%20%EC%82%AC%EC%A7%84';
//factory : 이 건 생성자 종류 중 하나이고, 항상 새 객체를 만드는 것보다 좀 더 유연한 생성자
//          함수처럼 내부에서 여러 로직 처리하고 객체 반환함.
//parse() : 문자열 ->객체임. 
//dart는 생성자에 이름 붙일 수 있음.  parse는 함수 이름이 아니라 이름이 있는 생성자임. 
//즉, class이름.parse()이런방식으로 클래스의 객체를 만들어냄.

factory MarkdownImageMeta.parse(String? title) {
  // 기본값
  String size = 'medium';
  String align = 'center';
  String? caption;
  /*factory 생성자여서, if문,파싱기능,디코딩까지 거친뒤에 객체 반환함 */
  if (title == null || title.isEmpty) {
    return MarkdownImageMeta(size: size, align: align, caption: caption);
  }

  // "size=medium;align=center" 같은 형식 파싱
  final parts = title.split(';');
  for (final part in parts) {
    final kv = part.split('=');
    if (kv.length != 2) continue;

    final key = kv[0].trim();
    final value = kv[1].trim();

    if (key == 'size') {
      size = value;
    } else if (key == 'align') {
      align = value;
    } else if (key == 'caption') {
      caption = Uri.decodeComponent(value);
    }
  }

  return MarkdownImageMeta(size: size, align: align, caption: caption);
}

/*parse된것을 다시 title로 바꿈 */
String toTitleMeta() {
  final buffer = StringBuffer()
    ..write('size=$size')
    ..write(';align=$align');

  if(caption != null && caption!.trim().isNotEmpty) 
  {
    buffer.write(';caption=${Uri.encodeComponent(caption!)}');
  }

  return buffer.toString();
}
}


/// 사이즈 문자열을 0~1.0 스케일로 변환
double imageSizeToFactor(String size) {
  switch (size) {
    case 'small':
      return 0.1;
    case 'medium':
      return 0.5;
    case 'large':
      return 0.7;
    case 'full':
      return 1.0;
    default:
      return 0.5;
  }
}

/// 정렬 문자열을 Alignment 로 변환
Alignment imageAlignToAlignment(String align) {
  switch (align) {
    case 'left':
      return Alignment.centerLeft;
    case 'right':
      return Alignment.centerRight;
    case 'center':
    default:
      return Alignment.center;
  }
}