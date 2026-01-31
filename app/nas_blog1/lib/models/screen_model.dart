/*지금 환경이 모바일인지 아닌지 판단 */
import 'package:flutter/widgets.dart';

class ScreenModel {
  bool web;
  bool tablet;
  bool mobile;

  ScreenModel(this.web, this.tablet, this.mobile); //생성자.

  // String toString() {
  //   return 'ScreenModel{}'
  //이건 안쓰일것으로보임. 

  static ScreenModel fromWidth(double w) {
  // factory ScreenModel.fromWidth(double w) {
  
    //factory : 이 생성자는 항상 새 인스턴스 만들 필요 없음 (=static유사), static으로 바꿔도됨.
    //이건 생성자라서 return값 안씀. 
    final mobile = ( w < 768);
    final tablet = (w >= 768 && w < 1100);
    final web = (w >= 1100);
    return ScreenModel(web,tablet,mobile);
  }

  static ScreenModel of(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    return ScreenModel.fromWidth(w);
  }
  }
