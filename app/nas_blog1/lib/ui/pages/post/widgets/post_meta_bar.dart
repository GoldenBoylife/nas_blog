import 'package:flutter/material.dart';

class PostMetaBar extends StatelessWidget {
  final String author;
  final String created_at;
  final List<String> tags;
  const PostMetaBar({
    super.key,
    required this.author,
    required this.created_at,
    required this.tags
    
    });

  @override
  Widget build(BuildContext context) {
    /*Wrap: 
      Row처럼 가로로 배치하되 공간이 부족하면 자동으로 다음 줄로 해주는 레이아웃 
    */
    return  Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      //같은 줄에 있는 위젯들을 세로 기준으로 가운데 정렬
      spacing: 10,
      runSpacing: 12,
      children: [
        Row(
          mainAxisSize:  MainAxisSize.min,
          //부모 공간 모두 쓰지말고, 자식 크기만큼만 차지.
          children: [
            const Icon(Icons.person, size: 16),
            const SizedBox(width: 6),
            Text(author, style: Theme.of(context).textTheme.bodyMedium)
          ],
      
          
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.calendar_month, size: 16),
            const SizedBox(width: 6),
            Text(created_at, style: Theme.of(context).textTheme.bodyMedium),
          ]
        ),
        /*태그 존재시  */
        if(tags.isNotEmpty) 
        ...tags.map((t) => Chip(
          label: Text('#$t'),
          visualDensity: VisualDensity.compact,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ))
        
      ,
      ]
    );
  }
}