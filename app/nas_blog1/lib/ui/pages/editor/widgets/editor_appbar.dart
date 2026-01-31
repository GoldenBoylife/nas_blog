
/*어디테 화면 상단에 들어갈 '커스텀 AppBar 위젯 */
//왼쪽 : 제목 New Post
//오른족 Preview 아이콘 버튼
//오른쪽 끝 : Save버튼
import 'package:flutter/material.dart';

class EditorAppBar extends StatelessWidget implements PreferredSizeWidget{
  //PreferredSizeWidget : AppBar자리에 넣기위해서 필요.
  //preferredSize :높이 
  final bool is_saving;
  final VoidCallback on_preview;
  final VoidCallback on_save;
  final String title;

  const EditorAppBar({
    super.key,
    required this.title,
    required this.is_saving,
    required this.on_preview, //콜백함수
    required this.on_save,
    });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title:  Text(title),
      actions: [
        IconButton(
          tooltip: 'Preview',
          onPressed: on_preview,
          icon: const Icon(Icons.remove_red_eye_outlined)
        ),
        const SizedBox(width: 6),
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: ElevatedButton.icon(
            onPressed: is_saving ? null : on_save,
            icon: is_saving 
              ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
              : const Icon(Icons.save_outlined),
            label: const Text('Save'),
          )
        )
      ]
    );
  }
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
  //dart의 getter 문법
  //preferredSize 라는 값 요청 받으면, Size.fromHeight(kToolbarHeight)를 리턴해라. 
}