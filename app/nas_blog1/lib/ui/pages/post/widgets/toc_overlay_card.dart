import 'package:flutter/material.dart';


  class TocItem {
   final int depth;
   final String text;
   TocItem({required this.depth, required this.text});

  }


class TocOverlayCard extends StatelessWidget {
  final String markdown;
  final VoidCallback on_close;
  const TocOverlayCard({
    super.key,
    required this.markdown,
    required this.on_close,
    });



  @override
  Widget build(BuildContext context) {
    final headings = _extractHeadings(markdown);

    return Card(
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12,10,12,12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.list_alt,size : 18),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text('목차', style: TextStyle(fontWeight: FontWeight.w800)),
                ),
                IconButton(
                  onPressed: on_close,
                  icon: const Icon(Icons.close),
                  tooltip: 'Close',
                )
              ]
            ),
            const SizedBox(height:6),
            SizedBox(
              height: 320,
              child: headings.isEmpty
                ? const Center(child: Text('목차가 없습니다.'))
                : ListView.builder(
                  itemCount: headings.length,
                  itemBuilder: (_,i) {
                    final h = headings[i];
                    return Padding(
                      padding: EdgeInsets.only(left: (h.depth -1) * 12.0),
                      child: ListTile(
                        dense: true,
                        visualDensity: VisualDensity.compact,
                        title: Text(h.text, maxLines: 2, overflow: TextOverflow.ellipsis),
                        onTap: () {

                        },)
                      );
                  }
                )
            )
          ]
                  
                )

            )

          
        );
      
  }


  /*
  funcs 
  - _extractHeadings
  */



  List<TocItem> _extractHeadings(String md) {
    final lines = md.split('\n');
    final items = <TocItem>[];
    for(final line in lines) {
     final m = RegExp(r'^(#{1,3})\s+(.+)$').firstMatch(line.trim());    
     if( m == null) continue;
     final depth = m.group(1)!.length;
     final text = m.group(2)!.trim();
     items.add(TocItem(depth: depth, text: text));
     }
     return items;
  }











}