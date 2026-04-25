
import 'dart:async';
import 'dart:math';
import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:nas_blog1/config/config.dart';
import 'package:nas_blog1/models/blog_category.dart';
import 'package:nas_blog1/models/post_meta.dart';
import 'package:nas_blog1/models/screen_model.dart';

import 'package:nas_blog1/services/category_service.dart';
import 'package:nas_blog1/services/category_tree_builder.dart';
import 'package:nas_blog1/services/post_service.dart';
import 'package:nas_blog1/ui/common_widgets/full_bleed.dart';
import 'package:nas_blog1/ui/pages/common/theme/calc_horizontal_padding.dart';
import 'package:nas_blog1/ui/pages/common/theme/text_util.dart';

import 'package:nas_blog1/ui/pages/common/widgets/pageWidget/common_scaffold.dart';
import 'package:nas_blog1/ui/pages/common/widgets/post/post_card_grid.dart';
import 'package:nas_blog1/ui/pages/common/widgets/post/post_grid.dart';
import 'package:nas_blog1/ui/pages/common/widgets/sidebar/category_sidebar.dart';
import 'package:nas_blog1/ui/pages/common/widgets/sidebar/sidebar.dart';
import 'package:nas_blog1/ui/pages/common/widgets/sidebar/sidebar_host.dart';

import 'package:nas_blog1/ui/pages/editor/editor_pg.dart';
import 'package:nas_blog1/ui/pages/common/widgets/page_hero/page_hero.dart';
import 'package:nas_blog1/ui/pages/post/post_pg.dart';
import 'package:nas_blog1/ui/pages/common/widgets/post/post_card.dart';

import 'package:nas_blog1/ui/pages/common/state/admin_gate.dart';
import 'package:nas_blog1/ui/pages/common/dialogs/admin_login_dialog.dart';




class HomePg extends StatefulWidget {
  const HomePg({super.key});

  @override
  State<HomePg> createState() => _HomePgState();
}

class _HomePgState extends State<HomePg> {
  final GlobalKey _latest_section_key = GlobalKey();

  /* data */
  List<BlogCategory> _category_tree = [];
  List<BlogCategory> _categories= [];
  String? _selected_slug; //null이면 All
  bool _cats_loading = true;
  String? _cats_error;

  late Future<List<PostMeta>> _future_posts;

  

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _future_posts = PostService.fetchPosts();
    _fetchCategories(); // ✅ 이거 반드시
  }


  @override
  Widget build(BuildContext context) {

    
    final screen_model = _calcScreenModel(context);
    final padding = calcHorizontalPadding(screen_model, MediaQuery.of(context).size.width);

    /*sidebar 위젯 만들기 (카테고리 로딩/에러 처리 포함) */
    Widget? side_bar = SidebarHost(
                            selected_slug:  null,
                            show_all_tile : false,
                            on_navigate: (slug) {
                              if(slug == null) Beamer.of(context).beamToNamed('/');
                              else Beamer.of(context).beamToNamed('/category/${Uri.encodeComponent(slug)}');
                            },
          );


    return CommonScaffold(
      use_page_scroll: false,
      content_max_width: 1100, //홈은 1100정도 추천
      current_index: 0,
      screen_model: screen_model,
      horizontal_padding : padding,
      side_bar : side_bar,
      black: false, //일단 밝게 (원하면 true)
      top_bar_actions: _topActions(),
      children : [
    
          FullBleed(
            child: PageHero(
              screen_model: screen_model,
              title: 'Dr.GoldenBoy Lab',
              sub_title: '이 로봇 개발 덕후가 한번 세상을 놀래켜 보게쓰 ( •̀ᴗ•́ )و ̑̑ \n you can be',
              words: const ['Programmer', 'Engineer', 'Designer', ],
              // 나중에 이모티콘으로? (ง •̀_•́)ง, ( •̀ ω •́ )✧ ,  (๑•̀ㅂ•́)و✧ , ( •̀ᴗ•́ )و ̑̑
              on_scroll_down: _scrollToLatestSection,
            ),
            ),
          const SizedBox(height: 28),
          KeyedSubtree(
            key: _latest_section_key,
            child: _BuildMainContentExpanded(),
                  //PostGrid와 PostCard가 여기서 뜬다. 

          ),
          const SizedBox(height: 24)
        
      ]
    );
  }

  /*
  funcs
  - _refreshPosts
  - _onSelectCategory
  - _calcCrossAxisCount
  - _buildThumbnail
  - _buildPostsGrid
  - _BuildMainContentExpanded
  - _calcScreenModel
  - _calcHorizontalPadding
  - _buildSidebar
  - _topActions
  - _maxWidthCenter

  */



  /*post목록을 다시 불러오도록 Future를 새로 만들어 UI 갱신 */
  void _refreshPosts() {
    setState(() {
      _future_posts = PostService.fetchPosts();
    });
  }

  /*사용자가 사이드바에서 카테고리를 클릭햇을때 "선택 상태"만 바뀌는 함수 */
  void _onSelectCategory(BlogCategory? cat) {
    setState(() {
      _selected_slug = cat?.slug;  //null이면 All
    });

  }

