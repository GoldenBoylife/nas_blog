import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart' as fm;
import 'dart:math' as math;

import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:url_launcher/url_launcher.dart';



//"as fm" : namespace concept in C++
// import 'package:markdown/markdown.dart' as md;


///common Markdown style
//fm : flutter markdown
//for markdown style
fm.MarkdownStyleSheet blogMarkdownStyle(BuildContext context) {
  final base = fm.MarkdownStyleSheet.fromTheme(Theme.of(context));
  return base.copyWith(
    p: const TextStyle(fontSize: 16, height: 1.6),
    h1: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold,color: Color.fromARGB(255, 168, 98, 6) ),
    h2: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold,color: Color.fromARGB(255, 57, 91, 241)), //22
    h3: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold,color: Color.fromARGB(255, 171, 39, 197)), //20
    h4: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 29, 219, 38)), //20
    h5: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), //20
    h6: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold), //20

    code: const TextStyle(
      fontFamily: 'monospace',
      fontSize:14,
    )
  );
}

/*only scrollable markdown view in total screen*/
//wrapping flutter_markdown.Markdown 
//full screen view included scroll
class BlogMarkdownScroll extends StatelessWidget {

  final String data;
  final EdgeInsets padding;
  final ScrollController? controller;
  final ScrollPhysics? physics;
  final bool shrink_wrap;

  final bool selectable;
  final fm.MarkdownStyleSheet? style_sheet;


  const BlogMarkdownScroll({
    super.key,
    required this.data,
    this.padding = const EdgeInsets.all(16.0),
    this.controller,
    this.physics,
    this.shrink_wrap = false,
    this.selectable = false,
    this.style_sheet,
    });

  // @override
  // void initState()
  // {

  // }
  // "initState() is only used in  statefulWidget"
  // there is no state  in statelessWidget, you don't need to use "initState()"
  // when setting up screen, state is fixed. don't need to change the screen.

  @override
  Widget build(BuildContext context) {
    return fm.Markdown(
      data: data,
      padding: padding,
      controller: controller,
      physics: physics,
      shrinkWrap : shrink_wrap,
      selectable: selectable,
      styleSheet: style_sheet ?? blogMarkdownStyle(context),
    );
  }
}

/*external SingleChildScrollview 's makrdown */
// no scrolldown, wraping MarkdownBody
class BlogMarkdownBody extends StatelessWidget {
  final String data;
  final fm.MarkdownStyleSheet? style_sheet;

  const BlogMarkdownBody({
    super.key,
    required this.data,
    this.style_sheet,
  });

  @override
  Widget build(BuildContext context) {
    final style = style_sheet ?? blogMarkdownStyle(context);

    // 화면 폭에 따라 이미지 최대 너비를 결정하기 위해 LayoutBuilder 사용
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final processed = _preprocessYoutubeLinks(data);


        return fm.MarkdownBody(
          data: processed,
          styleSheet: style,

          // 🔹 이미지 렌더링 커스터마이즈
imageBuilder: (uri, alt, title) {
  final meta = _parseImageMeta(title);
  final widthFactor = _sizeToFactor(meta.size);
  final alignment = _alignToAlignment(meta.align);

  debugPrint('alt=$alt');
  debugPrint('title=$title');
  debugPrint('meta.size=${meta.size}, meta.align=${meta.align}');
  debugPrint('maxWidth=$maxWidth');

  double? imgWidth;
  if (maxWidth.isFinite) {
    imgWidth = maxWidth * widthFactor;
  }

  // 기본 이미지 위젯
  Widget thumbImage = Image.network(
    uri.toString(),
    width: imgWidth,
    fit: BoxFit.contain,
    errorBuilder: (context, error, stackTrace) {
      return Container(
        color: Colors.grey[200],
        padding: const EdgeInsets.all(8),
        child: const Text(
          '썸네일을 불러올 수 없습니다.',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      );
    },
  );

  // 🔴 YouTube 썸네일이면 가운데 재생 버튼 오버레이
  if (_isYoutubeThumbnail(uri)) {
    thumbImage = Stack(
      alignment: Alignment.center,
      children: [
        // 썸네일
        thumbImage,
        // 반투명 검정 원 + 빨간 플레이 버튼
        Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.35),
            shape: BoxShape.circle,
          ),
          padding: const EdgeInsets.all(6),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(6),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: const Icon(
              Icons.play_arrow,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
      ],
    );
  }


final availableWidth =
    maxWidth.isFinite ? maxWidth : MediaQuery.of(context).size.width;
final targetWidth = availableWidth * widthFactor;

return Padding(
  padding: const EdgeInsets.symmetric(vertical: 8),
  child: SizedBox(
    width: double.infinity,
    child: Align(
      alignment: alignment,
      child: SizedBox(
        width: targetWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            thumbImage,
            if (meta.caption != null && meta.caption!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                meta.caption!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color.fromARGB(255, 88, 88, 88),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    ),
  ),
);


},
          // 🔹 링크 클릭 처리 (유튜브는 다이얼로그, 나머지는 브라우저)
          onTapLink: (text, href, title) async {
            if (href == null) return;

            final url = _normalizeUrl(href);
            final uri = Uri.parse(url);

            if (_isYouTubeUrl(uri)) {
              await _showYouTubeDialog(context, url);
            } else {
              if (await canLaunchUrl(uri)) {
                await launchUrl(
                  uri,
                  mode: LaunchMode.externalApplication,
                );
              }
            }
          },
        );
      
      },
    );
  }
}


