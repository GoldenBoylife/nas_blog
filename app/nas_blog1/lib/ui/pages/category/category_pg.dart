import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:nas_blog1/models/post_meta.dart';
import 'package:nas_blog1/models/screen_model.dart';
import 'package:nas_blog1/services/category_service.dart';
import 'package:nas_blog1/services/post_service.dart';
import 'package:nas_blog1/ui/common_widgets/full_bleed.dart';
import 'package:nas_blog1/ui/pages/common/theme/calc_horizontal_padding.dart';
import 'package:nas_blog1/ui/pages/common/widgets/pageWidget/common_scaffold.dart';
import 'package:nas_blog1/ui/pages/common/widgets/page_hero/page_hero.dart';
import 'package:nas_blog1/ui/pages/common/widgets/post/post_grid.dart';
import 'package:nas_blog1/ui/pages/common/widgets/sidebar/category_sidebar.dart';
import 'package:nas_blog1/ui/pages/common/widgets/sidebar/sidebar.dart';
import 'package:nas_blog1/ui/pages/common/widgets/sidebar/sidebar_host.dart';
import 'package:nas_blog1/ui/pages/post/post_pg.dart';

import '../../../models/blog_category.dart';



class CategoryPg extends StatefulWidget {
  final String slug;
  const CategoryPg({super.key, required this.slug});

  @override
  State<CategoryPg> createState() => _CategoryPgState();
}

class _CategoryPgState extends State<CategoryPg> {
  late Future<List<PostMeta>> _future_posts;
  late Future<List<BlogCategory>> _future_cats;


    List<BlogCategory> _category_tree = [];
    bool _cats_loading = true;


  @override
  void initState() {
    super.initState();
    _future_posts = PostService.fetchPosts();
    _future_cats = CategoryService.fetchCategories();
  }


  Widget _BuildMainContentExpanded() {
    return Expanded(
      child: FutureBuilder<List<PostMeta>> (
        future : _future_posts,
        builder: (context, snap) {
          if(snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if(snap.hasError || !snap.hasData) {
            return Center(child: Text('Error: ${snap.error}'));

          }
          final posts = snap.data!;
          /*All이면 전체, 아니면 필터된 목록, but 여기는 그냥 카테고리 있으므로,*/
          final filtered = posts.where((p) => p.category == widget.slug).toList();
            return PostGrid(
              posts: filtered,
              on_tap: (p) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => PostPg(post_id: p.id))
                  );
                }
              );
        },
      )
    );
  }
        
  ScreenModel _calc_screen_model(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final mobile = (w < 768);
    final tablet = (w >= 768 && w < 1100);
    final web = (w >= 1000);
    return ScreenModel(web, tablet, mobile);
  }

  @override
  Widget build(BuildContext context) {
    final screen_model = _calc_screen_model(context);
    final padding = calcHorizontalPadding(screen_model, MediaQuery.of(context).size.width);

    return FutureBuilder<List<BlogCategory>>(
      future: _future_cats,
      builder: (context, cat_snap) {
        if (!cat_snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final categories = cat_snap.data!;
        final side_bar = SidebarHost(
                                    selected_slug:  null,
                                    show_all_tile : false,
                                    on_navigate: (slug) {
                                      if(slug == null) Beamer.of(context).beamToNamed('/');
                                      else Beamer.of(context).beamToNamed('/category/${Uri.encodeComponent(slug)}');
                                    },
                  );


        return CommonScaffold(
          use_page_scroll: false,
          content_max_width: 1100, //본문 크기
          current_index: 0,
          screen_model: screen_model,
          horizontal_padding: padding,
          side_bar: side_bar,
          black: false,
          children: [
            FullBleed( child: PageHero(screen_model: screen_model)),
            const SizedBox(height: 18),

            _BuildMainContentExpanded(),

            const SizedBox(height: 24),
          ],
        );
      },
    );
  }
}

