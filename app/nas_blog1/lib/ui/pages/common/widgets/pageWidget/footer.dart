
/*임시용 */
import 'package:flutter/material.dart';
import 'package:nas_blog1/ui/pages/common/theme/my_color.dart';
import 'package:nas_blog1/ui/pages/common/theme/text_util.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width; // 현재 창 width 크기
    return Container(
      color: MyColor.white, // 배경색 설정
      width: double.infinity, // 화면 전체 너비로 설정
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40), // 상하 좌우 padding 추가
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // 왼쪽 정렬
        children: [
          // 회사 정보, 주소 및 연락처 부분
          Text("Dev_v0.1.0", style: TextUtil.get24(context, Colors.black)),
          const SizedBox(height: 8),
          Text("Contact me", style: TextUtil.get24(context, Colors.black)),
          const SizedBox(height: 8),
          Text(
            "South Korea", 
            style: TextUtil.get16(context, MyColor.gray80)
          ),
          const SizedBox(height: 8),
          Text(
            "Email: ---,", 
            style: TextUtil.get16(context, MyColor.gray80)
          ),
          const SizedBox(height: 20),
          Divider(color: MyColor.gray80), // 구분선
        ],
      ),
    );
  }
}
