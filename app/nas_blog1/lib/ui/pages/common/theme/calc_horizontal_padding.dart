
  import 'package:nas_blog1/models/screen_model.dart';

double calcHorizontalPadding(ScreenModel sm, double width) {
    /*대충 inpa 느낌, desktop은 좌우 여백 조금 */
    if(sm.web) return 16;
    if(sm.tablet) return 12;
    return 10;
  }