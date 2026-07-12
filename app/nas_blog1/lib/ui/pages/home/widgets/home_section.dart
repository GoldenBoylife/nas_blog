import 'package:flutter/material.dart';
import 'package:nas_blog1/config/config.dart';
import 'package:nas_blog1/models/post_meta.dart';
import 'package:nas_blog1/ui/pages/common/theme/text_util.dart';
import 'package:nas_blog1/ui/pages/common/widgets/post/post_card.dart';
import 'package:nas_blog1/ui/pages/home/widgets/home_category_style.dart';

class HomeSection extends StatefulWidget {
  final List<PostMeta> posts;

  final ValueChanged<PostMeta> on_post_tap;
  final VoidCallback on_main_project_tap;
  final VoidCallback on_sub_project_tap;

  const HomeSection({
    super.key,
    required this.posts,
    required this.on_post_tap,
    required this.on_main_project_tap,
    required this.on_sub_project_tap,
  });

  @override
  State<HomeSection> createState() => _HomeSectionState();


  
}

class _HomeSectionState extends State<HomeSection> {

  @override
  Widget build(BuildContext context) {
    final visible_posts = widget.posts.take(9).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildProjectShortcutArea(context),
        const SizedBox(height: 34),
        _buildLatestPostArea(context, visible_posts),
      ],
    );
  }

  Widget _buildProjectShortcutArea(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
      _SectionTitle(
        icon: Icons.rocket_launch_outlined,
        title: '프로젝트 바로가기',
        sub_title: '핵심 프로젝트와 서브 프로젝트를 한눈에 확인하세요.',
        action_text: null,
        on_action_tap: null,
      ),
        const SizedBox(height: 14),

        LayoutBuilder(
          builder: (context, constraints) {
            final is_narrow = constraints.maxWidth < 720;

            final cards = [
              Expanded(
                child:HomeProjectCard(
                  label: 'CORE PROJECT',
                  title: 'SlamProject',
                  description: 'SLAM 기반 실내외 자율주행 및 3D 맵핑 플랫폼',
                  button_text: '바로가기',
                  icon: Icons.radar_rounded,
                  accent_color: const Color(0xFF2563EB),
                  background_image: 'assets/slam_thumnail.png',
                  on_tap: widget.on_main_project_tap,
                ),
              ),
              SizedBox(width: is_narrow ? 0 : 16, height: is_narrow ? 14 : 0),
              Expanded(
                child: HomeProjectCard(
                  label: 'SUB PROJECT',
                  title: 'PetBot',
                  description: '반려 로봇 swfwhw(?) 제작 로그',
                  button_text: '바로가기',
                  icon: Icons.smart_toy_outlined,
                  accent_color: const Color(0xFF16A34A),
                  background_image: 'assets/petbot_thumnail.png',
                  on_tap: widget.on_sub_project_tap,
                ),
              ),
            ];

            if (is_narrow) {
              return Column(
                children: cards
                    .where((w) => w is! SizedBox || w.height != 0)
                    .toList(),
              );
            }

            return Row(children: cards);
          },
        ),
      ],
    );
  }

  Widget _buildLatestPostArea(BuildContext context, List<PostMeta> visible_posts) {
    if (visible_posts.isEmpty) {
      return const SizedBox.shrink();
    }

    final featured_main = visible_posts[0];
    final side_posts = visible_posts.skip(1).take(2).toList();
    final grid_posts = visible_posts.skip(3).take(6).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(
          icon: Icons.history_edu_rounded,
          title: '최신 게시글',
          sub_title: '가장 최근에 작성한 개발 기록을 모았습니다.',
          action_text: null,
          on_action_tap: null,
        ),
        const SizedBox(height: 14),

        LayoutBuilder(
          builder: (context, constraints) {
            final is_narrow = constraints.maxWidth < 860;

            if (is_narrow) {
              return Column(
                children: [
                  SizedBox(
                    height: 320,
                    child: PostCard(
                      post: featured_main,
                      thumbnail_height: 190,
                      on_tap: () => widget.on_post_tap(featured_main),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _buildCompactGrid(
                    context,
                    [
                      ...side_posts,
                      ...grid_posts,
                    ],
                    card_height: 260,
                  ),
                ],
              );
            }

            return Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 11,
                      child: SizedBox(
                        height: 360,
                        child: PostCard(
                          post: featured_main,
                          thumbnail_height: 210,
                          on_tap: () => widget.on_post_tap(featured_main),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 9,
                      child: Column(
                        children: side_posts.map((post) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: SizedBox(
                              height: 172,
                              child: HomeSidePostCard(
                                post: post,
                                on_tap: () => widget.on_post_tap(post),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                _buildCompactGrid(
                  context,
                  grid_posts,
                  card_height: 260,
                ),
              ],
            );
          },
        ),

        
      ],
    );
  }

  Widget _buildCompactGrid(
    BuildContext context,
    List<PostMeta> list, {
    required double card_height,
  }) {
    if (list.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;

        int cross_axis_count;
        if (w >= 900) {
          cross_axis_count = 3;
        } else if (w >= 560) {
          cross_axis_count = 2;
        } else {
          cross_axis_count = 1;
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: list.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cross_axis_count,
            mainAxisExtent: card_height,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemBuilder: (context, index) {
            final post = list[index];

            return PostCard(
              post: post,
              thumbnail_height: 145,
              on_tap: () => widget.on_post_tap(post),
            );
          },
        );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? sub_title;
  final String? action_text;
  final VoidCallback? on_action_tap;

  const _SectionTitle({
    required this.icon,
    required this.title,
    this.sub_title,
    this.action_text,
    this.on_action_tap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 22, color: const Color(0xFF2563EB)),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.4,
                          ),
                    ),
                    if (sub_title != null && sub_title!.trim().isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Text(
                        sub_title!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[700],
                            ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        if (action_text != null && on_action_tap != null)
          TextButton(
            onPressed: on_action_tap,
            style: TextButton.styleFrom(
              foregroundColor: Colors.black87,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(action_text!),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_forward_rounded, size: 16),
              ],
            ),
          ),
      ],
    );
  }
}

class HomeProjectCard extends StatelessWidget {
  final String label;
  final String title;
  final String description;
  final String button_text;
  final IconData icon;
  final Color accent_color;
  final VoidCallback on_tap;
  final String? background_image;

  const HomeProjectCard({
    super.key,
    required this.label,
    required this.title,
    required this.description,
    required this.button_text,
    required this.icon,
    required this.accent_color,
    required this.on_tap,
    this.background_image,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: on_tap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: 320,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: const Color(0xFF0F172A),
          boxShadow: [
            BoxShadow(
              blurRadius: 18,
              offset: const Offset(0, 8),
              color: Colors.black.withOpacity(0.10),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (background_image != null)
              Image.asset(
                background_image!,
                fit: BoxFit.cover,
              ),

            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.black.withOpacity(0.45),
                    Colors.black.withOpacity(0.20),
                    Colors.black.withOpacity(0.08),
                  ],
                ),
              ),
            ),

            Positioned(
              right: -24,
              top: -20,
              child: Icon(
                icon,
                size: 150,
                color: accent_color.withOpacity(0.12),
              ),
            ),
            Positioned(
              right: 18,
              bottom: 16,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: accent_color.withOpacity(0.28),
                    width: 1.2,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                    decoration: BoxDecoration(
                      color: accent_color.withOpacity(0.92),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: accent_color.withOpacity(0.22),
                      ),
                    ),
                    child: Text(
                      label,
                      style: TextUtil.get12(context, Colors.white).copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.6,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextUtil.get14(
                      context,
                      Colors.white.withOpacity(0.92),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        button_text,
                        style: TextUtil.get13(context, Colors.white).copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeSidePostCard extends StatelessWidget {
  final PostMeta post;
  final VoidCallback on_tap;

  const HomeSidePostCard({
    super.key,
    required this.post,
    required this.on_tap,
  });

  String? _thumbnailUrl() {
    final t = post.thumbnail;
    if (t == null || t.isEmpty) return null;
    return t.startsWith('http') ? t : '$NAS_BASE_URL$t';
  }

  @override
  Widget build(BuildContext context) {
    final thumb_url = _thumbnailUrl();
    final style = resolveHomeCategoryStyle(post);
    return InkWell(
      onTap: on_tap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black.withOpacity(0.06)),
          boxShadow: [
            BoxShadow(
              blurRadius: 12,
              offset: const Offset(0, 6),
              color: Colors.black.withOpacity(0.06),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            SizedBox(
              width: 165,
              height: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (thumb_url != null)
                    Image.network(
                      thumb_url,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _thumbFallback(),
                    )
                  else
                    _thumbFallback(),
                    Positioned(
                      left: 10,
                      top: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: style.bg_color,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: style.border_color, width: 1.2),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                              color: Colors.black.withOpacity(0.18),
                            ),
                          ],
                        ),
                        child: Text(
                          style.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextUtil.get12(context, style.text_color).copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextUtil.get15(
                        context,
                        Colors.black,
                        font_weight: FontWeight.w900,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 11,
                          backgroundImage: AssetImage('assets/logo.png'),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'GoldenBoy',
                          style: TextUtil.get12(context, Colors.grey.shade700),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '·',
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            post.created_at,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextUtil.get12(context, Colors.grey.shade700),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _thumbFallback() {
    return Container(
      color: const Color(0xFFF2F2F7),
      child: const Center(
        child: Icon(Icons.image_outlined, size: 30, color: Colors.black26),
      ),
    );
  }
}