/*purpose : +눌렀을때 다이얼로그 */

import 'package:flutter/material.dart';
import 'package:nas_blog1/models/blog_category.dart';
import 'package:nas_blog1/ui/pages/editor/dialogs/add_category_dialog.dart';


class AddCategoryDialogResult{
  final String name;
  final String? parent_id; //null => root
  const AddCategoryDialogResult({
    required this.name, 
    required this.parent_id
  });
}




class AddCategoryDialog extends StatefulWidget {
  final List<BlogCategory> categories_flat;
    
  const AddCategoryDialog({
    super.key,
    required this.categories_flat,
    });

  @override
  State<AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends State<AddCategoryDialog> {
  final _ctrl = TextEditingController();
  String? _parent_id; //null => root



  @override
    void dispose() {
      // TODO: implement dispose
      _ctrl.dispose();
      super.dispose();

    }

  @override
  Widget build(BuildContext context) {
    /*부모 후보: root 카테고리만 넣고 싶으면 parent_id == null만 필터링 */
    final parents = widget.categories_flat;
    //flat 리스트

    /*AlertDialog
        title: 상단 제목
        content: 본문 입력(UI)
        actions: 하단 버튼 영역
     */
    return AlertDialog(
      title: const Text('New category'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /*이름 받기 */
            TextField(
              controller: _ctrl,
              autofocus: true, //커서 여기로 이동
              decoration : const InputDecoration(
                labelText: 'Category name',
                border: OutlineInputBorder(),
              )
            ),
            const SizedBox(height: 12,),
            /*부모 옵션 선택 */
            DropdownButtonFormField<String?>(
              //부모 없을 수도 있으니 ?로 
              value: _parent_id,
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('(No parent)'),
                ),
                ...parents.map(
                  (c) => DropdownMenuItem<String?>(
                    value: c.id,
                    child: Text(c.name),                   
                  ),
                )
              ],
              onChanged: (v) => setState(() => _parent_id = v),
              decoration: const InputDecoration(
                labelText: 'Parent category (optional)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      /* 하단 버튼 영역 */
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),

        ),
        ElevatedButton(
          onPressed: () {
            final name = _ctrl.text.trim();
            if(name.isEmpty) return;

            Navigator.pop(
              context,
              AddCategoryDialogResult(name: name, parent_id : _parent_id),
            );
          },
          child: const Text('OK'),
        )
      ]
    );
  }
}