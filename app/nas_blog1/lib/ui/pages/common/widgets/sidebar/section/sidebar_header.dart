import 'package:flutter/material.dart';
import 'package:nas_blog1/constants/asset_path.dart';
import 'package:nas_blog1/ui/pages/common/theme/my_color.dart';
import 'package:nas_blog1/ui/pages/common/theme/text_util.dart';

class SidebarHeader extends StatefulWidget {
  final VoidCallback on_home;
  final VoidCallback? on_refresh;

  final VoidCallback? on_about;

  final String title;
  final String handle;
  final String tag_line;
  //나중에 서버 ,설정을 바꾸기 쉬움.

  const SidebarHeader({
    super.key,
    required this.on_home,
    this.on_refresh,
    this.on_about,
    this.title = "Dr.GoldenBoy Lab",
    this.handle = 'GB_',
    this.tag_line = '다시 태어나도 내 자신이고 싶은 그러한 삶을 위하여',
    });

  @override
  State<SidebarHeader> createState() => _SidebarHeaderState();
}

class _SidebarHeaderState extends State<SidebarHeader> {
  @override
  Widget build(BuildContext context) {
    return  Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 180,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(14),
                    bottomRight: Radius.circular(14),
                  ),
                  child: Image.asset(
                    AssetPath.logo_background_jpg,
                    fit: BoxFit.cover,
                  ),
                )
              ),
              Container(
                width: 124,
                height: 124,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: Colors.white.withOpacity(0.18)),
                ),
                padding: const EdgeInsets.all(10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: Image.asset(
                    AssetPath.logo_png,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              /*우측 상단 버튼들 */
              Positioned(
                right: 10,
                top: 10,
                child: Row(
                  children: [
                    PillIcon(icon: Icons.home_outlined, on_tap: widget.on_home),
                    const SizedBox(width: 6),
                    if (widget.on_about != null) ...[
                      PillIcon(icon: Icons.info_outline, on_tap: widget.on_about!),
                      const SizedBox(width: 6),
                    ],
                    if (widget.on_refresh != null)
                      PillIcon(icon: Icons.refresh, on_tap: widget.on_refresh!),
                  ]
                )
              )
            ]
          )
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.title,
                textAlign: TextAlign.center,
                style: TextUtil.get16(context, MyColor.gray90, font_weight: FontWeight.w900)
                    .copyWith(letterSpacing: -0.3),
              ),
const SizedBox(height: 8),

Row(
  children: [
    Expanded(
      child: Text(
        '로봇 덕후의 기록',
        style: TextUtil.get13(context, MyColor.gray60).copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    ),
    const SizedBox(width: 8),

    // HOME 버튼
    _MiniActionButton(
      icon: Icons.home_outlined,
      tooltip: 'Home',
      onTap: widget.on_home,
    ),

    const SizedBox(width: 6),

    // Refresh는 있을 때만
    // if (widget.on_refresh != null)
    //   _MiniActionButton(
    //     icon: Icons.refresh,
    //     tooltip: 'Refresh',
    //     onTap: widget.on_refresh!,
    //   ),
  ],
),
              const SizedBox(height: 10),

              // ✅ 소개 문구 (한줄~두줄)
             // ✅ 소개 문구 (업그레이드 버전 B)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.035),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.black.withOpacity(0.07)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD6A74A).withOpacity(0.18),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: const Color(0xFFD6A74A).withOpacity(0.35)),
                      ),
                      child: const Icon(Icons.auto_awesome, size: 16),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        widget.tag_line,
                        textAlign: TextAlign.left, // 여기만 left로 두는게 읽기 편함
                        style: TextUtil.get13(
                          context,
                          MyColor.gray90,
                          font_weight: FontWeight.w800,
                        ).copyWith(
                          height: 1.35,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),
      ]
    );
  }



  }














class PillIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback on_tap;

  const PillIcon({
    super.key,
    required this.icon,
    required this.on_tap
    
    });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      //클릭 탭 가능한 영역 만들기
      borderRadius: BorderRadius.circular(999),
      onTap: on_tap,
      child: Container(
        width: 36, 
        height: 36,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.05),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.black.withOpacity(0.06)),
        ),
        child: Icon(icon,size: 18),

      )
      
      );
  }
}


class _MiniActionButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _MiniActionButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.04),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.black.withOpacity(0.06)),
          ),
          child: Icon(icon, size: 18),
        ),
      ),
    );
  }
}
