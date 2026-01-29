import 'package:flutter/material.dart';
import 'my_color.dart';
class TextUtil {

//font_size = 24
  static TextStyle get32(BuildContext context, Color color,{FontWeight font_weight = FontWeight.w800})
  // { } 가 들어간 인자는 default와 비슷한 개념. 
  //왜 context까지? 현재 위치의 Theme(글꼴/텍스트 스타일 설정) 가져오려면 BuildContext필요.
    {
      return Theme.of(context).textTheme.headlineLarge!.copyWith(
          color: color,
          fontWeight: font_weight
      );
      //Theme.of()가 context 통해서 위젯 트리를 거스러 올라가 가장 가까운 Theme을 찾음
      //copyWith : 기존 객체(스타일) 복사하되, 내가 지정한 일부 속석만 바꿈.
    }
  //font_size = 24
  static TextStyle get24(BuildContext context, Color color,{FontWeight font_weight = FontWeight.w600})
  {
    return Theme.of(context).textTheme.headlineLarge!.copyWith(
      color: color,
      fontWeight: font_weight
    );
  }
  
  
  /// fontSize = 20
  static TextStyle get20(BuildContext context, Color color,{FontWeight font_weight = FontWeight.w500}) {
    return Theme.of(context).textTheme.titleMedium!.copyWith(
      fontWeight: font_weight);
  }

  /// fontSize = 18
  static TextStyle get18(BuildContext context, Color color, {FontWeight font_weight = FontWeight.w500}) {
    return Theme.of(context).textTheme.titleSmall!.copyWith(
      color: color,
      fontWeight: font_weight);
  }

  /// fontSize = 16
  static TextStyle get16(BuildContext context, Color color, {FontWeight font_weight = FontWeight.w500}) {
    return Theme.of(context).textTheme.bodyLarge!.copyWith(
      color: color,
      fontWeight: font_weight);
  }

  /// fontSize = 15
  static TextStyle get15(BuildContext context, Color color, {FontWeight font_weight = FontWeight.w500}) {
    return Theme.of(context).textTheme.bodyMedium!.copyWith(
      color: color,
      fontWeight: font_weight);
  }

  /// fontSize = 14
  static TextStyle get14(BuildContext context, Color color, {FontWeight font_weight = FontWeight.w500}) {
    return Theme.of(context).textTheme.bodySmall!.copyWith(
      color: color,
      fontWeight: font_weight);
  }

  /// fontSize = 13
  static TextStyle get13(BuildContext context, Color color, {FontWeight font_weight = FontWeight.w500}) {
    return Theme.of(context).textTheme.labelLarge!.copyWith(
      color: color,
      fontWeight: font_weight);
  }

  /// fontSize = 12
  static TextStyle get12(BuildContext context, Color color, {FontWeight font_weight = FontWeight.w500}) {
    return Theme.of(context).textTheme.labelMedium!.copyWith(
      //labelMedium 자체가 fontSize 12다.
      color: color,
      fontWeight: font_weight);
  }

  /// fontSize = 11
  static TextStyle get11(BuildContext context, Color color, {FontWeight font_weight = FontWeight.w500}) {
    return Theme.of(context).textTheme.labelSmall!.copyWith(
      color: color,
      fontWeight: font_weight
    );
  }

  static TextStyle getEng32(BuildContext context, Color color, {FontWeight font_weight = FontWeight.w500}){
    return Theme.of(context).textTheme.headlineLarge!.copyWith(
      color: color,
      fontWeight: font_weight,
      fontFamily: 'AstonPoliz', //폰트 지정
    );
  }
  static TextStyle getKor32(BuildContext context, Color color, {FontWeight fontWeight = FontWeight.w500}) {
    return Theme.of(context).textTheme.headlineLarge!.copyWith(
      color: color,
      fontWeight: fontWeight,
      fontFamily: 'BMJUA', //폰트 지정
    );
  }


  // static TextTheme setTextTheme() {
  static TextTheme setTextTheme() {
    return const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: MyColor.gray90,
      ),
      titleLarge: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: MyColor.gray90,
      ),
      titleMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: MyColor.gray90,
      ),
      titleSmall: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: MyColor.gray90,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: MyColor.gray90,
      ),
      bodyMedium: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: MyColor.gray90,
      ),
      bodySmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: MyColor.gray90,
      ),
      labelLarge: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: MyColor.gray90,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: MyColor.gray90,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: MyColor.gray90,
      ),
    );
  }
}