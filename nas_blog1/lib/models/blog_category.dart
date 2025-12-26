class BlogCategory{
  final String id;
  final String name;
  final String slug;
  //String : null불가, String? null가능

  BlogCategory({
    required this.id,
    required this.name,
    required this.slug
  });

  factory BlogCategory.fromJson(Map<String, dynamic> j) {
  //정적 생성 함수
  //factory : 항상 새 인스턴스 만들 필요 없고, 만들지 않거나 다른 타입을 반환할수도 있는 생성자.
    return BlogCategory(
      id: j['id'] as String,
      name: j['name'] as String,
      slug: (j['slug'] ?? j['name']) as String,
    );
  }
}
