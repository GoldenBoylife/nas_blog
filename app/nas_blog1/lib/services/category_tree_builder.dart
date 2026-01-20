/*
func 
  struct 변환 
 DB/API에서 내려온 평면 카테고리 목록을 트리 구조로 재조립 하는 전용 빌더

 아래와 같은 구조에서 sub category를 유지하기 위해서 씀. 
[
  { "id": "1", "name": "Programming", "parent_id": null },
  { "id": "2", "name": "SLAM", "parent_id": "1" },
  { "id": "3", "name": "HW", "parent_id": "1" }
]
 */

import '../models/blog_category.dart';

class CategoryTreeBuilder {
  const CategoryTreeBuilder._();

  static List<BlogCategory> build(
    List<BlogCategory> flat,
  ){
    final Map<String , BlogCategory> map = {};
    final List<BlogCategory> roots = [];


    /*clone & init_children */
    for (final c in flat) {
      map[c.id] = c.copyWith(children: []);
    }

    /*attach */
    for (final c in map.values) {
      if(c.parent_id == null) {
        roots.add(c);

      } else {
        map[c.parent_id!]?.children.add(c);
      }
    }
    return roots;
  }
}