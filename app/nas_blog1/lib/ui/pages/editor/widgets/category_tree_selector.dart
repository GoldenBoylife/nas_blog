

import'package:flutter/material.dart';
import 'package:nas_blog1/models/blog_category.dart';

/// CategoryTreeSelector 
/// ------------------------------------
/// Purpose
/// - flat 카테고리 목록을 tree UI로 렌더링
/// Inputs
/// - categories_flat: flat한 카테고리목록 (parent_id 기반)
/// - selected_slug : 현재 선택된 카테고리, 일치하면 체크 표시
/// - on_select : 사용자가 카테고리 선택하면 호출되는 콜백(부모 위젯에서 상태 변경함)
///
/// How it works
/// 1. categories_flat을 parent_id로 그룹핑하여 tree 형태로 렌더링,
/// 2. depth에 따라서 들여쓰기 적용하여 계층 표현
/// 3. checkboxListTile을 사용해서 선택표시
class CategoryTreeSelector extends StatelessWidget {

  final List<BlogCategory> categories_flat;
  final String? selected_slug;
  final void Function(String slug) on_select;


  const CategoryTreeSelector({
    super.key,
    required this.categories_flat,
    required this.on_select,
    required this.selected_slug
    });


  @override
  Widget build(BuildContext context) {
    if(categories_flat.isEmpty) {
      return const Text('No categories');
    }


    final by_parent = _groupByParent(categories_flat);


    return Container(
      constraints: const BoxConstraints(maxHeight: 280),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Scrollbar(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 6),
          children: _buildNodes(by_parent: by_parent, parent_id : null, depth: 0)
        )
      )
    );
  }

  /*
  funcs 
  -  _groupByParent
  -  _buildNodes
      _compareCategoryByName
      _buildCategoryNode
  */

  Map<String? , List<BlogCategory>> _groupByParent(List<BlogCategory> c_flat) {

    /*flat한 Category를 sub_category로 만들기 위해서 id기준으로 category들 그룹핑해서 부모-자식 구조로 만든다.*/
    final Map<String?, List<BlogCategory>> by_parent = {};
    //by_parent : id기준으로 묶인 카테고리들, 딕셔너리
    //key: id값
    //value : 카테고리 리스트
    for(final c in c_flat) {
      final parent_id = c.parent_id;
    
      /*딕셔너리에서 key값이 없다면 */
      if(!by_parent.containsKey(parent_id)) {        
        by_parent[parent_id] = <BlogCategory>[];
        //<BlogCategory>[] : 빈 리스트 리터럴 객체 값 이고 BlogCategory타입만 담음
        //parent_id에 해당하는 바구니가 아직 없으면 일단 빈 바구니 만든다.
      }
      by_parent[parent_id]!.add(c);
      // !: 여기는 null이 아님을  보장한다. 그 카테고리를 추가한다.
      // id 값 기준으로 그 카테고리를 카테고리 리스트로 넣는다.
    }
    return by_parent;
  }

  List<Widget> _buildNodes(
    {required Map<String?, List<BlogCategory>> by_parent,
    required String? parent_id,
    required int depth,
    })
  {
    final list = List<BlogCategory>.from(by_parent[parent_id] ?? const <BlogCategory>[]);
    //.from : by_parent 자체를 바로 sort 하게되면 원소스가 꼬여서 다른 곳에도 영향 줄 수 있으니
    //sort하기전에 복사부터 한다.
    //by_parent[parent_id] : category리스트
    // 그 리스트가 null이라면? 빈리스트인 const []를 넣는다.
    // 값이 있으면 그 리스트를 list에 저장한다.

    final int Function(BlogCategory a, BlogCategory b) compareCategoryByName = _compareCategoryByName;
    list.sort(compareCategoryByName);
    //치환: list.sort((a,b) => a.name.compareTo(b.name));
    //sort : 정렬
    //(a,b) =>  비교 함수
    //a.name.compareTo(b.name) : 음수면 a먼저, 같으면 0, 양수면 b먼저, 그 결과값을 list로 넘김. 
    //여기서 정렬 완료됨. 

    final widgets = <Widget>[];
    for(final c in list) 
    {
      widgets.add(_buildCategoryNode(c: c, by_parent: by_parent,depth: depth));
      //c는 이미정렬된 카테고리가 들어감. 

    }
    return widgets;
  }

  int _compareCategoryByName(BlogCategory a, BlogCategory b) 
  {
   return a.name.compareTo(b.name);
  }

  Widget _buildCategoryNode({
    required BlogCategory c,
    required Map<String?, List<BlogCategory>> by_parent,
    required int depth,
  }) {
    final c_children = by_parent[c.id] ?? const <BlogCategory>[];
    final checked = (selected_slug == c.slug);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children : [
        /*UI : [ ] 카테고리 이름  */
        CheckboxListTile(
          dense: true,
          contentPadding: EdgeInsets.only(left: 8.0 + depth * 16.0, right: 8),
          value: checked,
          onChanged: (_) => on_select(c.slug),
          title: Text(c.name, overflow : TextOverflow.ellipsis),
          controlAffinity: ListTileControlAffinity.leading,
          ),
          /*만약 이 자식1에 자식2가 있으면 다시 재귀해라. */
          //루트부터 시작해서 자식의 자식까지 계속 이뤄짐. 
          if(c_children.isNotEmpty)
            ..._buildNodes(by_parent:by_parent, parent_id: c.id, depth: depth +1),
            /*
            A 
              A1
              A2
                A2a
            B 
            이런 구조라면,
            depth가 붙어서,  A->  A1,A2 -> A2a -> B 이런순으로 처리함.
            "DFS 재귀 랜더링"
              */
            
        
      ]
    );
  }


}