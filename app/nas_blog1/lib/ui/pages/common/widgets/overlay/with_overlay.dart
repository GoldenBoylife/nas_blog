
import 'package:flutter/material.dart';


/// content 위에 overlay를 얹어주는 공용 래퍼, 
/// overlay가 null이면 content만 반환
/// 내부에서 Positioned를 자유롭게 쓰도록 설계
class WithOverlay extends StatelessWidget {
  final Widget child; //스크롤 컨텐츠
  final Widget? overlay; //Positioned 들어 있는 overlay

  const WithOverlay({
    super.key,
    required this.child,
    this.overlay
    });

  @override
  Widget build(BuildContext context) {
    if(overlay == null) return child;

    return Stack(
      clipBehavior : Clip.none,
      children: [
        Positioned.fill(child:child),
        overlay!,
      ]
    );
  }
}