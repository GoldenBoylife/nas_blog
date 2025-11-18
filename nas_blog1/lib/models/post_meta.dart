class PostMeta {
  final String id;
  final String title;
  final String created_at;

  PostMeta({
    required this.id,
    required this.title,
    required this.created_at
  });


/*jSON -> PostMeta */
factory PostMeta.fromJson(Map<String ,dynamic> json) 
{
  return PostMeta(
    id: json['id'],
    title: json['title'],
    created_at: json['created_at'],
  );
}
}