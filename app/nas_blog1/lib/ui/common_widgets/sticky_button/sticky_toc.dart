import 'package:flutter/material.dart';
import 'package:nas_blog1/ui/pages/post/widgets/toc_overlay_card.dart';

class StickyToc extends StatefulWidget {
  final String markdown;
  final double left;
  final double top;

  const StickyToc({
    super.key,
    required this.markdown,
    this.left = 16,
    this.top = 92,
  });

  @override
  State<StickyToc> createState() => _StickyTocState();
}

class _StickyTocState extends State<StickyToc> {
  bool _open = false;

  static const Color _dark = Color(0xFF111827);
  static const Color _panelBg = Color(0xFFF8F5FF);
  static const Color _panelBorder = Color(0xFFE9DDF5);
  static const Color _accent = Color(0xFFF59E0B);
  static const Color _text = Color(0xFF1F2937);
  static const Color _subText = Color(0xFF6B7280);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.left,
      top: widget.top,
      child: AnimatedContainer(
        // Container의 애니메이션 버전이고 부드럽게 보간됨.

        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        width: _open ? 320 : 112,
        child: Material(
          color: Colors.transparent,
          elevation: _open ? 10 : 6,
          borderRadius: BorderRadius.circular(_open ? 18 : 16),
          clipBehavior: Clip.antiAlias,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 160),
            child: _open ? _buildOpenPanel() : _buildClosedButton(),
          ),
        ),
      ),
    );
  }

  Widget _buildClosedButton() {
    return InkWell(
      key: const ValueKey('toc_closed'),
      onTap: () => setState(() => _open = true),
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: _panelBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _panelBorder,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.format_list_bulleted_rounded,
              size: 18,
              color: _accent,
            ),
            SizedBox(width: 8),
            Text(
              '목차',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: _text,
                letterSpacing: -0.2,
              ),
            ),
            SizedBox(width: 4),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: _dark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOpenPanel() {
    return TocOverlayCard(
      key: const ValueKey('toc_open'),
      markdown: widget.markdown,
      on_close: () => setState(() => _open = false),
    );
  }
}