

import 'package:flutter/material.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:nas_blog1/models/blog_category.dart';
import 'package:nas_blog1/ui/pages/common/widgets/sidebar/section/sidebar_category.dart';
import 'package:nas_blog1/ui/pages/common/widgets/sidebar/section/sidebar_header.dart';

/// sidebar 
/// 각 섹션별로 나누어서 코딩할것임. 
/// 
class Sidebar extends StatelessWidget {
  final List<BlogCategory> categories; // tree roots
  final String?  selected_slug;
  final void Function(String? slug) on_navigate;

  final bool show_all_tile;
  final VoidCallback? on_home;
  //명시적 콜백 
  final VoidCallback?  on_refresh;

  const Sidebar({
    super.key,
    required this.categories,
    required this.selected_slug,
    required this.on_navigate,
    this.show_all_tile = false,
    this.on_home,
    this.on_refresh,
    });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        //노치, 상단바, 하단바 같은 시스템 UI영역을 피해서내용이 배치되도록 해줌. 
        child: Column(
          children: [
            SidebarHeader(
              on_home: on_home ?? () => on_navigate(null),
              on_refresh : on_refresh,
            ),
            
            Expanded(
              //여기부터
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  SidebarCategory(
                    categories: categories,
                    selected_slug: selected_slug,
                    on_navigate : on_navigate,
                    //카테고리 클릭 시 이동 콜백 전달
                    show_all_tile : show_all_tile,
                  ),
                  const SizedBox(height:10),
                  // const SidebarFooter(),
                  const SizedBox(height:12)
                ],
              )
            )
          ]
      )
        )

      
    );
  }
}