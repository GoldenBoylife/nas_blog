import 'package:flutter/material.dart';
// import 'package:nas_blog1/models/post_status.dart';

/*
배치도
 Cantainer (패널 외곽)-A4용지 외곽선
 -> BoxDecoration 겉모양으로  테두리 선 넣음. 
 -> padding(안쪽 여백)
 -------------------------------
 -- Column
 -> Column은 세로 방향배치이고, stretch : 가로폭을 가능한 꽉채우게, 

  1) Text
  2) SizedBox
  3) child


 */
class PanelCard extends StatelessWidget {
  final String title;
  final Widget child;

  const PanelCard({
    super.key,
    required this.title,
    required this.child,
    });



  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            color: Colors.black.withOpacity(0.03),
            offset: const Offset(0,6))
          
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        //Column은 세로 방향배치이고, stretch : 가로폭을 가능한 꽉채우게, 
        //
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height:10),
          child,
        ]
      )
    );
  }
}
