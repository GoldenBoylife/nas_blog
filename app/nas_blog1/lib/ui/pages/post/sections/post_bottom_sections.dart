import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nas_blog1/models/post_meta.dart';
import 'package:nas_blog1/services/post_service.dart';
import 'package:nas_blog1/ui/pages/common/widgets/post/post_card_grid.dart';
import 'package:nas_blog1/ui/pages/post/post_pg.dart';
import 'package:nas_blog1/ui/pages/common/widgets/post/post_card_row.dart';


class PostBottomSections extends StatelessWidget {
  final String current_post_id;
  final String? current_category_slug;

  const PostBottomSections({
    super.key,
    required this.current_post_id,
    required this.current_category_slug,
    });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<PostMeta>>(
      future: PostService.fetchPosts(),
      builder: (context, snap) {
        if(snap.connectionState == ConnectionState.waiting){
          return const Padding(
            padding: EdgeInsets.symmetric(vertical:24),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if(snap.hasError || !snap.hasData) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Text('하단 글 목록을 불러오지 못했습니다.'),
          );
        }
        final all = snap.data!;
        /*같은 카테고리 (현재 글 제외) */
        final same_category_posts = (current_category_slug== null)
          ? <PostMeta>[]
          : all
              .where((p) => p.category == current_category_slug && p.id != current_post_id)
              .toList();
        /* 인기 글(임시: 최신 순/ 그냥 앞에서 N개, 나중에 서버에서 인기정렬로 교체) */
        final popular_posts = all.where((p) => p.id != current_post_id).take(12).toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children:[
            if(same_category_posts.isNotEmpty) ...[
              PostCardRow(
                title: '이 카테고리의 다른 글',
                sub_title: '같은 주제의 다른 글도 확인해보세요.',
                posts: same_category_posts.take(12).toList(),
                // featured: false,
                on_tap:(p) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => PostPg(post_id: p.id),
                    
                  )
                  );
                }
              )
            ]
          ]
        );

      }
    );
  }
}