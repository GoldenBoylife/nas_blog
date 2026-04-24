import 'package:flutter/material.dart';
import 'package:nas_blog1/utils/markdown/markdown_image_meta.dart';
import 'package:nas_blog1/utils/markdown/markdown_youtube.dart';

/*
  Markdown 안의 이미지를 그냥 기본 방식으로 그리지 않고, 커스텀 방식으로 렌더링해주는 함수
  Markdown 이미지의 크기/ 정렬/ 캡션을 적용해서 보여주고, 유튜브 썸네일이면 재생 버튼 오버레이까지 얹어주는 이미지 빌더
 */

Widget buildMarkdownImage({
  required BuildContext context,
  required Uri uri,
  required String? alt,
  required String? title,
  required double max_width,
}) {

  final meta = MarkdownImageMeta.parse(title);
  final width_factor =imageSizeToFactor(meta.size);
  final alignment = imageAlignToAlignment(meta.align);

  final available_width = max_width.isFinite ? 
            max_width : MediaQuery.of(context).size.width;
  
  final target_width = available_width * width_factor;

  Widget image = Image.network(
    uri.toString(),
    width: target_width,
    fit: BoxFit.contain,
    errorBuilder: (context, error, stackTrace) {
      return Container(
        color: Colors.grey[200],
        padding: const EdgeInsets.all(8),
        child: const Text(
          '썸네일을 불러올 수 없네요잉.',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey,
          )
        )
      );
    },
  );

  if(isYoutubeThumbnail(uri))
  {
    image = Stack(
      alignment : Alignment.center,
      children : [
        image,
        Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.35),
            shape: BoxShape.circle,

          ),
          padding: const EdgeInsets.all(6),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius : BorderRadius.circular(6),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical:6
            ),
            child: const Icon(
              Icons.play_arrow,
              color: Colors.white,
              size: 28,
            )

          )
        )
      ]
    );
  }

  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: SizedBox(
      width : double.infinity,
      child: Align(
        alignment: alignment,
        child: SizedBox(
          width: target_width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              image,
              if(meta.caption !=null && meta.caption!.isNotEmpty) ... [
                const SizedBox(height: 8,),
                Text(meta.caption!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color.fromARGB(255,88,88,88),
                  fontStyle: FontStyle.italic,
                ))
              ]
            ]
          )
        )
      )
    )
  );
}