/*

splite the screen into three separate sections.
1. TopBar : logo, search, menu
2. Left Sidebar: category list
3. Main Content: display a grid of cards showing the posts that belong to the selected category.
4. Determine the overall page layout based on the user's device.
 */

import 'package:flutter/material.dart';
import 'package:nas_blog1/models/screen_model.dart' show ScreenModel;
import 'package:nas_blog1/ui/common_widgets/full_bleed.dart';

import 'package:nas_blog1/ui/pages/common/widgets/menu/menu.dart';
import 'package:nas_blog1/ui/pages/common/widgets/menu/top_bar.dart';
import 'package:nas_blog1/ui/pages/common/widgets/overlay/with_overlay.dart';
import 'package:nas_blog1/ui/pages/common/widgets/pageWidget/common_scaffold_desktop.dart';
import 'package:nas_blog1/ui/pages/common/widgets/pageWidget/common_scaffold_mobile.dart';
import 'package:nas_blog1/ui/pages/common/widgets/pageWidget/common_scaffold_tablet.dart';
import 'package:nas_blog1/ui/pages/common/widgets/pageWidget/footer.dart';

class CommonScaffold extends StatefulWidget {


  final int current_index; //현재 선택도니 메뉴가 무슨 항목인지
  final ScreenModel screen_model; //디바이스기종에 따라서, 
  final List<Widget> children; //밖에서 children 선언해서 여기로 가져옴. 
  final Widget? side_bar; //왼쪽 사이드바(카테고리). 필요 없는 페이지는 sidebar 안나오게 가능
  //이 페이지가 사이드바가 계속 필요한 페이지인지만 결정해서 한번에 넘겨줌. 

  final bool black; //블랙테마 켜고 끄는 것.
  final double horizontal_padding; //화면 크기에 따라서 padding 달라지게, 

  final bool use_page_scroll; //기본 true

  final List<Widget> top_bar_actions; 
  final double? content_max_width; // null이면 제한 없음.
  final Widget? content_overlay; //content위에 고정으로 올릴 위젯


  const CommonScaffold({

    required this.current_index,
    required this.screen_model,
    required this.children, //페이지 별로 써야 할 children이 다르고, 그걸 외부에서 가져옴. 
    this.side_bar,
    this.black = true,  //밤낮모드
    this.horizontal_padding = 0,  
    this.use_page_scroll = true,
    this.top_bar_actions = const <Widget>[],
    this.content_max_width, 
    this.content_overlay,
    super.key});



  @override
  State<CommonScaffold> createState() => _CommonScaffoldState();
}

class _CommonScaffoldState extends State<CommonScaffold> {

  /*내부에서만 쓰는 변수 */
  //살아 있는 동안 사용자의 행동/스크롤 등으로 바뀌는 상태값이라서 여기둠.
    static const double top_bar_height = 64;
    //static const : 클래스 상수 
    // TopBar(메뉴) 높이
    static const double side_bar_width = 280;
    //inpa 느낌으로 : 좌측 고정 사이드 바 폭

