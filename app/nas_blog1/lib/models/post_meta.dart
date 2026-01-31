class PostMeta {
  final String id;
  final String title;
  final String created_at;
  final List<String> tags;
  final String? category;
  final String? thumbnail; //representive image

  PostMeta({
    required this.id,
    required this.title,
    required this.created_at,
    required this.tags,
    this.category,
    this.thumbnail,
  });


/*jSON -> PostMeta */
factory PostMeta.fromJson(Map<String ,dynamic> json) 
{
  return PostMeta(
    id: json['id'],
    title: json['title'],
    created_at: json['created_at'],
    tags: (json['tags'] as List<dynamic>).cast<String>(),
    category: json['category'] as String? ?? null ,// 없으면 null
    thumbnail: json['thumbnail']as String? ?? null
  );
}
}
