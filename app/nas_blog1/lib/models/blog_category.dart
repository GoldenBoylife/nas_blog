/// 카테고리 데이터를 담는 모델 클래스
/// 서버로부터 받은 JSON을 Dart 객체로 바꾸고 Tree도 담기 위한 구조
class BlogCategory{
  final String id;
  final String name;
  final String slug;
  final String? parent_id;
  final String? icon_key; //260205 추가
  final List<BlogCategory> children;
  //String : null불가, String? null가능


  //생성자, 기본 3개는 꼭 잇어야 함. 
  BlogCategory({
    required this.id,
    required this.name,
    required this.slug,
    this.parent_id,
    this.icon_key, //260205추가
    this.children  = const  <BlogCategory>[], //빈 리스트
  });

  /*부분복사 :  일부만 바꿔서 새 객체 만들고 싶을 때 씀.  */
  BlogCategory copyWith({
    String? icon_key, //260205추가
    List<BlogCategory>? children,
  }) {
    return BlogCategory(
      id: id, 
      name: name, 
      slug: slug,
      parent_id : parent_id,
      icon_key : icon_key ?? this.icon_key,
      children: children ?? this.children,
      );
  }

/*JSON-> BlogCategory 객체 생성에 쓰이는 거라 factory가 적절 */
  factory BlogCategory.fromJson(Map<String, dynamic> j) {
  //정적 생성 함수
  //factory : 항상 새 인스턴스 만들 필요 없고, 만들지 않거나 다른 타입을 반환할수도 있는 생성자.
    return BlogCategory(
      id: j['id'] as String,
      name: j['name'] as String,
      slug: (j['slug'] ?? j['name']) as String,
      parent_id: j['parent_id'] as String?,  //여긴 String으로 하면 서버쪽에서 parent_id없을때 crash생김
      icon_key: j['icon_key'] as String?,  //260205 추가.
      //children은 tree 빌더가 채우는 값이라 여기서는 안건듬.
    );
  }

  /*서버로 값을 보낼때 쓰는 toJson */
  //BlogCategory객체를 Json형식으로 바꾸는 변환 동작이라 단순 메서드가 자연스러움. 
  Map<String, dynamic > toJson() {
    return {
    'id' : id,
    'name' : name,
    'slug': slug,
    'parent_id': parent_id,
    'icon_key':icon_key,
    };
  }

}//end