/// title 문자열에서 size/align 정보 꺼내기
class _ImageMeta {
  final String size;   // small, medium, large, full
  final String align;  // left, center, right
  final String? caption;
  _ImageMeta({required this.size, required this.align,  this.caption});
}

_ImageMeta _parseImageMeta(String? title) {
  // 기본값
  String size = 'medium';
  String align = 'center';
  String? caption;

  if (title == null || title.isEmpty) {
    return _ImageMeta(size: size, align: align, caption: caption);
  }

  // "size=medium;align=center" 같은 형식 파싱
  final parts = title.split(';');
  for (final part in parts) {
    final kv = part.split('=');
    if (kv.length != 2) continue;
    final key = kv[0].trim();
    final value = kv[1].trim();

    if (key == 'size') {
      size = value;
    } else if (key == 'align') {
      align = value;
    } else if (key == 'caption') {
      caption = Uri.decodeComponent(value);
    }
  }

  return _ImageMeta(size: size, align: align, caption: caption);
}

/// 사이즈 문자열을 0~1.0 스케일로 변환
double _sizeToFactor(String size) {
  switch (size) {
    case 'small':
      return 0.1;
    case 'medium':
      return 0.5;
    case 'large':
      return 0.7;
    case 'full':
      return 1.0;
    default:
      return 0.5;
  }
}

/// 정렬 문자열을 Alignment 로 변환
Alignment _alignToAlignment(String align) {
  switch (align) {
    case 'left':
      return Alignment.centerLeft;
    case 'right':
      return Alignment.centerRight;
    case 'center':
    default:
      return Alignment.center;
  }
}














// class Markdown extends MarkdownWidget{
  
//     final EdgeInsets padding;
//     final ScrollController? controller;
//     final ScrollPhysics? physics;
//     final bool shrinkWrap;


//     const Markdown({
//       //super : 부모의 생성자로 전달.
//         super.key,
//         required super.data,
//         super.selectable,
//         super.styleSheet,
//         super.styleSheetTheme = null,
//         super.syntaxHighlighter,
//         super.onSelectionChanged,
//         super.onTapLink,
//         super.onTapText,
//         super.imageDirectory,
//         super.blockSyntaxes,
//         super.inlineSyntaxes,
//         super.extensionSet,
//         super.sizedImageBuilder,
//         super.checkboxBuilder,
//         super.bulletBuilder,
//         super.builders,
//         super.paddingBuilders,
//         super.listItemCrossAxisAlignment,
//         this.padding = const EdgeInsets.all(16.0),
//         this.controller,
//         this.physics,
//         this.shrinkWrap = false,
//         super.softLineBreak,
//     });


//     @override
//     /*how to draw this widget on the screen as tree */
//   Widget build(BuildContext context, List<Widget>? children) {
//     return ListView(
//       padding: padding,
//       controller: controller,
//       physics: physics,
//       shrinkWrap: shrinkWrap,
//       children: children!,
//       //!:this value is never null. if "null", runtime error.
//     );
//   }
// }

bool _isYouTubeUrl(Uri uri) {
  final host = uri.host.toLowerCase();
  return host.contains('youtube.com') || host.contains('youtu.be');
}

String _normalizeUrl(String href) {
  if (href.startsWith('http://') || href.startsWith('https://')) {
    return href;
  }
  return 'https://$href';
}

// 유튜브 플레이어 다이얼로그 열기
Future<void> _showYouTubeDialog(BuildContext context, String url) async {
  final videoId = YoutubePlayerController.convertUrlToId(url);
  if (videoId == null) return;

  final controller = YoutubePlayerController.fromVideoId(
    videoId: videoId,
    autoPlay: true,
    params: const YoutubePlayerParams(
      showFullscreenButton: true,
    ),
  );

  await showGeneralDialog(
    context: context,
    barrierDismissible: true,          // 바깥 터치하면 닫힘
    barrierLabel: 'YouTube player',
    barrierColor: Colors.transparent,  // ✅ 암전 제거
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (context, anim, secondaryAnim) {
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 960,  // 웹에서 너무 커지지 않게
          ),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(12),
              clipBehavior: Clip.antiAlias,
              child: YoutubePlayer(
                controller: controller,
              ),
            ),
          ),
        ),
      );
    },
  );

  controller.close();
}


/// 라인 안에 있는 유튜브 URL을 "썸네일 이미지를 가진 링크"로 바꿔주는 전처리
String _preprocessYoutubeLinks(String data) {
  // 한 줄 전체가 유튜브 URL인 경우만 대상으로 함
  final reg = RegExp(
    r'^(https?:\/\/(?:www\.)?(?:youtube\.com\/watch\?v=|youtu\.be\/)([A-Za-z0-9_-]{11})).*$',
    multiLine: true,
  );

  return data.replaceAllMapped(reg, (m) {
    final url = m.group(1)!;    // 전체 유튜브 URL
    final id  = m.group(2)!;    // video id
    final thumb = 'https://img.youtube.com/vi/$id/hqdefault.jpg';

    // [![썸네일](thumbURL)](videoURL) 형태로 치환
    return '[![YouTube video]($thumb)]($url)';
  });
}


bool _isYoutubeThumbnail(Uri uri) {
  final host = uri.host.toLowerCase();
  if (!host.contains('img.youtube.com')) return false;
  // 경로 형식: /vi/<videoId>/hqdefault.jpg
  final segments = uri.pathSegments;
  return segments.length >= 3 && segments[0] == 'vi';
}