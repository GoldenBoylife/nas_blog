import 'package:flutter/material.dart';

class CommonScaffoldDesktop extends StatelessWidget {
  final Widget top_bar;
  final Widget content;
  final Widget? side_bar;
  final double side_bar_width;

  const CommonScaffoldDesktop({
    required this.top_bar,
    required this.content,
    required this.side_bar,
    required this.side_bar_width,
    super.key
    
    });

  @override
  Widget build(BuildContext context) {
    final bool show_sidebar = (side_bar != null);
    const double gap = 16;

    return Scaffold(
      body: Column(
        children: [
          top_bar,
          Expanded(
            child: Row(
              children: [
                if(show_sidebar)
                SizedBox(
                  width: side_bar_width,
                  child: side_bar!,
                ),
                const SizedBox(width: gap),
                //side바 최외곽 gap

                Container(width: 1, color: Colors.black12),
                //side바 최와곽 윤곽선
                const SizedBox(width: gap),
                
                Expanded(child: content),
              ]
            )
          )
        ]
      )
    );
  }
}