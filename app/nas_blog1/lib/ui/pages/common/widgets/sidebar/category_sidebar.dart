import 'package:flutter/material.dart';
import 'package:nas_blog1/models/blog_category.dart';

class CategorySidebar extends StatelessWidget {
  final List<BlogCategory> categories;
  final String? selected_slug;
  final void Function(BlogCategory? cat) on_select;

  // B방식: "갱신 버튼" 정도만 넣어도 편해요 (선택)
  final VoidCallback? on_refresh_requested;

  const CategorySidebar({
    super.key,
    required this.categories,
    required this.selected_slug,
    required this.on_select,
    this.on_refresh_requested,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),

            // 프로필/로고 영역(임시)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  const CircleAvatar(radius: 18, child: Icon(Icons.person)),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Dr.GoldenBoy Lab',
                      style: TextStyle(fontWeight: FontWeight.w700),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (on_refresh_requested != null)
                    IconButton(
                      onPressed: on_refresh_requested,
                      icon: const Icon(Icons.refresh),
                      tooltip: 'Refresh categories',
                    ),
                ],
              ),
            ),

            const SizedBox(height: 12),
            const Divider(height: 1),

            // All
            _tile(
              context: context,
              title: 'All',
              selected: selected_slug == null,
              onTap: () => on_select(null),
              leading: Icons.home_outlined,
            ),

            const SizedBox(height: 8),

            Expanded(
              child: ListView.builder(
                itemCount: categories.length,
                itemBuilder: (_, i) {
                  final c = categories[i];
                  final sel = (selected_slug == c.slug);

                  return _tile(
                    context: context,
                    title: c.name,
                    selected: sel,
                    onTap: () => on_select(c),
                    leading: Icons.folder_outlined,
                    trailing: const Icon(Icons.chevron_right, size: 18),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tile({
    required BuildContext context,
    required String title,
    required bool selected,
    required VoidCallback onTap,
    required IconData leading,
    Widget? trailing,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: selected ? Colors.black.withOpacity(0.06) : Colors.transparent,
          border: Border(
            left: BorderSide(
              width: 3,
              color: selected ? Colors.black : Colors.transparent,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(leading, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }
}