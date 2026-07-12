import 'dart:math';

import 'package:flutter/material.dart';
import 'package:nas_blog1/config/config.dart';
import 'package:nas_blog1/models/blog_category.dart';
import 'package:nas_blog1/ui/pages/common/theme/my_color.dart';
import 'package:nas_blog1/ui/pages/common/theme/text_util.dart';
import 'package:nas_blog1/ui/pages/common/widgets/sidebar/section/sidebar_category_tile.dart';

class SidebarCategory extends StatefulWidget {
  final List<BlogCategory> categories;
  final String? selected_slug;
  final void Function(String? slug) on_navigate;
  //인자가 있는 콜백
  final bool show_all_tile;      
  final Map<String, int> post_count_by_slug;


  const SidebarCategory({
    super.key,
    required this.categories,
    required this.selected_slug,
    required this.on_navigate,
    required this.show_all_tile,
    this.post_count_by_slug = const {},
    
    });

  @override
  State<SidebarCategory> createState() => _SidebarCategoryState();
}

class _SidebarCategoryState extends State<SidebarCategory> {
  final Set<String> expanded_ids  = {};

  void _toggle(String id) {
    setState(() {
      if(expanded_ids.contains(id)) expanded_ids.remove(id);
      else expanded_ids.add(id);
    });
  }

