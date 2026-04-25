import 'package:flutter/material.dart';
import 'package:nas_blog1/ui/pages/common/theme/my_color.dart';
import 'package:nas_blog1/ui/pages/common/theme/text_util.dart';

class SidebarHeader extends StatefulWidget {
  final VoidCallback on_home;
  final VoidCallback? on_refresh;
  final VoidCallback? on_about;

  final String title;
  final String handle;
  final String tag_line;

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
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 상단 이미지
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: SizedBox(
              height: 180,
              width: double.infinity,
              child: Image.asset(
                'assets/sidebar_image1.png',
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // 기존 Dr.GoldenBoy Lab 텍스트 대신 버튼 영역
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _HeaderPillButton(
                icon: Icons.home_outlined,
                label: 'Home',
                onTap: widget.on_home,
              ),
            ],
          ),

          const SizedBox(height: 14),

          // 로봇 덕후의 기록: 옆에 홈 버튼 없음
          Text(
            '로봇 덕후의 기록',
            style: TextUtil.get13(context, MyColor.gray60).copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
            ),
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 10),

          // 소개 문구 카드
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.035),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.black.withOpacity(0.07),
              ),
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
                    border: Border.all(
                      color: const Color(0xFFD6A74A).withOpacity(0.35),
                    ),
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    size: 16,
                    color: Color(0xFF8A5A00),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.tag_line,
                    textAlign: TextAlign.left,
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
    );
  }
}

class _HeaderPillButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _HeaderPillButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: Colors.black.withOpacity(0.08),
            ),
            boxShadow: [
              BoxShadow(
                blurRadius: 8,
                offset: const Offset(0, 2),
                color: Colors.black.withOpacity(0.05),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 17,
                color: Colors.black87,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}