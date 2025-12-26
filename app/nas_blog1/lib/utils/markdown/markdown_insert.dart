/*TextEditingController */
/*
커서 위치 삽입 유틸
 

 */

import 'package:flutter/material.dart';

class MarkdownInsert{
  const MarkdownInsert._();


  static void insertTextAtCursor({
    required TextEditingController controller, //현재 편집기 상태
    required String text,
  }){


  /*현재 값 상태 */
  final value = controller.value; 
  final selection = value.selection; 

  if(!selection.isValid) {
    controller.value = value.copyWith(
      text: value.text + text,
      selection: TextSelection.collapsed(
        offset: (value.text + text).length,
      )
    );
    //커서 정보가 "유효하지 않으면" 맨 뒤에 붙임. 
    return ;
  }


  final new_text = value.text.replaceRange(
    selection.start,
    selection.end,
    text,
  );
  final new_selection_pos = selection.start + text.length;

  controller.value = value.copyWith(
    text: new_text,
    selection: TextSelection.collapsed(offset: new_selection_pos),
  );
  }

  /*insert one line about image markdown  */
  /// titleMeta : 'size=medium;align=center' 같이 들어감. 
  static void insertImageMarkdown({
    required TextEditingController controller,
    required String full_url,
    String? alt,
    String? title_meta,
  })
  {
    final alt_text = alt ?? 'image';

    final buffer = StringBuffer();  
    //아무 내용 없는 빈 문자열에 버퍼 추가, 조건에 맞추어서 문자열이 계속추가될때 이 함수 씀
      buffer.write('\n![');
      buffer.write(alt_text);
      buffer.write('](');
      buffer.write(full_url);


      if(title_meta != null && title_meta.isNotEmpty)
      {
        buffer
          ..write(' "')
          ..write(title_meta)
          ..write('"');
      }

      buffer.write(')\n');

      insertTextAtCursor(
        controller: controller,
        text: buffer.toString(),
      );
  }
}