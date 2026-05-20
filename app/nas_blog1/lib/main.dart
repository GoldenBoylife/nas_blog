import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nas_blog1/config/route_page.dart';


import 'package:nas_blog1/ui/pages/home/home_pg.dart';

import 'package:flutter_localizations/flutter_localizations.dart'
  show 
    GlobalCupertinoLocalizations,
    GlobalMaterialLocalizations,
    GlobalWidgetsLocalizations; 
  //show: 필요한 기능만 로드함. 
import 'ui/pages/category/category_pg.dart';
import 'ui/pages/common/widgets/interaction/custom_scroll_behavior.dart';
import 'ui/pages/common/widgets/pageWidget/custom_constraints.dart';
import 'ui/pages/common/theme/my_color.dart';
import 'ui/pages/common/theme/text_util.dart';
import 'ui/pages/editor/editor_pg.dart';
import 'ui/pages/not_found/not_found_pg.dart';
import 'ui/pages/post/post_pg.dart';


void main() {

  runApp( MyApp());
}

class MyApp extends StatelessWidget {
   MyApp({super.key});

/*URL -> Page 객체를 만들어주는 라우팅 테이블 + 컨트롤 */
//BeamerDelegate : 라우팅, 네비게이션 총괄 컨트롤러 객체
 final BeamerDelegate router_delegate = BeamerDelegate(
  transitionDelegate: const NoAnimationTransitionDelegate(),
  beamBackTransitionDelegate:  const NoAnimationTransitionDelegate(),
  initialPath: RoutePage.home,
  notFoundRedirectNamed: RoutePage.not_found,
  

/* pages
  home
  category
  post
  editor
  notFound

 */


  locationBuilder: RoutesLocationBuilder(
    routes: {
      RoutePage.home : (context, state, data) {
        //전역 상태에 따라서 다른 위젯 사용해야 할지도 모르니 context와 state를 Routing할때부터줌.
        //state: 현재 url에 나온 정보 전부, 이걸로 post id나 slug 알수 있음. 
        //data : url에 없는 데이터 넣을 때, 안써도 됨. 
        return const BeamPage(
          key: ValueKey("Home"), //페이지 고유식별자
          title: "GoldenBoy 로봇 개발 놀이터",  //탭제목이나, 메타 정보
          child: HomePg(), //실제 화면
        );
        //이 RoutePage로 들어왔을때 어떤 화면 보여줄지를 BeamPage객체로 반환
        //여기서는 HomePg 에 있는 stf로 보여줌.
        //왜 BeamPage로 감싸는지? Beamer는 Page단위(meta포함)로 스택을 관리해서, 
        //  - 뒤로가기 히스토리
        //  - 페이지 교체 판단 등등 Page 단위의 meta 정보가 있어야 이게 가능
      },
    
    RoutePage.category: (context,state,data) {
      final slug = state.pathParameters['slug'] ?? '';
      return  BeamPage(
        key: ValueKey('category-$slug'),
        title: slug,
        child: CategoryPg(slug:slug), // accoding to my Page.


      );
    },
    RoutePage.post: (context,state,data) {
      final id = state.pathParameters['id'] ?? '';
      return BeamPage(
        key: ValueKey('post-$id'),
        title: 'Post',
        child: PostPg(post_id :id)
      );
    },
    
    RoutePage.editor : (context, state, data) {
      return BeamPage(
        key: ValueKey('editor'),
        title: 'Editor',
        child: EditorPg(),
      );
    },
    RoutePage.not_found : (context, state, data) {
      return BeamPage(
        key : ValueKey('404'),
        title: 'Not Found',
        child: NotFoundPg(),
      );
    }
    

    },
    ).call
    // RouteLocationBuild 객체의 call메서드 써서, locationBuild 자리에 넣는다. 
  
 );


  // This widget is the root of your application.
  //최상위 위젯 트리 : 앱 전역 설정, theme, font, textTheme, 버튼 스타일 등등,레이아웃 설정 등
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
      //객체가 자기만의 상태를 가지고 있어야 하면 인스턴스 만들고,
      // 단순 입출력만 하는 도구이면 static으로 인스턴스 없이 만든다. 
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if(states.contains(WidgetState.disabled))
              return Colors.grey;
            return MyColor.blue40;

          }),
          backgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if(states.contains(WidgetState.disabled))
              return Colors.grey;
            return null;

          }),
        )
      )

      
    ),
    /*MaterialApp써야 이거 쓸 수 있음.  */
    //Beamer는 Navigator 2.0기반이라 MaterialApp 꼭써야함.
    routerDelegate: router_delegate,
    //앞서 선언했던 router_delegate  넣음.
    routeInformationParser : BeamerParser(), 
    //원시 url 읽어서 Beamer가 이해 가능한 형태로 파싱함
    backButtonDispatcher: BeamerBackButtonDispatcher(delegate: router_delegate),
    //back 이벤트를 누가 처리할지 연결함.
    
    /*다국어, 지역 지원위해서 */
    localizationsDelegates:  const [
      GlobalMaterialLocalizations.delegate, //기본 문자열 지역화
      GlobalWidgetsLocalizations.delegate,  //기본 widgets 레벨에서 필요한 것 지역화
      GlobalCupertinoLocalizations.delegate, // iOS 스타일(Cupertino) 위젯 지역화
    ],
    
    //우리 앱이 지원하는 언어 목록 선언함. 
  );
  }
}