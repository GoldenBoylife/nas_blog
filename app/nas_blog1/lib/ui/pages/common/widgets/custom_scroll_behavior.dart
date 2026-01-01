/*main에서 쓰임*/
//마우스로 드래그해서 스크롤+페이지 넘기는 기능
//웹/데스크톱에서 유용한 기능

import 'dart:ui';
import 'package:flutter/material.dart';

class CustomScrollBehavior extends MaterialScrollBehavior{

  /*touch or mouse 가능한 기기는 drag 가능하도록 override*/
  //허용 가능한 입력장치 목록,
  //Set : 중복을 허용하지 않는 컬렉션
  Set<PointerDeviceKind> get dragDevices => 
  {
    PointerDeviceKind.touch, //터지 가능한 디바이스
    PointerDeviceKind.mouse, //materialScrollBehavior에서 기본적으로 mouse빠져있어서 추가
  };
}