  late final ScrollController scroll_controller;
  bool _is_drawer_open = false; //mobile drawer overlay 상태


  

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    scroll_controller = ScrollController();

    
  }

  @override
  void dispose() {
    // TODO: implement dispose
    scroll_controller.dispose();
    super.dispose();
  }

  void toggleDrawer() {
    setState(() {
      print('_is_drawer_open : $_is_drawer_open');
      _is_drawer_open = !_is_drawer_open;
    });
  }
  void closeDrawer() {
    
      if(_is_drawer_open) {
      setState(() {
        _is_drawer_open = false;
      });
      }    
  }

  @override
  Widget build(BuildContext context) {
    


    final bool is_mobile =  widget.screen_model.mobile; 
    final bool is_tablet = widget.screen_model.tablet;
    final bool is_desktop = widget.screen_model.web;

    final bool show_sidebar = (widget.side_bar != null);
    //사이드바가 필요 없는 페이지면 null을 넘기니까.
    //만약 필요 없는페이지라면,show_sidebar에 false가 들어오고, 
    //만약 필요한 페이지라면, show_sidebar에 true 들어오고, 

    /*footer는 build 에서 add 금지 -> 여기서 합침 */
    final List<Widget> content_children = [];

    /*위에서 읽어온 children들 모두 push_back하고 맨 마지막에 footer를 넣으려는 의도 */
    for(final child in widget.children) {
      //final: 한번 정해지면 다시 다른 값으로 재할당 불가
      //for문에서는 이 변수는 읽기 전용으로 쓴다고 표시하는 것. 
      //C++에서 읽기 전용인 const와 비슷한 개념.
      content_children.add(child);
    }
    content_children.add(const Footer());




    /*Content 영역*/
      /*scroll영역 */
      /*
      history : 
      1. scroll 영역 존재하기위해서 SingleChildScrollView 존재 
      2. scroll을 각페이지(homePg)에서 관리하기위해서 쓸지 안쓸지로 결정하도록 use_page_scroll 추가함
      */

    final EdgeInsets content_padding = 
      EdgeInsets.symmetric(horizontal: widget.horizontal_padding);
    

    /*기존 page 전체 스크롤, InkWell, Card 안쓰는 곳에서는 필요하니께 */
    //use_page_scroll에 따라서 content만 달라짐
    //padding을 각 item에 적용함. 
    late final Widget content;

    if(widget.use_page_scroll){
        content = SingleChildScrollView(
        controller: scroll_controller,
        padding: content_padding,
        child:  
          Column(
            crossAxisAlignment:  CrossAxisAlignment.stretch,
            children: content_children.map((c) => _wrapItem(c, content_padding)).toList(),
          ),
        
      );
    } else {
      content = ListView.builder(
        //ListView는 가로폭이 무한이라 wrap 잘 안먹혀서, 각 item을 감싸는 방식이 안정적
        controller: scroll_controller,
        itemCount: content_children.length,
        itemBuilder: (_, i) => _wrapItem(content_children[i], content_padding)

          );
        }
        /*overlay는 스크롤 밖에서 Stack으로 올림 */
        final content_with_overlay = WithOverlay(
          child: content,
          overlay: widget.content_overlay,
        );

        /* */


    

    /*menu대신 임시로 top_bar , top_bar는 공통이니, */
    final Widget top_bar = TopBar(
      height: top_bar_height,
      black: widget.black,
      show_hamburger: (!is_desktop && show_sidebar),
      //데탑모드 아니거나, sidebar가 필요한 곳이면,

      on_tap_hamburger:  toggleDrawer,
      actions: widget.top_bar_actions,

    );
    if( is_desktop) 
    {
      return CommonScaffoldDesktop(
        top_bar : top_bar,
        content: content_with_overlay,
        side_bar : widget.side_bar,
        side_bar_width : side_bar_width,
      );
    }
    else if(is_tablet) {
      return CommonScaffoldMobile(
        top_bar: top_bar,
          content: content_with_overlay,
          side_bar: widget.side_bar,
          side_bar_width: side_bar_width,
          top_bar_height: top_bar_height,
          is_drawer_open: _is_drawer_open,
          on_close_drawer: closeDrawer,
      );
    }
      return CommonScaffoldMobile(
          top_bar: top_bar,
          content: content_with_overlay,
          side_bar: widget.side_bar,
          side_bar_width: side_bar_width,
          top_bar_height: top_bar_height,
          is_drawer_open: _is_drawer_open,
          on_close_drawer: closeDrawer,
          //함수를 쓰는게아니라 callback으로 넘기는 함수포인터라서 ()안씀.
          // ()를 쓰면 곧바로 쓰는 거라 출력이 여기서 나와서 안됨.
          );
    }

    /*use_page_scroll false일때  */
    // Column+Expanded로 뷰포트를 꽉 채우기 형태로 구성 
    // content 자체는 스크롤 하지 않음.



  /*
  funcs
  - _wrapContentMaxWidth
  - _wrapItem
   */

  Widget _wrapContentMaxWidth(Widget child) {
    if(child is FullBleed) return child;
    //FullBleed이면 부모 폭 제한 무시, 
    
    final max_w = widget.content_max_width;
    if(max_w == null) return child;

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth : max_w),
        child: child,
      )
    );

  }

  Widget _wrapItem(Widget child, EdgeInsets content_padding) {
    // 1) full-bleed면 padding/maxWidth 둘다 적용 안함
    if(child is FullBleed) return child;

    // 2) 기본은 padding -> maxWidth 순서로 적용
    return Padding(
      padding: content_padding,
      child: _wrapContentMaxWidth(child)
    );
  }


} //end
