import 'package:flutter/material.dart';
import 'package:nas_blog1/ui/common_widgets/panels/panel_card.dart';

class EditorToolsPanel extends StatelessWidget {
  final VoidCallback on_insert_image;
  final VoidCallback on_insert_video;


  const EditorToolsPanel({
    super.key,
    required this.on_insert_image,
    required this.on_insert_video,
    });




  @override
  Widget build(BuildContext context) {
    return PanelCard(
      title: 'Editor Tools',
      child: Column(
        children: [
          _toolButton(
            icon: Icons.image_outlined,
            label: 'Insert image',
            on_tap : on_insert_image,
          ),
          _toolButton(
            icon: Icons.video_file_outlined,
            label: 'Insert video',
            on_tap: on_insert_video,
          )
        ]
      )
    );
  }
  /*funcs
  - _toolButton
   */

  
  Widget _toolButton({ required IconData icon, required String label, required VoidCallback on_tap})
  {
    return InkWell(
      onTap: on_tap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200),
          color: Colors.grey.shade50,
          ),
          child: Row(
            children: [
              Icon(icon, size:18),
              const SizedBox(width: 10),
              Expanded(child: Text(label, overflow : TextOverflow.ellipsis))
            ]
          )
        ),
      );    
  }

}