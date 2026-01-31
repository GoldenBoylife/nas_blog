import 'package:flutter/material.dart';

/*hero이미지처럼 부모의 좌우 패딩, /최대폭 제한 무시하고 화면 전체폭으로 펼쳐지는 여역 만들고 싶을 때 */
class FullBleed extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const FullBleed({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
    });

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: padding,
      child: child,
    );
  }

  
}