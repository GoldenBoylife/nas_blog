/*화면에 패딩 추가*/

import 'package:flutter/material.dart';

class CustomConstraints extends StatelessWidget {
  final Color background_color;
  final double max_width;
  final Widget child;

  const CustomConstraints({
    required this.background_color,
    required this.max_width,
    required this.child,
    super.key
    });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: this.background_color, //배경색 컬러
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: this.max_width),
            //페이지의 최대 길이 한정
            child: this.child,
            //자식 위젯을 리턴함.
            //이 클래스의 인자로 받은 Widget을 그대로 씀
            //여기서는 단순히 최대 길이만 한정한것. 
          )
      )
    );
  }
}
