import 'post_meta.dart';
class PostDetail{
  final PostMeta meta;
  final String body_markdown;

  PostDetail({
    required this.meta,
    required this.body_markdown,
  });

  /*factory constructure :  */
  //json -> return this model class 
  factory PostDetail.fromJson(Map<String, dynamic> json) 
  {
    return PostDetail(
      meta: PostMeta.fromJson(json['meta']),
      body_markdown: json['body_markdown'] as String,
    );
  }
}