  @override
  Widget build(BuildContext context) {
    // final sections = _groupRootsBySection(widget.categories);
    final roots = widget.categories;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if(widget.show_all_tile) ... [
          SidebarCategoryTile(
            title: 'All',
            depth: 0,
            leading_icon : Icons.home_outlined,
            selected: widget.selected_slug == null,
            has_children : false,
            expanded: false,
            on_tap_row: () => widget.on_navigate(null),
            on_tap_chevron: null,

          ),
          const SizedBox(height:6),
        ],
        /*서버가 준 루트 트리를 그대로 렌더링 */
        for(final root in roots) ... [
          _buildNode(root, depth:0),
          const SizedBox(height: 2),

        ]
      ]
      
    );
  }

  /*
  funcs
  
  
   */
  /*카테고리 트리를 재귀로 렌더링 하면서 row클릭, 하위 카테고리 버튼, 펼침, 접힘 나타냄.  */
  Widget _buildNode(BlogCategory cat, {required int depth}) {
    // 현재 노드 상태 계산
    final has_children = cat.children.isNotEmpty;
    final expanded = expanded_ids.contains(cat.id);
    final selected = widget.selected_slug == cat.slug;
    //현재 선택된 카테고리 slug와 이 노드의 slug가 같으면 선택 상태,

    final count = widget.post_count_by_slug[cat.slug] ?? 0;

    /*UX 정책: */
    //부모 - row 클릭 => toggle
    //leaf - row 클릭 => navigate
    void onRowTap() {
      if(has_children) {
        _toggle(cat.id);
      } else {
        widget.on_navigate(cat.slug);
      }
    }

    void onChevronTap() {
      _toggle(cat.id);
    }

    return Column(
      crossAxisAlignment : CrossAxisAlignment.stretch,
      children: [
        /*한줄짜리 타일 */
        SidebarCategoryTile(
          title: cat.name, 
          depth: depth, 
          leading_icon: SidebarIconPicker.pick(cat, is_root: depth ==0), 
          selected: selected, 
          has_children: has_children, 
          expanded: expanded, 
          post_count: count,

          on_tap_row: onRowTap,
          //행 전체를 클릭하면 호출됨. 그리고 라우팅/필터 변경 등 이동 담당.
          /*sub_category는지? 있으면 expanded 상태인지? */
          on_tap_chevron: has_children  ? onChevronTap : null 
          
          ),

          /*children (펼쳐질때만) */
          AnimatedSize(
            //AnimatedSize : chlid의 크기가 바뀔때 부드럽게 높이 조절
            duration: const Duration(milliseconds:  180),
            curve: Curves.easeOut,
            child: (!has_children || !expanded)  
                  ? const SizedBox.shrink() // children없거나 expand가 아닐때는 아무것도 없음.
                  : Column(
                    children : cat.children 
                                  .map((c) => _buildNode(c, depth: depth+1))
                                  //자식 랜더링에서 재귀
                                  //depth가 추가되면서  들여스기/아이콘/스타일을 깊이에 따라 바뀌는 구조.
                                  .toList(),
                    )
            
          )
      ]
    );
  }

  /*Section grouping( 취향대로 수정 가능) */
  //최상 카테고리 목록을 받고 이름에 포함된 키워드로 섹션을 분류한뒤에 Map으로 묶어주는 함수
  Map<String, List<BlogCategory>> _groupRootsBySection(List<BlogCategory> roots) {
    final Map<String , List<BlogCategory>> out= {};
    //맵핑 위한 컨테이너
    //output 첫인자는 Section name,

    String norm(String s)  => s
                                .toLowerCase()
                                .trim()
                                .replaceAll(RegExp(r'[\s/]+'), '_')
                                .replaceAll(RegExp(r'[^a-z0-9_]+'), '');
    //norm() 이름을 판단용 키로 정규화
    //정규화 과정 : Robotics / SLAM -> 소문자로만 -> 공백/슬러시 묶어서 _ -> 특수문자 제거 -> robotics_slam
    //ex) 3D & Maker! -> 3d_maker

    String sectionOf(BlogCategory r) {
      final k = norm(r.name);
      if(k.contains('portfolio')) return 'PORTFOLIO';
      if(k.contains('slam')) return 'ROBOTICS / SLAM';
      if(k.contains('robot')) return 'ROBOTICS SYSTEMS';
      if(k.contains('embedded') || k.contains('hardware')) return 'EMBEDDED / HW';
      if(k.contains('life')) return 'LIFE';

      return 'ETC';
    }

    /*루트 들을 섹션별로 out에 추가 */
    //비유: sec = 서랍이름, out=서랍장, out[sec]= 그 서랍안의 목록
    // roots에서 하나 꺼낸 r -> 어디 서랍인지 확인(sec) -> 서랍(sec)없으면 새 서랍 만들고 -> 그 서랍에 r을 넣는다. 
    for(final r in roots) {
      final sec = sectionOf(r);
      //각 루트 마다 해당하는 String을 출력함.
      if(!out.containsKey(sec)) { 
        out[sec] = [];
        //그 서랍 없으니 그 key로 빈 리스트 만듬
        //out[sec]가 없으면 []만들고 out[sec]에 넣고,
      }
      out[sec]!.add(r);
      //out[sec]가 있으면 그냥 그걸 그대로 사용.
      //그 서랍 안에 r 넣는다.
    }

    // 표시 순서(원하면 바꿔도 됨)

    List<String> orderKey(Map<String, List<BlogCategory>> o)
    {
      final List<String> keys = [];
      if(o.containsKey('PORTFOLIO'))  keys.add('PORTFOLIO');
      if(o.containsKey('ROBOTICS / SLAM')) keys.add('ROBOTICS /SLAM');
      if (o.containsKey('ROBOTICS SYSTEMS')) keys.add('ROBOTICS SYSTEMS');
      if (o.containsKey('EMBEDDED / HW')) keys.add('EMBEDDED / HW');
      if (o.containsKey('3D / MAKER')) keys.add('3D / MAKER');
      if (o.containsKey('DATA')) keys.add('DATA');
      if (o.containsKey('DEVOPS')) keys.add('DEVOPS');
      if (o.containsKey('LIFE')) keys.add('LIFE');
      if (o.containsKey('ETC')) keys.add('ETC');

      return keys;
    }
    
    final  List<String> ordered_keys = orderKey(out);

    final Map<String, List<BlogCategory>> ordered = {};
    for(final k in ordered_keys) {
      final list = out[k];
      if(list !=null && list.isNotEmpty)
        ordered[k] = list;
    }

    for(final entry in out.entries) {
      if(!ordered.containsKey(entry.key) && entry.value.isNotEmpty) {
        ordered[entry.key] = entry.value;
      }
    }
    return ordered;
  }

} // end


class sectionHeader extends StatelessWidget {
  final String title;
  const sectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 14, right: 14, top: 14, bottom: 6),
      child: Row(
        children: [
          Text(
            title,
            style: TextUtil.get12(
              context,
              MyColor.gray60,
              font_weight: FontWeight.w800
            )),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                height: 1, 
                color: Colors.grey.withOpacity(0.18),
              )
            )
        ]
          )
        
      );
  }
}