import 'package:flutter/material.dart';
import 'package:nas_blog1/ui/pages/common/theme/text_util.dart';

class TopBar extends StatelessWidget {
  final double height;
  final bool black;
  final bool show_hamburger;
  final VoidCallback? on_tap_hamburger;
  //VoidCallback? 인자 없고 return 없는 함수, ?이니 null일수도 있음. 
  //눌렀을때 실행할 콜백이고 flutter 위젯 API대부분이 이런 패턴 씀. onPressed, onTap, onChanged
  

  final List<Widget> actions;

  const TopBar({
    this.height = 64,
    required this.black,
    required this.show_hamburger,
    this.on_tap_hamburger,
    this.actions = const  <Widget>[], //default
    
    super.key});

  @override
  Widget build(BuildContext context) {
    final _icon_color = black ? Colors.white : Colors.black;

    return Container(
      height : height,
      padding : const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: black ? Colors.black : Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.withOpacity(0.2)),
        )
      ),
      child: Row(
        children: [
          if(show_hamburger)
            IconButton(
              onPressed: on_tap_hamburger,
              icon: Icon(
                Icons.menu,
                color: black ? Colors.white: Colors.black,
              ),
              tooltip : 'Open sidebar',
            ),
          if(show_hamburger) const SizedBox(width: 8),
          // Text(
          //   "Dr.GoldenBoy Lap",
          //   style: TextStyle
          // )
          Text("Dr.GoldenBoy Lap",
              style: TextUtil.get18(
                context,
                _icon_color,
                //font color니까 배경과 반대로 해야됨. 
               )),
          const Spacer(),
          Icon(
            Icons.search,
            color: _icon_color
          ),
          const SizedBox(width: 8),
          
          ...actions

        ]
      )
    );
  }
}