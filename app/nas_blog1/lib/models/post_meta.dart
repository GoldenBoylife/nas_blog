class PostMeta {
  final String id;
  final String title;
  final String created_at;
  final List<String> tags;

  PostMeta({
    required this.id,
    required this.title,
    required this.created_at,
    required this.tags
  });


/*jSON -> PostMeta */
factory PostMeta.fromJson(Map<String ,dynamic> json) 
{
  return PostMeta(
    id: json['id'],
    title: json['title'],
    created_at: json['created_at'],
    tags: (json['tags'] as List<dynamic>).cast<String>(),
  );
}
}
