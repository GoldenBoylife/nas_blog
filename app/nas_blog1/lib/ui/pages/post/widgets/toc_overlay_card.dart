import 'dart:ui';

import 'package:flutter/material.dart';

class TocItem {
  final int depth;
  final String text;

  TocItem({
    required this.depth,
    required this.text,
  });
}

class TocOverlayCard extends StatefulWidget {
  final String markdown;
  final VoidCallback on_close;

  const TocOverlayCard({
    super.key,
    required this.markdown,
    required this.on_close,
  });

  @override
  State<TocOverlayCard> createState() => _TocOverlayCardState();
}

class _TocOverlayCardState extends State<TocOverlayCard> {
  final ScrollController _scrollController = ScrollController();

  static const Color _bg = Color(0xFFF9F4FF);
  static const Color _headerBg = Color(0xFFF2E8FA);
  static const Color _accent = Color(0xFFF59E0B);
  static const Color _text = Color(0xFF25202C);
  static const Color _subText = Color(0xFF6B6174);

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final headings = _extractHeadings(widget.markdown);

    final maxHeight = MediaQuery.of(context).size.height - 150;

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 16,
          sigmaY: 16,
        ),
        child: Container(
          width: 300,
          constraints: BoxConstraints(
            maxHeight: maxHeight.clamp(360, 620),
          ),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.56),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Colors.white.withOpacity(0.78),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.14),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(),
              Container(
                height: 1,
                color: Colors.white.withOpacity(0.60),
              ),
              Flexible(
                child: headings.isEmpty
                    ? _buildEmpty()
                    : _buildScrollableList(headings),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: Colors.white.withOpacity(0.32),
      padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.78),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.format_list_bulleted_rounded,
              size: 18,
              color: _accent,
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '목차',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: _text,
                    letterSpacing: -0.3,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Table of Contents',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _subText,
                    letterSpacing: 0.1,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: widget.on_close,
            tooltip: 'Close',
            icon: const Icon(
              Icons.close_rounded,
              size: 22,
              color: _subText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(28),
        child: Text(
          '목차가 없습니다.',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: _subText,
            letterSpacing: -0.2,
          ),
        ),
      ),
    );
  }

  Widget _buildScrollableList(List<TocItem> headings) {
    return Scrollbar(
      controller: _scrollController,
      thumbVisibility: true,
      thickness: 4,
      radius: const Radius.circular(999),
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(10, 12, 12, 12),
        itemCount: headings.length,
        separatorBuilder: (_, __) => const SizedBox(height: 4),
        itemBuilder: (_, i) {
          final h = headings[i];

          final left = switch (h.depth) {
            1 => 0.0,
            2 => 14.0,
            _ => 28.0,
          };

          final fontSize = switch (h.depth) {
            1 => 14.5,
            2 => 13.5,
            _ => 13.0,
          };

          final fontWeight = switch (h.depth) {
            1 => FontWeight.w800,
            2 => FontWeight.w700,
            _ => FontWeight.w600,
          };

          return Padding(
            padding: EdgeInsets.only(left: left),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                // 나중에 해당 heading 위치로 scroll 이동
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: h.depth == 1
                      ? Colors.white.withOpacity(0.46)
                      : Colors.white.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 5,
                      height: 5,
                      margin: const EdgeInsets.only(top: 8),
                      decoration: BoxDecoration(
                        color: h.depth == 1
                            ? _accent
                            : const Color(0xFFC4B5D4),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        h.text,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: fontSize,
                          height: 1.35,
                          fontWeight: fontWeight,
                          color: _text,
                          letterSpacing: -0.25,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  List<TocItem> _extractHeadings(String md) {
    final lines = md.split('\n');
    final items = <TocItem>[];

    for (final line in lines) {
      final m = RegExp(r'^(#{1,3})\s+(.+)$').firstMatch(line.trim());
      if (m == null) continue;

      final depth = m.group(1)!.length;
      final text = m.group(2)!.trim();

      items.add(
        TocItem(
          depth: depth,
          text: text,
        ),
      );
    }

    return items;
  }
}