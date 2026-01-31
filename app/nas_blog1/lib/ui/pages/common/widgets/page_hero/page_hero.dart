/*hero쪽은 서버나 저장소에서데이터를 가져오기(fetch) 하지 않는다.  */
// 바로 assets쪽에 잇는 gif쓴다. 

import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:nas_blog1/models/screen_model.dart';

import 'package:nas_blog1/constants/asset_path.dart';
import 'package:nas_blog1/ui/pages/common/theme/text_util.dart';



class PageHero extends StatelessWidget {
    final ScreenModel screen_model;

    final String title;
    final String sub_title;
    final List<String> words;

  const PageHero({
    super.key,
    required this.screen_model,
    this.title = "Dr.GoldenBoy Lab",
    this.sub_title = "you can be",
    this.words = const ['designer', 'engineer', 'programmer'],    
    });

/*functions*/
    double _height() {
        if(screen_model.web) return 520;
        if(screen_model.tablet) return 360;
        return 260;
    }
    double _titleSize() {
        if(screen_model.web) return 52;
        if(screen_model.tablet) return 38;
        return 26;
    }
    double _subSize() {
        if(screen_model.web) return 22;
        if(screen_model.tablet) return 18;
        return 16;
    }

    double _typingSize() {
        if(screen_model.web) return 44;
        if(screen_model.tablet) return 30;
        return 24;
    }

  @override
  Widget build(BuildContext context) {
    final h = _height();

    return ClipRRect(
        borderRadius : BorderRadius.circular(18),
        child: SizedBox(
            height: h,
            width: double.infinity,
            child: Stack(
                fit : StackFit.expand,
                children: [
                    // arc reactor gif (asset)
                    Image.asset(
                        AssetPath.arc_reactor_gif,
                        fit: BoxFit.cover,
                        gaplessPlayback: true,
                    ),
                    /*  가독성용 오버레이*/
                    //반투명 그라데이션 오버레이를 깔아서 글자/아이콘 더 잘 보이게,
                    
                    const DecoratedBox(
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                    Color(0xAA000000),
                                    Color(0x55000000),
                                    Color(0xAA000000),
                                ]
                            )
                        ),
                    ), 
                    Center(
                        child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 18),
                            child: ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 980),
                                child: Column(
                                    mainAxisAlignment:  MainAxisAlignment.center,
                                    children: [
                                        Text(
                                            title,
                                            textAlign: TextAlign.center,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: _titleSize(),
                                                fontWeight: FontWeight.w800,
                                                letterSpacing : -0.5,
                                            )

                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                            sub_title,
                                            textAlign: TextAlign.center,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                color: Colors.white.withOpacity(0.92),
                                                fontSize: _subSize(),
                                                fontWeight: FontWeight.w500,
                                            )),
                                            const SizedBox(height:16),
                                            DefaultTextStyle(
                                                style: TextStyle(
                                                    fontSize: _typingSize(),
                                                    fontWeight: FontWeight.w400,
                                                    color: Colors.amber,
                                                ),
                                                child: AnimatedTextKit(
                                                    repeatForever: true,
                                                    pause: const Duration(milliseconds: 900),
                                                    animatedTexts: words
                                                        .map(
                                                            (w) => TypewriterAnimatedText(
                                                                w, 
                                                                speed: const Duration(milliseconds: 110),
                                                                // cursor: '_',
                                                            ),
                                                        ).toList(),
                                                )

                                            )
                                    ]
                                ) )
                        )
                    )
                ]
            )
        )
    );
    
  }
}
