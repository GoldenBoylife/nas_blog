
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
import 'package:nas_blog1/ui/pages/common/theme/text_util.dart';

import 'package:nas_blog1/ui/pages/common/widgets/pageWidget/common_scaffold.dart';
import 'package:nas_blog1/ui/pages/common/widgets/post/post_card_grid.dart';
import 'package:nas_blog1/ui/pages/common/widgets/post/post_grid.dart';
import 'package:nas_blog1/ui/pages/common/widgets/sidebar/category_sidebar.dart';

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

  /* data */
  List<BlogCategory> _category_tree = [];
  List<BlogCategory> _categories= [];
  String? _selected_slug; //null이면 All


  late Future<List<PostMeta>> _future_posts;

  bool _cats_loading = true;
  String? _cats_error;
  

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _future_posts = PostService.fetchPosts();
    _fetchCategories();
  }


  @override
  Widget build(BuildContext context) {

    
    final screen_model = _calcScreenModel(context);
    final padding = _calcHorizontalPadding(screen_model, MediaQuery.of(context).size.width);

    /*sidebar 위젯 만들기 (카테고리 로딩/에러 처리 포함) */
    Widget? side_bar = _buildSidebar(context);
    
    final h  = MediaQuery.of(context).size.height;
    final hero_h = (h*0.22) .clamp(120.0, 220.0); //취향값
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
            child: PageHero(screen_model: screen_model),
            ),
          const SizedBox(height: 18),
          _BuildMainContentExpanded(),
          //PostGrid와 PostCard가 여기서 뜬다. 
          const SizedBox(height: 24)
        
      ]
    );
  }

  /*
  funcs
  - _fetchCategories
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


    /*카테고리 목록을 NAS에서 다시 받아와서 화면 상태를 업뎃함 */
  Future<void>  _fetchCategories() async{
    
    // setState(() {
    //   _cats_loading = true;
    //   _cats_error = null;
    // });
    try {
      final flat = await CategoryService.fetchCategories();
      final tree  =  CategoryTreeBuilder.build(flat);
      //서버에서 받아옴.
      if(!mounted) return;
      //await하는 동안 화면이 사라질수 있으니, 안전장치

      /*받아온 상태로 업데이트 진행 */
      setState(() {
        _category_tree = tree;
        // _categories = cats;
        _cats_loading = false;

        /*선택된 slug가 더이상 없으면 All로 */
        //선택된 slug가 아직 유효한지 확인
        // 예를 들어서 eidtor모드에서 robotics 카테고리를 삭제하면, 더이상 목록에 없게 됨.
        if(_selected_slug  != null && 
            _categories.indexWhere((c) => c.slug == _selected_slug) <0) {
            _selected_slug = null;
          }
      });
    } catch (e) {
      if(!mounted) return;
      setState(() {
        _cats_loading = false;
        _cats_error = '$e';
      });

    }
  }


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

  /*UI helpers 
  // widget을 직접 그리지는 않지만 UI를 만들기 쉽게 도와주는 보조 코드
  // history : 
    1. buildPosts로 스크롤을 homPg, commonScaffold 둘다 하고 있었음. 이러면 팅김 그래서
    
    2. buildPostsGrid 
    commonScaffold의  스크롤 기능을 각 페이지들(homePg)에서 할수 잇도록 바꾸겟음.그래서 buildPostsGrid로 바꿈
    이렇게 하면 homePg에서만 스크롤 사용하므로 팅김을 방지할 수 있음
  */
  // Widget _buildPostsGrid(List<PostMeta> posts) {
  //   // UI에서 category 필터링(서버 필터가 아직 없을 때) 
  //   final filtered = (_selected_slug == null) 
  //     ? posts
  //     : posts.where((p) => p.category == _selected_slug).toList();
  //   if(filtered.isEmpty) {
  //     return const Center(child: Text('No posts'));
  //   }

  //   final w = MediaQuery.of(context).size.width;
  //   final cross = _calcCrossAxisCount(w);
  //   final show_chip = ( w >= 360); //기준 취향

                              
                          
  //   return GridView.builder(
      
  //     padding: const EdgeInsets.only(top: 12, bottom :80),
  //     gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
  //       crossAxisCount: cross,
  //       //화면 너비에 따라서 한줄에 보여줄 카드의 갯수 정함
  //       crossAxisSpacing: 16,
  //       mainAxisSpacing: 16,
  //       mainAxisExtent: 270, //카드 높이 고정(썸네일 150 + 아래영역)
        
  //       ),

  //     itemCount: filtered.length,
  //     // separatorBuilder: (_,__) => const Divider(height :1), 
  //     itemBuilder: (context, index) {
  //       final p = filtered[index];
  //       return PostCard(
  //         post: p,
  //         //기존 ListTile은 빠르게 리스트 만들기 위한 거고, 
  //         //이 InkWell은 터치 효과, 클릭 처리를 위한 것이다. 
  //         //이제 inpa처럼  썸네일 크기, 카드를 직접 제작하기위해서 이걸로 바꿈. 
  //         on_tap: () {
  //           Navigator.push(
  //             context,
  //             MaterialPageRoute(
  //               builder: (_) => PostPg(post_id : p.id)
  //               )
  //           );
  //         },
  //       );
  //     }
      
      
  //   );
  // }

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

  double _calcHorizontalPadding(ScreenModel sm, double width) {
    /*대충 inpa 느낌, desktop은 좌우 여백 조금 */
    if(sm.web) return 16;
    if(sm.tablet) return 12;
    return 10;
  }
  Widget? _buildSidebar(BuildContext context) {
    if(_cats_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if(_cats_error != null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Category load error:\n$_cats_error'),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _fetchCategories,
              child: const Text('Retry')
              )
            ]
          
        )
      );
    }
    return CategorySidebar(
      categories: _category_tree,
      selected_slug : _selected_slug,
      show_all_tile: false,
      on_navigate: (slug) {
        if(slug == null) 
          Beamer.of(context).beamToNamed('/');
        else 
          Beamer.of(context).beamToNamed('/category/$slug');
      },
      on_refresh_requested: _fetchCategories,
    );
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

                  if (!context.mounted) return;

                  if (ok) AdminGate.login();
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
                      _fetchCategories();
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










}// end






