/*text preview 볼수 있도록 */
import 'package:flutter/material.dart';
import 'package:nas_blog1/utils/markdown/markdown.dart';


class PreviewDialog{
  static void open(BuildContext context, {required String title, required String body})
  {
    /*팝업 띄우는 함수 */
    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: SizedBox(
          width: 900,
          height: 700,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  title.isEmpty ? '(No title)' : title,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),

                ),
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height:12),
                Expanded(
                  child: SingleChildScrollView(
                    // child: SelectableText(body.isEmpty ? '(No content)' : body),
                    child: BlogMarkdownBody(
                      data: (body.isEmpty ? '(No content)' : body)
                    .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '  \n'),
                  )
                )
                ),
              ]
            )
          )
        )
      )
    );
  }
}