/*화면의 너비에 따라서 한줄에 몇개의 포스트 카드를 배치할지 정하는 함수 */
  int _calcCrossAxisCount(double w) {
    if(w >= 1400) return 4;
    if(w >= 1100) return 3;
    if(w >= 768) return 2;
    return 1;
  }

  Widget _buildThumbnail(PostMeta p) {

          

    if(p.thumbnail == null || p.thumbnail!.isEmpty) 
      // 1) 썸네일 없으면 기본 아이콘
      if(p.thumbnail == null || p.thumbnail!.isEmpty)
      {
        return Container(
          width: 56, 
          height: 56,
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withOpacity(0.2)),
            ),
            child: const Center(child: Icon(Icons.article)),
            );
      }
      
        /*상대경로 -> 절대 경로로 */
      final thumb = p.thumbnail!; // non-null로 강제 보장함.
      final url = thumb.startsWith('http') 
            ? thumb
            : '$NAS_BASE_URL$thumb';

      final thumb_widget = Image.network(url, fit: BoxFit.cover,errorBuilder: (_, __, ___) {
        return const DecoratedBox(
          decoration: BoxDecoration(color: Colors.grey),
          child: Center(
            child: Icon(Icons.broken_image, color: Colors.white),
              ),
            );
          },
        );

        return Container(
          width: 56, 
          height: 56, 
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: Colors.white,  //썸네일 배경
            borderRadius:  BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withOpacity(0.2)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: thumb_widget
          )
        );
  }


  // /*slug 조건에 맞는 액자들만 골라서 PostGrid 벽 가장자리에 걸어둔다.  */
  Widget _BuildMainContentExpanded() {
    /*CommondScaffold는 body를 SingleChildScrollView로 감싸고 있어서,
    여기서는 스크롤 가능한 리스트를 만들어 놓으면 Nested scroll이 꼬일 수 있음. 

    그래서 HomPg본문은 ListView를 직접 쓰지 말고, 
    1) 지금은 '고정 높이'로 감싸거나, 
    2) 다음 단계에서 CommonScaffold에 "scroll 옵션"을 추가해 분리하는 것이 좋다. 

    지금 단계에서는 가장 단순하게:
    - 화면 높이를 받아서 Expanded로 만들지 ㅇ낳고, 
    - "PostsListSection"을 SizedBox(height: ...)로 넣어둡니다. 

    다음 단계에서 CommonScaffold의 스크롤 구조를 개선할 예정.

    
    */
    

    return FutureBuilder<List<PostMeta>> (
      //FutureBuilder : 비동기 작업의 상태에 따라서 UI를 갈아 끼워줌. 
      future: _future_posts,
      builder: (context,snap) {
        if(snap.connectionState == ConnectionState.waiting) {
          return  const Center(child: CircularProgressIndicator());
          
        }
        if(snap.hasError || !snap.hasData) {
          return Center(child: Text('Error: ${snap.error}'));
        
        }
        final posts = snap.data!;
        //홈은 "All"이면 전체, 아니면 필터된 목록
        final filtered = (_selected_slug ==null)
              ? posts 
              : posts.where((p) => p.category == _selected_slug).toList();
        return  
        // PostGrid(
        //   posts: filtered,
        //   on_tap: (p) {
        //     Navigator.push(
        //       context,
        //       MaterialPageRoute(builder: (_) => PostPg(post_id: p.id)),
        //     );
        //   }
        // );
        PostCardGrid(
          title: '최신 글 ',
          sub_title: "따끈 따끈한 포스트 구경해보세요!",
          posts: filtered,
          featured: true,
          on_tap:(p) {
            return Beamer.of(context).beamToNamed('/post/${p.id}');
          },
            );
          }

        );
        // SizedBox(height:200);
        
      }
  


  ScreenModel _calcScreenModel(BuildContext context) 
  {
    final w = MediaQuery.of(context).size.width;
    /*내가 쓰는 기준에 맞추어서 수정 가능 */
    final mobile = (w < 768);
    final tablet = (w >= 768 && w < 1100);
    final web = (w >=1000);
    return ScreenModel(web,tablet,mobile);
    //객체가 하나 생성되어 리턴된다.
  }



  List<Widget> _topActions() {
    return [
      ValueListenableBuilder<bool>(
        valueListenable: AdminGate.is_admin,
        builder: (context, isAdmin, _) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: isAdmin ? 'Logout' : 'Login',
                icon: Icon(isAdmin ? Icons.lock_open : Icons.lock_outline),
                onPressed: () async {
                  if (isAdmin) {
                    AdminGate.logout();
                    return;
                  }

                  final ok = await AdminLoginDialog.open(
                    context,
                    password: ADMIN_PASS,
                  );
                  debugPrint('ADMIN_PASS=$ADMIN_PASS');
                  debugPrint('dialog result ok=$ok');

                  if (!context.mounted) return;

                  if (ok) 
                  {
                    debugPrint('calling AdminGate.login()');
                    AdminGate.login();
                  }
                },
              ),

              if (isAdmin) ...[
                const SizedBox(width: 6),
                IconButton(
                  tooltip: 'New Post',
                  icon: const Icon(Icons.edit_square),
                  onPressed: () async {
                    final changed = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const EditorPg()),
                    );

                    if (!context.mounted) return;

                    if (changed == true) {
                      _refreshPosts();
                    }
                  },
                ),
              ],
            ],
          );
        },
      ),
      const SizedBox(width: 4),
    ];
  }
  Widget _maxWidthCenter(Widget child) {
    const maxW = 1100.0; // 취향: 960~1200 추천
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: maxW),
        child: child,
      ),
    );
  }




Future<void> _fetchCategories() async {
  setState(() {
    _cats_loading = true;
    _cats_error = null;
  });

  try {
    final flat = await CategoryService.fetchCategories();
    final tree = CategoryTreeBuilder.build(flat);

    if (!mounted) return;
    setState(() {
      _categories = flat;
      _category_tree = tree;
      _cats_loading = false;

      // 선택된 slug가 더이상 존재하지 않으면 All로
      if (_selected_slug != null &&
          _categories.indexWhere((c) => c.slug == _selected_slug) < 0) {
        _selected_slug = null;
      }
    });
  } catch (e) {
    if (!mounted) return;
    setState(() {
      _cats_loading = false;
      _cats_error = '$e';
    });
  }
}

void _scrollToLatestSection() {
  final context = _latest_section_key.currentContext;
  if (context == null) return;

  Scrollable.ensureVisible(
    context,
    duration: const Duration(milliseconds: 550),
    curve: Curves.easeOutCubic,
    alignment: 0.05,
  );
}





}// end






