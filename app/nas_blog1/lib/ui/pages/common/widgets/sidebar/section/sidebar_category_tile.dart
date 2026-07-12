import 'package:flutter/material.dart';
import 'package:nas_blog1/config/category_icon_registry.dart';
import 'package:nas_blog1/models/blog_category.dart';

/*category에서 한줄짜리 타일 */
class SidebarCategoryTile extends StatelessWidget {
  final String title;
  final int depth;

  final IconData leading_icon;
  final bool selected;

  final bool has_children;
  final bool expanded;

  final VoidCallback on_tap_row; //행 클릭 콜백 -> categoryPg로 이동
  final VoidCallback? on_tap_chevron; //sub_category위해서 화살표 클릭 콜백
  final int post_count;

  const SidebarCategoryTile({
    super.key,
    required this.title,
    required this.depth,
    required this.leading_icon,
    required this.selected,
    required this.has_children,
    required this.expanded,
    required this.on_tap_row,
    required this.on_tap_chevron,
    this.post_count = 0,
    });

  @override
  Widget build(BuildContext context) {
    final left_pad = 12.0 + depth * 14.0;

    return InkWell(
      onTap: on_tap_row,
      child: Container(
        height: 44,
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        padding: EdgeInsets.only(left: left_pad, right: 10),
        decoration: BoxDecoration(
          color: selected? Colors.black.withOpacity(0.06) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            //IconBubble
            IconBubble(icon: leading_icon),
            const SizedBox(width: 10),

            Expanded(
              child: Text(
                title,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
            ),

            if (post_count > 0) ...[
              const SizedBox(width: 8),
              _PostCountBadge(count: post_count),
            ],

            if (has_children)
              GestureDetector(
                behavior : HitTestBehavior.opaque,
                onTap: on_tap_chevron,
                child: SizedBox(
                  width: 34,
                  height:34,
                  child: Icon(
                    expanded
                      ? Icons.keyboard_arrow_down
                      : Icons.chevron_right,
                      size: 18
                  )
                )
              )

          ]
        )
      )

    );
  }
}
class _PostCountBadge extends StatelessWidget {
  final int count;

  const _PostCountBadge({
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 24),
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.055),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$count',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 11,
          height: 1.0,
          fontWeight: FontWeight.w800,
          color: Colors.black.withOpacity(0.58),
        ),
      ),
    );
  }
}

class IconBubble extends StatelessWidget {
  final IconData icon;
  const IconBubble({super.key, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        //겉모양(스타일)
        color: Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(999),


      ),
      child: Icon(icon, size: 16),
    );
  }

}

class SidebarIconPicker{
  static String _norm(String s) {
    return s
            .toLowerCase()
            .trim()
            .replaceAll(RegExp(r'[\s/]+'), '_')
            .replaceAll(RegExp(r'[^a-z0-9_]+'), '');
  }


  static IconData pick(BlogCategory c, { bool is_root = false}){
    if(c.icon_key != null && c.icon_key!.isNotEmpty) {
      return CategoryIconRegistry.iconFromKey(c.icon_key);
    }
    final key = '${_norm(c.slug)}_${_norm(c.name)}';

    if(key.contains('portfolio')) return Icons.work_outline;
    if (key.contains('mapping_algorithms') ||
        key.contains('mappingalgorithm') ||
        key.contains('algorithm')) {
      return Icons.auto_graph_rounded;
    }

    if (key.contains('mapping_sensors') ||
        key.contains('mappingsensor') ||
        key.contains('sensor')) {
      return Icons.sensors_rounded;
    }

    if (key.contains('slam')) return Icons.map_outlined;
    if (key.contains('paper') || key.contains('note')) return Icons.article_outlined;

    if(key.contains('experiment') || key.contains('dataset') || key.contains('metric')) {
      return Icons.science_outlined;
    }


    if(key.contains('robot')) return Icons.smart_toy_outlined;
    if(key.contains('system_design') || key.contains('pipeline') || key.contains('state')) {
      return  Icons.account_tree_outlined;
    }

    if(key.contains('path_planning') || key.contains('planning')) return Icons.alt_route_outlined;
    if(key.contains('perception') || key.contains('ai')) return Icons.visibility_outlined;

    if(key.contains('embedded') || key.contains('hardware')) return Icons.view_in_ar_outlined;
    if(key.contains('stm32') || key.contains('fusion')) return Icons.design_services_outlined;
    if(key.contains('print')) return Icons.print_outlined;
    
    if(key.contains('life') ) return Icons.local_cafe_outlined;
    if(key.contains('travel') ) return Icons.flight_takeoff_outlined;
    if(key.contains('car') ) return Icons.directions_car_outlined;
    if(key.contains('daily') ) return Icons.event_note_outlined;
    

    return is_root ? Icons.folder_outlined : Icons.circle_outlined;
  }
}
