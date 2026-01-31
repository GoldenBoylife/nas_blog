import 'package:flutter/material.dart';
import 'package:nas_blog1/ui/pages/post/widgets/toc_overlay_card.dart';

class StickyToc extends StatefulWidget {
  final String markdown;
  final double left;
  final double top;


  const StickyToc({
    super.key,
    required this.markdown,
    this.left = 16,
    this.top = 92,
    });

  @override
  State<StickyToc> createState() => _StickyTocState();
}

class _StickyTocState extends State<StickyToc> {
  bool _open = true;
  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.left,
      top: widget.top,
      child : AnimatedContainer(
        // Container의 애니메이션 버전이고 부드럽게 보간됨.
        duration: const Duration(milliseconds: 180),
        width: _open ? 280 : 44,
        child: Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(12),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              //header bar
              SizedBox(
                height: 44,
                child: Row(
                  children: [
                    IconButton(
                      tooltip : _open ? 'Close TOC' : 'Open TOC',
                      onPressed: () => setState(() => _open = !_open),
                      icon: Icon(_open ? Icons.chevron_left : Icons.chevron_right),
                    ),
                    if(_open) const Text('TOC'),
                  ]
                )
              ),
              if (_open) 
                SizedBox(
                  height: 420, //취향: 화면에 맞게 clamp도 가능
                  child: TocOverlayCard(
                    markdown: widget.markdown, 
                    on_close: () => setState(() => _open = false
                    )),
                  )
            ]
          )
          
          )
        )
        
        );
  }
}