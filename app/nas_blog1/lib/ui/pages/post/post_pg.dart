
import 'dart:math';

import 'package:nas_blog1/config/route_page.dart';
import 'package:nas_blog1/ui/common_widgets/full_bleed.dart';


import 'package:nas_blog1/ui/common_widgets/sticky_button/sticky_toc.dart';
import 'package:nas_blog1/ui/pages/common/widgets/post/post_card_grid.dart';
import 'package:nas_blog1/models/post_meta.dart';

import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:nas_blog1/config/config.dart';
import 'package:nas_blog1/models/blog_category.dart';
import 'package:nas_blog1/models/post_detail.dart';
import 'package:nas_blog1/models/screen_model.dart';
import 'package:nas_blog1/services/category_service.dart';
import 'package:nas_blog1/services/category_tree_builder.dart';
import 'package:nas_blog1/services/post_service.dart';
import 'package:nas_blog1/ui/pages/common/dialogs/admin_login_dialog.dart';
import 'package:nas_blog1/ui/pages/common/state/admin_gate.dart';
import 'package:nas_blog1/ui/pages/common/widgets/pageWidget/common_scaffold.dart';
import 'package:nas_blog1/ui/pages/common/widgets/sidebar/category_sidebar.dart';
import 'package:nas_blog1/ui/pages/editor/editor_pg.dart';
import 'package:nas_blog1/ui/pages/post/sections/post_bottom_sections.dart';
import 'package:nas_blog1/ui/pages/post/widgets/post_hero_header.dart';
import 'package:nas_blog1/ui/pages/post/widgets/post_meta_bar.dart';
import 'package:nas_blog1/ui/pages/post/widgets/toc_overlay_card.dart';
import 'package:nas_blog1/utils/markdown/markdown.dart';

import 'package:nas_blog1/ui/pages/post/widgets/post_meta_bar.dart';
import 'widgets/toc_overlay_card.dart';




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

    /*sidebar용 카테고리 */
    List<BlogCategory> _category_tree = [];
    bool _cats_loading = true;
    String? _cats_error;

    /*TOC overlay */
    bool _toc_open = false;


		@override
  void initState() {
    // TODO: implement initState
    super.initState();
		_future_post = PostService.fetchPost(widget.post_id);
    _fetchCategories();
  }

	


  @override
  Widget build(BuildContext context) {
    final screen_model = _calcScreenModel(context);
    final width = MediaQuery.of(context).size.width;
    final padding = _calcHorizontalPadding(screen_model, width);
    final side_bar = _buildSidebar(context);

    return FutureBuilder<PostDetail>(
			future: _future_post,
			builder: (context, snapshot) {
				if(snapshot.connectionState == ConnectionState.waiting) {
          /*loading중 대처 */
					return CommonScaffold(
						use_page_scroll: true,
            content_max_width: null, //글 본문 폭

            current_index: 0,
            screen_model: screen_model,
            horizontal_padding: padding,
            side_bar : side_bar,
            black: false,
            top_bar_actions: _topActions(widget.post_id),

            children: const [
              SizedBox(height: 240),
              Center(child: CircularProgressIndicator()),

            ]

					);
				}
        /*error시 대처 */
				if(snapshot.hasError || !snapshot.hasData) {
					return CommonScaffold(
						use_page_scroll: true,
            content_max_width:  920,
            current_index: 0,
            screen_model: screen_model,
            horizontal_padding : padding,
            side_bar : side_bar,
            black: false,
            top_bar_actions: _topActions(widget.post_id),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Error loading post\n${snapshot.error}'),
              )
            ]
						
					);
				}
			
			final post = snapshot.data!;
			final meta = post.meta;

			/*inpa style layout */
			return CommonScaffold(
        use_page_scroll: true,
        content_max_width: 920,
        current_index: 0,
        screen_model: screen_model,
        horizontal_padding: padding,
        side_bar : side_bar,
        black: false,
        top_bar_actions: _topActions(widget.post_id),
        content_overlay: screen_model.web 
        //web일때만 stickyToc 넣기. 
                          ? StickyToc(
                              markdown: post.body_markdown,
                              left: 16, //content 영역 기준 왼쪽 여백
                              top: 92, // topbar(64) + 여유 (약간)
                          )
                          : null,
        children: [
          FullBleed(
            child: PostHeroHeader(
              title: meta.title, 
              categoryName: meta.category ?? 'Category')),
          const SizedBox(height: 18),
          /*Stack으로 "본문" + TOC 오버레이 구성 */
          PostMetaBar(author: 'GB',
           created_at: meta.created_at,
            tags: meta.tags),
          const SizedBox(height: 18),
          BlogMarkdownBody(data: post.body_markdown),
          const SizedBox(height:28),
                
          PostBottomSections(
            current_post_id: widget.post_id, 
            current_category_slug: meta.category
            ),
            const SizedBox(height: 60),
          /*우상단 floating 버튼 + TOC 버튼 */
          // Positioned(
          //   right: 16, 
          //   top: 16,
          //   child: Column(
          //     crossAxisAlignment: CrossAxisAlignment.end,
          //     children: [
          //       FloatingActionButton.small(
          //         heroTag: 'toc_btn_${widget.post_id}',
          //         onPressed: () => setState(() => _toc_open = !_toc_open),
          //         child: const Icon(Icons.list_alt),
          //       ),
          //       const SizedBox(height: 10),
          //       if(_toc_open)
          //         SizedBox(
          //           width: 320,
          //           child: TocOverlayCard(
          //             markdown :post.body_markdown,
          //             on_close: () => setState(() => _toc_open = false),
          //           ))
          //     ]
            
          //         ),
          // )
        ]
              );
      },
    );
  }  
			

			
		
  



  /*
  funcs 
  - _fetchCategories
  - _refreshPosts
  - _calcScreenModel
  - _TocOverlayCard
  */


  Future<void> _fetchCategories() async{
    try {
      final flat = await CategoryService.fetchCategories();
      final tree = CategoryTreeBuilder.build(flat);
      if(!mounted) return;
      setState(() {
        _category_tree = tree;
        _cats_loading = false;
        _cats_error = null;
      });  
    } catch (e) {
      if(!mounted) return;
      setState(() {
        _cats_loading = false;
        _cats_error = '$e';
      });
    }
  }


  void _refreshThisPosts() {
  setState(() {
    _future_post = PostService.fetchPost(widget.post_id);
  });
  }


  ScreenModel _calcScreenModel(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final mobile = (w < 768);
    final tablet = (w >= 768 && w < 1100);
    final web = (w>= 1000);
    return ScreenModel(web,tablet,mobile);
  }


  double _calcHorizontalPadding(ScreenModel sm, double width) {
    if( sm.web)  return 16;
    if( sm.tablet) return 12;
    return 10;

  }

  Widget? _buildSidebar(BuildContext context) {
    if(_cats_loading) {
      return const  Center(child: CircularProgressIndicator());
    }
    if(_cats_error !=null) {
      return Padding( 
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Category load error:\n$_cats_error'),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _fetchCategories,
              child: const Text('Retry'),

            )
          ]
        )
      );
    }
    return CategorySidebar(
      categories: _category_tree,
      selected_slug : null, // PostPg에서는 선택 상태를 굳이 유지 안해도 됨. 
      show_all_tile:  false,
      on_navigate: (slug) {
        if(slug == null) 
          Beamer.of(context).beamToNamed(RoutePage.home);
          //home_pg로
        else 
          Beamer.of(context).beamToNamed('/category/$slug');
      
      },
      on_refresh_requested: _fetchCategories


    );
  }


