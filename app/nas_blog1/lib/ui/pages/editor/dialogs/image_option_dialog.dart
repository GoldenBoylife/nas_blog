import 'package:flutter/material.dart'; //ui관련된 클래스를 함꺼번에 가져오는 선언,

/*모델 객체*/
//getter가없는 이유는, final로 선언했기에 자동으로 불변데이터 객체이고, 자동으로 getter가 붙어 있음. 
//opt.size, opt.align으로 접근 가능하다. 
class ImageInsertOption{
  final String size; //small,medium,large, full
  final String align; //left, center, right,
  final String? caption; //optional
  ImageInsertOption({
    required this.size, 
    required this.align,
    this.caption //this may be provided, so that should be allowed as well.
    });
}


class ImageOptionDialog extends StatefulWidget {
  const ImageOptionDialog({super.key});

  
  @override
  State<ImageOptionDialog> createState() => _ImageOptionDialogState();



}

class _ImageOptionDialogState extends State<ImageOptionDialog> {
  String size_ = 'medium';
  String align_ = 'center';
  final TextEditingController caption_ctrl = TextEditingController();

  @override
  void dispose() {
    caption_ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Image option'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Size'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: const Text('Small'),
                selected: size_ == 'small',
                onSelected: (_) => setState(() => size_ ='small'),
                  
              ),
              ChoiceChip(
                label: const Text('Medium'),
                selected: size_ == 'medium',
                onSelected: (_) => setState(() => size_ = 'medium'),
                ),
                ChoiceChip(
                  label: const  Text('Large'),
                  selected : size_ =='large',
                  onSelected: (_) => setState(() => size_ = 'large'),
                ),
                ChoiceChip(
                  label: const Text('Full'),
                  selected: size_ == 'full',
                  onSelected: (_) => setState(() => size_ = 'full'),
                ),
            ]
          ),
          const SizedBox(height: 16),
          const Text('Align'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: const Text('Left'),
                selected: align_ == 'left',
                onSelected: (_) => setState(() => align_ = 'left'),
              ),
              ChoiceChip(
                label: const Text('Center'),
                selected: align_ == 'center',
                onSelected: (_) => setState(() => align_ = 'center'),
              ),
              ChoiceChip(
                label: const  Text('Right'),
                selected: align_ == 'right',
                onSelected: (_) => setState(() =>  align_ = 'right'),
              ),
            ]
          ),
            /*caption  */
      const SizedBox(height:16),
      TextField(
        controller: caption_ctrl,
        decoration: const InputDecoration(
          labelText: 'Caption',
          hintText: '그림 아래에 들어갈 설명',
          border: OutlineInputBorder(),
        ),
        maxLines: 2,
      )
        ]
      ),

      actions: [
        TextButton(
          onPressed : () => Navigator.pop<ImageInsertOption>(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(
              context,
              ImageInsertOption(
                size: size_, 
                align: align_,
                caption: caption_ctrl.text.trim()
                )
            );
          }, 
          child: const Text('OK'),
        )
      ]
    );
  }
}