import 'package:flutter/material.dart';
import 'package:nas_blog1/models/post_meta.dart';
import 'package:nas_blog1/ui/pages/common/widgets/post/post_card.dart';
import 'package:nas_blog1/ui/pages/common/widgets/post/post_grid.dart';

/// 섹션 헤더 + (옵션) featured 레이아웃 + 고정폭 그리드
/// 
/// 핵심: 
/// - 카드 크기는 유지(최대 폭고정)
/// - featured == true
///    - 넓은 화면: 왼쪽 큰 카드 + 오른쪽 작은 카드 2개ㅏ + 아래 그리드
///    - 좁은 화면: 첫카드 큰 버전 + 아래 그리드
/// - featured == false
///    - 바로 PostGrid
/// 
/// 
/// 
/// 

class PostCardGrid extends StatelessWidget {
  final String title;
  final String? sub_title;

  final List<PostMeta> posts;
  final ValueChanged<PostMeta> on_tap;

  final bool featured; //첫 카드 강조 여부
  final double max_tile_width;
  final double tile_height;

  final double spacing; 

  final EdgeInsets padding;
  //바깥 패딩

  final int? max_items;
  final String? more_button_text;
  final VoidCallback? on_more_tap;
  final bool show_more_button;



  const PostCardGrid({
    super.key,
    required this.title,
    this.sub_title,
    required this.posts,
    required this.on_tap,
    this.featured = true,
    this.max_tile_width = 360,
    this.tile_height = 270,
    this.spacing = 16,
    this.padding = const EdgeInsets.only(top:12, bottom:40),
  
    this.max_items,
    this.more_button_text,
    this.on_more_tap,
    this.show_more_button = false,
    });


  @override
  Widget build(BuildContext context) {
    if(posts.isEmpty) return const SizedBox.shrink(); 
    //posts 리스트가 비어 있으면 아무것도 그리지 말고 그 자리에서 build 끝내기.

    final visible_posts = max_items == null
      ? posts
      : posts.take(max_items!).toList();

    return  Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
 
          const SizedBox(height: 14),
      
          LayoutBuilder(
            builder: (context,c) {
              final w = c.maxWidth;
              final can_fancy_featured = featured && visible_posts.length >= 3 && w >=920;
              // 레이아웃 최소 폭(취향값)
              if(can_fancy_featured) {
                //왼쪽 큰 카드(2배 높이) + 오른쪽 작은 카드 2개
                return Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded( 
                          //남은 공간에서 가로 공간을 얼마나 차지할지,
                          flex: 1,
                          //오른쪽, 왼쪽 공간 중에서, 왼쪽칸을 2배 width로 쓴다.
                          child: SizedBox(
                            height: tile_height *2 + spacing,
                            //세로 크기를 2배로 지정
                            child: PostCard(
                              post: visible_posts[0],
                              thumbnail_height: tile_height * 0.95,
                              on_tap: () => on_tap(visible_posts[0]),
                            )
                          )
                        ),
                        SizedBox(width: spacing),
                        Expanded(
                          flex: 1,
                          child: Column(
                            children: [
                              SizedBox(
                                height: tile_height,
                                child: PostCard(
                                  //실제 콘텐츠 
                                  post: visible_posts[1],
                                  on_tap: () => on_tap(visible_posts[1]),
                                  //클릭하면 이리로 이동
                                )
                              ),
                              SizedBox(height: spacing),
                              SizedBox(height: tile_height,
                              child: PostCard(
                                post: visible_posts[2], 
                                on_tap:() => on_tap(visible_posts[2])
                                )
                              )
                            ]
                          )
                        )
                      ]
                    ),
                    const SizedBox(height:18),
                    _buildGrid(visible_posts.skip(3).toList()),
                    //posts : 서버로부터 받아온 전체 게시글 목록
                    //skip :앞의 3개 건너뜀. 그 뒤의 것부터 나열
                    //toList() : skip()은 <postMeta>반환해서, 진짜 List로 반환
                    _buildMoreButton(context),
                  ]
                );
              }
              /*좁은 화면일때 : 첫 카드만 살짝 큰 카드로 보여주고, 나머지는 그리드  */
              // if(featured && posts.length >= 2) {
              //   return Column(
              //     children: [
              //       SizedBox(
              //         height: tile_height * 1.35,
              //         child: PostCard(
              //           post: posts[0],
              //             thumbnail_height: tile_height * 1.55,
              //             on_tap : () => on_tap(posts[0]),
              //         )
              //       ),
              //       const SizedBox(height:18),
              //       _buildGrid(posts.skip(1).toList())
              //     ]
              //   );
              // }

              return Column(
                children: [
                  _buildGrid(visible_posts),
                  _buildMoreButton(context),
                ]
              );
            }
          )  
          
        
        ]
      )
    );
  }

  /*
  funcs
  - _buildHeader : 섹션의 위쪽 제목과 부제목 만들기
  - _buildGrid :PostGrid를 위젯으로 그림 
  - _buildMoreButton : 더보기 버튼
   */
  
  /*섹션 위쪽 제목과 부제목을 만드는 함수 */
  // 최신 게시글
  //  따근따끈 머시기~
  Widget _buildHeader(BuildContext context) 
  {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children : [
        Expanded(
          child: Column(
            crossAxisAlignment : CrossAxisAlignment.start,
            children : [
              Text(
                  title, 
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            
                ),
                if(sub_title != null && sub_title!.trim().isNotEmpty) ... [
                  const SizedBox(height: 6),
                  Text(
                    sub_title!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[700])
                  )
                ],

              ]
          )
        )
      ]
 
    );
  }

  /*PostGrid를 위젯으로 그림 */
  Widget _buildGrid(List<PostMeta> list) {
    if(list.isEmpty) return const SizedBox.shrink();

    return PostGrid(
      posts:list,
      on_tap: (p) => on_tap(p),

      /*내가 업데이트한 PostGrid 파라미터 이름을 맞춤 */
      max_tile_width : max_tile_width,
      main_axis_extent: tile_height,
      cross_axis_spacing : spacing,
      main_axis_spacing : spacing,
      padding: const EdgeInsets.only(top:0, bottom:0),
    );
  }

  /*더보기 버튼 */
  Widget _buildMoreButton(BuildContext context) 
  {
    if(!show_more_button || on_more_tap == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding:const EdgeInsets.only(top :18),
      child: Center(
        child: OutlinedButton.icon(
          onPressed: on_more_tap,
          icon: const Icon(Icons.arrow_forward_rounded, size: 18),
          label: Text(more_button_text ?? '더 보기'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.black87,
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
            side : BorderSide(color: Colors.black.withOpacity(0.12)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
            )
          )
        )
      )
      
      );
  }











}