List<Widget> _topActions(String current_post_id) {
  return [
    ValueListenableBuilder<bool> (
      valueListenable: AdminGate.is_admin,
      builder: (context, is_admin, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: is_admin ? 'Logout' : 'Login',
              icon: Icon(is_admin ? Icons.lock_open : Icons.lock_outline),
              onPressed: () async {
                if(is_admin) {
                  AdminGate.logout();
                  return;
                }
                final ok = await AdminLoginDialog.open(
                  context,
                  password: ADMIN_PASS
                );
                if(!context.mounted) return;
                if(ok) AdminGate.login();
              },
            ),

            /*login 되었을때만 현재 글 편집 */
             if(is_admin) 
             ...[
              const SizedBox(width: 6),
              IconButton(
                tooltip: 'Edit Post',
                icon: const Icon(Icons.edit_square),
                onPressed:() async{
                  final changed = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditorPg(post_id: current_post_id),
                    ));
                    if(!context.mounted) return;
                    if(changed == true) {
                      _fetchCategories();
                      _refreshThisPosts();
                    }
                }
              ),
              const SizedBox(width: 6),
              IconButton(
                tooltip : 'Remove Post',
                icon : const Icon(Icons.delete_outline),
                onPressed: () async {
                  final ok = await showDialog<bool> (
                    context : context,
                    builder: (_) => AlertDialog(
                      title: const Text('Delete this post?'),
                      content : const Text('This action cannot be undone.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context,false),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context,true),
                          // onPressed: () => Beamer.of(context).beamToNamed(RoutePage.home),
                          child: const Text('Delete'),
                        )
                      ]
                    )
                  );
                  if( ok != true) return;
                  await PostService.deletePost(widget.post_id);
                  if(!context.mounted) return;

                  Navigator.pop(context,true); //홈 카테고리로 복귀
                },
              )
             ]
          ]
        );
      }
    ),
    const SizedBox(width:4),
  ];
  }



} //end