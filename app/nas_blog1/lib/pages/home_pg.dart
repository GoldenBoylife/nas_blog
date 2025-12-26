import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:nas_blog1/pages/editor_pg.dart';
import 'package:nas_blog1/pages/post_detail_pg.dart';
import 'dart:convert';

import '../models/post_meta.dart';
// import 'package:nas_blog1/config/config.dart';
import '../services/post_service.dart';

class HomePg extends StatefulWidget {
  //StatefulWidget: 시간과 상태가 필요한 화면  상태에 따라 : 로딩중UI, 리스트UI, 애러 UI 
  const HomePg({super.key});
  
  @override
  State<HomePg> createState() => _HomePgState();
}

class _HomePgState extends State<HomePg> {

  late Future<List<PostMeta>> _future_posts;
  //late : 당장 값이 없긴한데, 나중에 넣을거야. 
  
  @override
  void initState() {
    // TODO: implement initState
    //initState () :  위젯이 화면에 붙을 때 딱 한번 실행되는 초기화 훅, 서버 요청 시작함.
    super.initState();
    _future_posts = PostService.fetchPosts(); // 서비스 호출
    //즉시 결과(List)를 주는 게 아니라 Future를 준다. 

  }

  @override
  Widget build(BuildContext context) {
    //build : 현재 상태로 UI를 그리는 함수
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Post list'),
      ),
      body: FutureBuilder<List<PostMeta>>(
        //FutureBuilder<List<PostMeta>> : 나중에 완료될 비동기 작업
        //언제 끝날지 모르지만 나중에 List<PostMeta>를 줄게 라는 약속대로 UI구성
        future: _future_posts,
        builder: (context, snapshot) {
          //snapshot: 현재의 future 상태를 묶어서 넘겨줌
          /*로딩 시 UI */
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          /*실패시 UI */
          if(snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text('Error loading posts'));
          }
          final posts = snapshot.data!;
          //! : snapshot.data의 타입이 nullable은 절대 아니야 
          /*data 없음 */
          if (posts.isEmpty) {
            return const Center(child : Text ('No posts yet'));
          }
          return ListView.separated(
            itemCount: posts.length,
            separatorBuilder: (_,__) => const Divider(height: 1),
            itemBuilder: (context,index) {
              final p = posts[index];
              return ListTile(
                title: Text(p.title),
                subtitle: Text(p.created_at),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PostDetailPg(
                        post_id: p.id),
                    )
                  );
                }
              );
            }
          );
        }
        
      ), //FutureBuilder
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const EditorPg()),
            );
        }, 
        icon: const Icon(Icons.add),
        label: const Text("Add"),
        )
      );
    
  }
}