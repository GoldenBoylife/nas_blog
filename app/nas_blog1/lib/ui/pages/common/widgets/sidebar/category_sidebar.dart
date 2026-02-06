import 'package:flutter/material.dart';
import 'package:nas_blog1/constants/asset_path.dart';
import 'package:nas_blog1/models/blog_category.dart';
import 'package:nas_blog1/ui/pages/common/theme/my_color.dart';
import 'package:nas_blog1/ui/pages/common/theme/text_util.dart';


  /*header Icon widget */
class _HeaderIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback? on_tap;
  const _HeaderIcon(this.icon, {this.on_tap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap : on_tap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 20),
      ),
    );
  }
}

class CategorySidebar extends StatefulWidget {
  final List<BlogCategory> categories;
  final String? selected_slug;
  final void Function(String? slug) on_navigate; // null => All(Home)
  final bool show_all_tile;
  final VoidCallback? on_home; //홈으로보내는 명시적 콜백 

  // B방식: "갱신 버튼" 정도만 넣어도 편해요 (선택)
  final VoidCallback? on_refresh_requested;

  const CategorySidebar({
    super.key,
    required this.categories,
    required this.selected_slug,
    required this.on_navigate,
    this.on_refresh_requested,
    this.show_all_tile = true,
    this.on_home,
  });

  @override
  State<CategorySidebar> createState() => _CategorySidebarState();
}





class _CategorySidebarState extends State<CategorySidebar> {
  final Set<String> _expanded_ids = {}; //펼쳐진 parent id 집합



/*funcs */

Widget _buildHeader(BuildContext context) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      // ✅ 배경 + 로고를 같은 레이어에서 처리
      SizedBox(
        height: 180,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 배경
            Positioned.fill(
              child: Image.asset(
                AssetPath.logo_background_jpg,
                fit: BoxFit.cover,
              ),
            ),

            // 로고 (가운데 정확히)
            Image.asset(
              AssetPath.logo_png,
              width: 120,   // 👈 여기서 크기 조절
              height: 120,
              fit: BoxFit.contain,
            ),
          ],
        ),
      ),

      const SizedBox(height: 12),

      // 텍스트
      Column(
        children: [
          Text(
            'Dr.GoldenBoy Lab',
            style: TextUtil.get16(
              context,
              MyColor.gray90,
              font_weight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'GB_',
            style: TextUtil.get13(
              context,
              MyColor.gray60,
            ),
          ),
        ],
      ),

      const SizedBox(height: 16),

      // 아이콘 버튼
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children:  [
          _HeaderIcon(
            Icons.home_outlined,
            on_tap: widget.on_home?? () => widget.on_navigate(null),
            ),
          // const _HeaderIcon(Icons.search),
          // const _HeaderIcon(Icons.person_outline),
        ],
      ),

      const SizedBox(height: 12),
      const Divider(height: 1),
    ],
  );
}



  Widget _buildAllTile() 
  {
    return _tile(
            title: 'All',
            selected: widget.selected_slug == null,
            on_tap: () => widget.on_navigate(null),
            leading: Icons.folder_outlined,
            // trailing: const Icon(Icons.chevron_right, size: 18),
          
        
      
    );
  }
/*Tree */
Widget _buildCategoryNode(BlogCategory cat) {
  final bool has_children   = cat.children.isNotEmpty;
  final bool expanded = _expanded_ids.contains(cat.id);
  //사이드바에서 펼쳐져 있느 카테고리들의 id를 저장해둔 목록,
  //현재 어떤 폴더가 열려 있는지, 닫혀 있는지 기억하는 상태 저장소

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _tile(
        title: cat.name,
        selected: widget.selected_slug == cat.slug,
        leading: Icons.folder_outlined,
        trailing: has_children
          ? Icon(
            expanded
              ? Icons.expand_less
              : Icons.expand_more,
            size: 18,
          )
          : null,
        on_tap: () {
            if(has_children) {
              setState((){
                expanded 
                  ? _expanded_ids.remove(cat.id)
                  : _expanded_ids.add(cat.id);
              });
            } else {
              widget.on_navigate(cat.slug);
            }

          }
        
      ),
      if(expanded) 
        ...cat.children.map((child) => _buildSubTile(child)),
    ]
  );
}

Widget _buildSubTile(BlogCategory cat) {
  final bool selected = widget.selected_slug == cat.slug;

  return _tile(
    title: cat.name,
    selected: selected,
    leading : Icons.subdirectory_arrow_right,
    padding_left: 32,
    on_tap: () => widget.on_navigate(cat.slug)
  );
}



  Widget _tile({
    required String title,
    
    required bool selected,
    required IconData leading,
    required VoidCallback on_tap,

    Widget? trailing,
    double padding_left= 14,
  }) {
    return InkWell(
      onTap: on_tap,
      child: Container(
        height: 44,
        padding:  EdgeInsets.only(
          left: padding_left,
          right: 14,
        ),
        decoration: BoxDecoration(
          color: selected ? Colors.black.withOpacity(0.06) : Colors.transparent,
          border: Border(
            left: BorderSide(
              width: 3,
              color: selected ? Colors.black : Colors.transparent,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(leading, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const SizedBox(height: 12),

            // 상단 프로필/로고 영역
            _buildHeader(context),


            // const SizedBox(height: 12),
            // const Divider(height: 1),

            if(widget.show_all_tile)
              _buildAllTile(),
            const SizedBox(height: 8),

            ...widget.categories.map(_buildCategoryNode),
          
          ]
        ),
      ),
    );
  }


}