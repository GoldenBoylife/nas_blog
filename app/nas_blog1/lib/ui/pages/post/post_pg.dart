
import 'package:flutter/material.dart';
import 'package:nas_blog1/models/post_detail.dart';
import 'package:nas_blog1/services/post_service.dart';
import 'package:nas_blog1/utils/markdown/markdown.dart';




class PostPg extends StatefulWidget {
    final String post_id;
  const PostPg({super.key,
    required this.post_id
  });

  @override
  State<PostPg> createState() => _PostPgState();
}

class _PostPgState extends State<PostPg> {
    late Future<PostDetail> _future_post;



		@override
  void initState() {
    // TODO: implement initState
    super.initState();
		_future_post = PostService.fetchPost(widget.post_id);
  }

	


  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PostDetail>(
			future: _future_post,
			builder: (context, snapshot) {
				if(snapshot.connectionState == ConnectionState.waiting) {
					return const Scaffold(
						body: Center(child: CircularProgressIndicator()),
					);
				}
				if(snapshot.hasError || !snapshot.hasData) {
					return Scaffold(
						body: Center(
							child: Text('Error loading post\n${snapshot.error}'),
						)
					);
				}
			
			final post = snapshot.data!;
			final meta = post.meta;

			/*inpa style layout */
			return Scaffold(
				body: SafeArea(
					child:SingleChildScrollView(
						child: Column(
							children : [
								// 1) Post 전용 Hero 상단 큰 이미지 배경 + 제목 오버레이
								PostHeroHeader
							]
						)
					)
					
					)
			)

			}
		);
  }
}