import 'package:flutter/material.dart';
import 'package:get/get.dart';


import 'package:nas_blog1/ui/pages/home/home_pg.dart';

import 'ui/pages/common/widgets/custom_scroll_behavior.dart';
import 'ui/pages/common/widgets/pageWidget/custom_constraints.dart';
import 'ui/pages/common/widgets/theme/text_util.dart';

void main() {

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
  
  /* ui1 : 기본1 */
    // return GetMaterialApp(
    //   title: 'Feat/ui-rework',
    //   debugShowCheckedModeBanner: false, //디버깅 표시 없앰.
    //   theme: ThemeData(
    //     useMaterial3: false,
    //     //모서리 둥근 모양 끔
    //     colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),

        
    //   ),
    //   initialRoute:  '/',
    //   getPages: [
    //     GetPage(
    //       name:'/', page : () => const HomePg(),
    //       transition: Transition.noTransition,
    //     )

    //   ]
    // );
  
  /* ui2 : feat/ui-rework */
  return  MaterialApp.router(
    title: 'Goldenboy_HomePg',
    debugShowCheckedModeBanner: false,
    scrollBehavior: CustomScrollBehavior(),
    builder: (context, child) {
      //builder : 공통 래퍼를 씌우는 훅
      //builder야 MerterialApp에서 나온  현재 화면을 뜻하는 child를 너에게 넘길게, 
      //context는 필요하면 써. 
      return CustomConstraints(
        background_color: Colors.white, 
        max_width:  1920, 
        child: child!
      );
    },
    /*전체 테마 설정*/
    theme: ThemeData(
      scaffoldBackgroundColor: Colors.white,
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple.shade600),
      useMaterial3:true,

      /*font*/
      fontFamily: "pretendard",
      textTheme: TextUtil.setTextTheme(),

      
    )
  );
  }
}