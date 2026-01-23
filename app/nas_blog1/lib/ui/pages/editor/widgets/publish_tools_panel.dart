import 'package:flutter/material.dart';
import 'package:nas_blog1/models/post_status.dart';
import 'package:nas_blog1/ui/common_widgets/panels/panel_card.dart';
import 'package:nas_blog1/ui/pages/common/widgets/post/post_card.dart';
import 'package:nas_blog1/ui/pages/editor/widgets/category_tree_selector.dart';
import 'package:nas_blog1/models/blog_category.dart';


/// PublishToolsPanel
/// purpose
/// input
/// how it works
/// 
class PublishToolsPanel extends StatelessWidget {
  final String? thumbnail_full_url;
  final VoidCallback on_pick_thumbnail;
  final VoidCallback on_remove_thumbnail;
  //인자가 없는 콜백, 리턴 없음

  final PostStatus status;
  final void Function(PostStatus v) on_change_status; // Post status 값이 변경되었다는 걸 부모위젯에게 콜백으로 알림.
  //인자 1개 를 받는 콜백, 리턴 없음

  final List<BlogCategory> categories_flat;
  final String? selected_category_slug;
  final void Function(String slug) on_select_category; // 선택된 카테고리 값이 변경되었다는 걸 부모위젯에게 콜백으로 알림.
  final VoidCallback on_add_category;

  const PublishToolsPanel({
    super.key,
    required this.thumbnail_full_url,
    required this.on_pick_thumbnail,
    required this.on_remove_thumbnail,
    required this.status,
    required this.on_change_status,
    required this.categories_flat,
    required this.selected_category_slug,
    
    required this.on_select_category,
    required this.on_add_category,
    
    });
         



  @override
  Widget build(BuildContext context) {
    return PanelCard(
      title:'PUblish Tools',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text('Thumbnail', style: TextStyle(fontWeight: FontWeight.w700))
              ),
            
            IconButton(
              tooltip: 'Pick thumbnail',
              onPressed: on_pick_thumbnail,
              icon: const Icon(Icons.photo_camera_outlined),

            )

            ],
          ),
          Container(
            height: 120,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
              color: Colors.grey.shade50
            ),
            child: thumbnail_full_url == null 
                    ? Center(
                      child: Text(
                        '+ Thumbnail',
                        style: TextStyle(color: Colors.grey.shade600),
                      )
                    )
                    : Image.network(thumbnail_full_url!, fit: BoxFit.cover)
          ),
          if(thumbnail_full_url != null) ... [
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: on_remove_thumbnail,
                child: const Text('Remove'),
              )
            )
          ],
          const SizedBox(height: 14),
          const Text('Status', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6 ),
          /*Post Status 설정 위한 드롭다운박스 */
          DropdownButtonFormField(
            value : status,
            items: PostStatus.values
              .map((s) => DropdownMenuItem<PostStatus>(
                value: s,
                child: Text(s.label),
              )).toList(),
              onChanged: (v){
                if(v == null) return;
                on_change_status(v);
              },
              decoration: const InputDecoration( border: OutlineInputBorder())
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Expanded(
                child: Text('Categories', style: TextStyle(fontWeight: FontWeight.w700))
              ),
              IconButton(
                tooltip: 'Add category',
                onPressed: on_add_category,
                icon: const Icon(Icons.add),
              )
            ],
          ),
          const SizedBox(height:6),
          CategoryTreeSelector(
            categories_flat: categories_flat,
            selected_slug: selected_category_slug,
            on_select: on_select_category,
          )


        ]
      )
    );
  }
}