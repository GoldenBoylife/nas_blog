import 'package:flutter/material.dart';

class CommonScaffoldTablet extends StatelessWidget {
  final Widget top_bar;
  final Widget content;
  final Widget? side_bar; //필요 있을 때도 없을때도 있음.

  final double side_bar_width;
  final double top_bar_height;

  final bool is_drawer_open;
  final VoidCallback on_close_drawer;//함수동작


  const CommonScaffoldTablet({
    required this.top_bar,
    required this.content,
    required this.side_bar,
    required this.side_bar_width,
    required this.top_bar_height,
    required this.is_drawer_open,
    required this.on_close_drawer,
    super.key});

  @override
  Widget build(BuildContext context) {
    final bool show_sidebar = (side_bar != null);
    //side_bar가 필요 없는 곳에서는 show_sidebar는 false다.
     
    final bool use_overlay_drawer = show_sidebar;
    //논리적으로 use_overlay_drawer가 true면, show_sidebar는 widget이 있으므로 null아님. 
    //나중에 LOGIN,editor,signup페이지에서는 show_side바가 필요 없기 때문에 적은것. 


    return  Scaffold(
      body : Stack(
        children: [
          //top_bar 아래부터 content 
          Positioned.fill(
            top: top_bar_height,
            child: content,
          ),
          //top bar
          Positioned(
            left: 0,
            top:0,
            right:0,
            height: top_bar_height,
            child: top_bar,
          ),
          /*overay sidebar */
          // sidebar slide 애니메이션~
          if(use_overlay_drawer)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              left: is_drawer_open ? 0 : -side_bar_width,
              //true면, overray side bar가 왼쪽에 딱 붙어서 보임.
              //false면, 화면 밖으로 나가서 완전 숨겨짐.
              //이걸 250ms동안 천천히보여줌.
              top: top_bar_height,
              bottom: 0,
              width: side_bar_width,
              child: Material(
                elevation: 12,
                color: Colors.white,
                child: side_bar!,  // null이 아니라고 확신!, null-safety라함.
              )
            ),
            // dim + tap to close
            /*when the sidebar(drawer) opens, semi-transparent layer is displayed over the main body content*/
            if(use_overlay_drawer && is_drawer_open) 
              Positioned.fill(
                top: top_bar_height,
                child: GestureDetector(
                  
                  child: Container(color: Colors.black.withOpacity(0.35)),
                  //배경 어둡게, 본문 클릭 막기,
                  onTap: on_close_drawer,
                  //사용자가 어두운 부분을 탭하면 drawer가 닫히게,
                  
                )
              ),
              
        ]
      )
    );
  }
}