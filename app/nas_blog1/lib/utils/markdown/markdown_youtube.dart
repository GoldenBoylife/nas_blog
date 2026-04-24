import 'package:flutter/material.dart';

import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:url_launcher/url_launcher.dart';



/// 라인 안에 있는 유튜브 URL을 "썸네일 이미지를 가진 링크"로 바꿔주는 전처리
String preprocessYoutubeLinks(String data) {
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

bool isYouTubeUrl(Uri uri) {
  final host = uri.host.toLowerCase();
  return host.contains('youtube.com') || host.contains('youtu.be');
}

bool isYoutubeThumbnail(Uri uri) {
  final host = uri.host.toLowerCase();
  if (!host.contains('img.youtube.com')) return false;
  // 경로 형식: /vi/<videoId>/hqdefault.jpg
  final segments = uri.pathSegments;
  return segments.length >= 3 && segments[0] == 'vi';
}

String normalizeHref(String href) 
{
  if(href.startsWith('http://') || href.startsWith('https://')) 
  {
    return href;
  }
  return 'https://$href';
}

/*markdown 글 안의 링크를 눌렀을때 처리하는 기능 */
//비동기 함수로  유튜브링크면, 유튜브 다이얼로그로 보여주고 일반 링크면, 외부 브라우저 열림 
Future<void> handleMarkdownLinkTap(
  BuildContext context,
  String href,
) async {
  final url = normalizeHref(href);
  final uri = Uri.parse(url);

  if(isYouTubeUrl(uri)) 
  {
    await showYouTubeDialog(context, url);
    return;
  }
  
  if(await canLaunchUrl(uri))
  {
    await launchUrl(uri,mode: LaunchMode.externalApplication,);
  }
}


// 유튜브 플레이어 다이얼로그 열기
Future<void> showYouTubeDialog(BuildContext context, String url) async {
  final video_id = YoutubePlayerController.convertUrlToId(url);
  if (video_id == null) return;

  final controller = YoutubePlayerController.fromVideoId(
    videoId: video_id,
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
