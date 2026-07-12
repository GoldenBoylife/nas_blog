import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nas_blog1/models/blog_category.dart';
import 'package:nas_blog1/services/category_service.dart';
import 'package:nas_blog1/services/category_tree_builder.dart';
import 'package:nas_blog1/ui/pages/common/widgets/sidebar/sidebar.dart';
import 'package:nas_blog1/models/post_meta.dart';
import 'package:nas_blog1/services/post_service.dart';

class SidebarHost extends StatefulWidget {
  final String? selected_slug;
  final bool show_all_tile;

  final void Function(String? slug) on_navigate;

  const SidebarHost({
    super.key,
    required this.selected_slug,
    required this.on_navigate,
    this.show_all_tile = false,
    });

  @override
  State<SidebarHost> createState() => _SidebarHostState();
}

class _SidebarHostState extends State<SidebarHost> {
  List<BlogCategory> _tree = [];
  bool _loading = true;
  String? _error;

  Map<String, int> _post_count_by_slug = {};
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fetch();

  }
  @override
  Widget build(BuildContext context) {
    if(_loading) {
      return const Center(child: CircularProgressIndicator());
    }

  if(_error != null) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Category load error:\n$_error'),
          const SizedBox(height:12),
          ElevatedButton(
            onPressed: _fetch, 
            child: const Text('Retry'),
            )
        ]
      )
    );
  }

  return Sidebar(
    categories: _tree,
    selected_slug: widget.selected_slug,
    show_all_tile: widget.show_all_tile,
    on_navigate: widget.on_navigate,
    on_refresh: _fetch,
    post_count_by_slug: _post_count_by_slug,
  );
  
    
  }

/*
funcs
  - fetch()
 */

Future<void> _fetch() async {
  setState(() {
    _loading = true;
    _error = null;
  });

  try {
    final results = await Future.wait([
      CategoryService.fetchCategories(),
      PostService.fetchPosts(),
    ]);

    final flat = results[0] as List<BlogCategory>;
    final posts = results[1] as List<PostMeta>;

    final tree = CategoryTreeBuilder.build(flat);
      //서버에서 받아온다. 

    final count_map = _buildPostCountMap(tree, posts);

    if (!mounted) return;
    //await 동안 화면이 사라질 수 있으니, 안전장치
    /*받아온 상태로 업데이트 진행 */

    setState(() {
      _tree = tree;
      _post_count_by_slug = count_map;
      _loading = false;
    });
  } catch (e) {
    if (!mounted) return;
    setState(() {
      _loading = false;
      _error = '$e';
    });
  }
}


  Map<String, int> _buildPostCountMap(
    List<BlogCategory> tree,
    List<PostMeta> posts,
  ) {
    final direct_count_by_slug = <String, int>{};

    for (final post in posts) {
      final slug = post.category;
      if (slug == null || slug.trim().isEmpty) continue;

      direct_count_by_slug[slug] = (direct_count_by_slug[slug] ?? 0) + 1;
    }

    final total_count_by_slug = <String, int>{};

    int calcTotalCount(BlogCategory category) {
      final self_count = direct_count_by_slug[category.slug] ?? 0;

      int children_count = 0;
      for (final child in category.children) {
        children_count += calcTotalCount(child);
      }

      final total = self_count + children_count;
      total_count_by_slug[category.slug] = total;
      return total;
    }

    for (final root in tree) {
      calcTotalCount(root);
    }

    return total_count_by_slug;
  }


}//end