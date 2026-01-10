import 'package:flutter/material.dart';
import 'package:nas_blog1/config/config.dart';
import 'package:nas_blog1/models/post_meta.dart';
import 'package:nas_blog1/ui/pages/common/theme/text_util.dart';

class PostCard extends StatelessWidget {
  final PostMeta post;
  final VoidCallback on_tap;


  const PostCard({
    super.key,
    required this.post,
    required this.on_tap
    });

    String? _thumbnailUrl() {
      final t = post.thumbnail;
      if(t == null || t.isEmpty) return null;
        return t.startsWith('http') ? t : '$NAS_BASE_URL$t';
        //t가 http로 시작하면 그대로 반환 없으면 NAS_BASE_URL붙여서 반환
    }


  /*functions*/
  Widget _thumbFallback() 
  {
    return Container(
      color: const Color(0xFFF2F2F7),
      child: const Center(
        child: Icon(Icons.image_outlined, size: 34, color: Colors.black26),
      )
    );
  }

  Widget _tagChip(BuildContext context, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.06),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextUtil.get12(context, Colors.grey.shade800),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    final thumb_url = _thumbnailUrl();


    return InkWell(
      onTap: on_tap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.black.withOpacity(0.06)),
          boxShadow: [
            BoxShadow(
              blurRadius: 12, 
              offset: const Offset(0,6),
              color: Colors.black.withOpacity(0.06),
            )
          ]
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            /*상단 썸네일 영역(고정높이) */
            SizedBox(
              height: 150,
              child: Stack(
                fit:StackFit.expand,
                children: [
                  if(thumb_url != null)
                    Image.network(
                      thumb_url,
                      fit: BoxFit.cover,
                      errorBuilder: (_,__,___) => _thumbFallback(),
                    )
                    else 
                      _thumbFallback(),

                      /*위에 살짝 어둡게 (텍스트 가독성) */
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.25),
                              Colors.transparent
                            ]
                          )
                        ),
                      ),
                      /*좌 상단 카테고리 칩*/
                      if(post.category != null && post.category!.isNotEmpty)
                        Positioned(
                          top: 10,
                          left: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal:  10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.45),
                              borderRadius: BorderRadius.circular(999),

                            ),
                            child: Text(
                              post.category!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextUtil.get12(context,Colors.white),
                            )
                          )
                        )
                
                      ]
                    )
                  ),
                  /*하단 정보 영역 */
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14,12,14,12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /*제목 */
                        Text(
                          post.title,
                          maxLines:2,
                          overflow: TextOverflow.ellipsis,
                          style: TextUtil.get16(context,Colors.black, font_weight: FontWeight.w800),
                        ),
                        const SizedBox(height: 10),

                        /*작성자/날짜 줄 (지금 데이터에서 author 없으니 일단 "goldenboy" 고정) */
                        Row(
                          children: [
                            const CircleAvatar(
                              radius : 12 ,
                              child: Icon(Icons.person, size: 14),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'GoldenBoy',
                              style: TextUtil.get12(context, Colors.grey.shade700),
                            ),
                            const SizedBox(width: 8),
                            Text('·', style : TextStyle(color:Colors.grey.shade500)),
                            const SizedBox(width:8),
                            Expanded(
                              child: Text(
                                post.created_at,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextUtil.get12(context, Colors.grey.shade700),
                              )
                            )
                          ]
                        ),
                        const SizedBox(height:12),

                        /*태그/ 댓글 공유 (임시 UI)*/
                        //나중에 넣읍시다. 나중에! 댓글 기능 넣고서.
                        // Row(
                        //   children: [
                        //     _tagChip(context, '개발'),
                        //     const SizedBox(width: 6),
                        //     _tagChip(context, '키보드'),
                        //     const Spacer(),
                        //   ]
                        // )
                      ]
                      
                    )
                  )
          ]  
    )
    
      )
    );
    
  }
}