/*purpose : +눌렀을때 다이얼로그 */

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nas_blog1/config/category_icon_registry.dart';
import 'package:nas_blog1/models/blog_category.dart';
import 'package:nas_blog1/ui/pages/editor/dialogs/add_category_dialog.dart';


class AddCategoryDialogResult{
  final String name;
  final String? parent_id; //null => root
  final String? icon_key; //260205 추가
  const AddCategoryDialogResult({
    required this.name, 
    required this.parent_id,
    required this.icon_key, //260205 추가
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
  String? _icon_key = CategoryIconRegistry.default_key; //기본값, 260205추가



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
            const SizedBox(height: 12),
            /*Icon 선택 */
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Icon',
                style: Theme.of(context).textTheme.titleSmall,
              )
            ),
            const SizedBox(height:8),
            _IconPickerGrid(
              selected_key : _icon_key,
              on_select:(k) => setState(() => _icon_key = k),
            )

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
              AddCategoryDialogResult(
                name: name, 
                parent_id : _parent_id,
                icon_key : _icon_key
                ),
            );
          },
          child: const Text('OK'),
        )
      ]
    );
  }

}

class _IconPickerGrid extends StatelessWidget {
  final String? selected_key;
  final ValueChanged<String> on_select;

  const _IconPickerGrid({
    super.key,
    required this.selected_key,
    required this.on_select,
    });

  @override
  Widget build(BuildContext context) {
    final keys = CategoryIconRegistry.keys;
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing:8,
        children : [
          for(final k in keys) 
            _IconChip(
              key_name: k,
              selected: k == selected_key,
              on_tap: () => on_select(k),
            )
        ]
      )
    );
  }
}

/*dkdlzhs tjsxordyd clq */
class _IconChip extends StatelessWidget {
  final String key_name;
  final bool selected;
  final VoidCallback on_tap;
  const _IconChip({
    super.key,
    required this.key_name,
    required this.selected,
    required this.on_tap
    });

  @override
  Widget build(BuildContext context) {
    final icon = CategoryIconRegistry.iconFromKey(key_name);
    //icon_data를 가져온다.  ex) robot -> Icons.smart_toy_outlined
    return InkWell(
      onTap: on_tap,
      borderRadius: BorderRadius.circular(666),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? Colors.black.withOpacity(0.08) : Colors.transparent,
          border: Border.all(
            color: selected ? Colors.black : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon,size: 18),
              const SizedBox(width: 6,),
              Text(
                key_name,
                style: TextStyle(
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                )
              )
            ]
          )

        )
      
    );
  }
}