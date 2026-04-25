import 'package:flutter/material.dart';
import 'package:nas_blog1/ui/pages/common/widgets/menu/site_brand.dart';

class TopBar extends StatelessWidget {
  final double height;
  final bool black;
  final bool show_hamburger;
  final VoidCallback? on_tap_hamburger;
  final List<Widget> actions;

  const TopBar({
    this.height = 64,
    required this.black,
    required this.show_hamburger,
    this.on_tap_hamburger,
    this.actions = const <Widget>[],
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = black ? Colors.white : Colors.black;

    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: black ? Colors.black : Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.withOpacity(0.2)),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compactBrand = constraints.maxWidth < 560;

          return Stack(
            alignment: Alignment.center,
            children: [
              Center(
                child: SiteBrand(
                  compact: compactBrand,
                ),
              ),

              Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (show_hamburger)
                      IconButton(
                        onPressed: on_tap_hamburger,
                        icon: Icon(
                          Icons.menu,
                          color: iconColor,
                        ),
                        tooltip: 'Open sidebar',
                      ),
                  ],
                ),
              ),

              Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ...actions,
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}