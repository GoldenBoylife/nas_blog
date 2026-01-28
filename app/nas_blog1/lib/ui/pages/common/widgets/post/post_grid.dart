/*post card 형태로 격자로 배치해주는 위젯 */
//input: posts라는 데이터 벡터 받고 화면 폭에 따라서 열 갯수를 자동으로 정한 뒤에, 
//각 원소를 PostCard라는 랜더링 객체로 마들어 뿌려주는 UI 컴포넌트
import 'package:flutter/material.dart';
import 'package:nas_blog1/models/post_meta.dart';
import 'package:nas_blog1/ui/pages/common/widgets/post/post_card.dart';

class PostGrid extends StatelessWidget {
  final List<PostMeta> posts;
  final void Function(PostMeta post) on_tap;


  final int? cross_axis_count;
  //화면 별 카드 갯수(원하면 밖에서 강제 가능)
  final EdgeInsets padding; //grid padding
  //패딩의 안쪽 여백 얼마나 둘지를 담는 객체

  /*카드 간격 */
  final double cross_axis_spacing;
  final double main_axis_spacing;

  /*카드 높이 (PostCard) 높이 맞추기 */
  final double main_axis_extent;

  const PostGrid({
    super.key,
    required this.posts,
    required this.on_tap,
    this.cross_axis_count,  //열 개수
    this.padding = const EdgeInsets.only(top: 12, bottom:80),
    this.cross_axis_spacing = 16, //열 간격
    this.main_axis_spacing = 16, //행 간격
    this.main_axis_extent = 270, //카드의 세로 높이
    //카드 높이 일정하게 해서 그리드가 깔끔해지도록  
  });

  /*functions */
  /*화면 폭에 따라 열 개수 자동 결정(반응형 레이아웃) */
  int _calc_corss_axis_count(double w) {
    if(cross_axis_count != null) return cross_axis_count!;
    //사용자가 프로퍼티로 열갯수를 지정했으면 그 값대로 진행
    //! : null값이 아님을 보장한다.

    if(w>=1400) return 4;
    if(w>=1100) return 3;
    if(w>=768) return 2;
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    if(posts.isEmpty) {
      return const Center(child: Text('No posts'));
    }
    final w = MediaQuery.of(context).size.width;
    final cross = _calc_corss_axis_count(w);
    //폭값에 따라서 열의 갯수를 정하는 구만. 

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      // padding: padding, //gridview의 패딩 값
      padding: const EdgeInsets.only(top: 12, bottom: 80),

      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cross,
        crossAxisSpacing: cross_axis_spacing,
        mainAxisSpacing: main_axis_spacing,
        mainAxisExtent: main_axis_extent,
      ),
      itemCount : posts.length,
      itemBuilder: (context, index) {
        final p = posts[index];
        return PostCard(
          post: p,
          on_tap:() => on_tap(p),
        );
      }

    );

  }
}