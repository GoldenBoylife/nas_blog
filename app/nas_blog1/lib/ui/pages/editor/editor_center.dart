import 'package:flutter/material.dart';

class EditorCenter extends StatelessWidget {
  final TextEditingController title_ctrl;
  final TextEditingController body_ctrl;
  final String? error_msg;

  const EditorCenter({
    super.key,
    required this.title_ctrl,
    required this.body_ctrl,
    required this.error_msg,
    });
  


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: title_ctrl,
          decoration: const InputDecoration(
            hintText: 'Title',
            border: OutlineInputBorder(),

          ),
        ),
        const SizedBox(height:12),
        Expanded(
          //남는 공간을 아래의 child로 꽉 채우고 싶을 때 쓰는것.
          child: TextField(
            controller: body_ctrl,
            maxLines: null,
            //줄수 제한 삭제
            expands: true, //꽉채움
            keyboardType: TextInputType.multiline,
            //여러줄 입력용 키보드 요청
            decoration: const InputDecoration(
              hintText: '# Heading\nWrite in markdown...',
              border: OutlineInputBorder(),
            )
          )
        ),
        if( error_msg != null) ... [
          const SizedBox(height: 10),
          Text(error_msg!, style: const TextStyle(color: Colors.red)),
        ]
      ]
    );
  }
}