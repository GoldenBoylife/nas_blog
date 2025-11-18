import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:nas_blog1/pages/editor_pg.dart';
import 'package:nas_blog1/pages/post_detail_pg.dart';
import 'dart:convert';

import '../models/post_meta.dart';
import 'package:nas_blog1/config/config.dart';
class HomePg extends StatefulWidget {
  const HomePg({super.key});
  
  @override
  State<HomePg> createState() => _HomePgState();
}

class _HomePgState extends State<HomePg> {

  late Future<List<PostMeta>> _future_posts;
  Future<List<PostMeta>> fetchPosts() async{

  final res = await http.get(Uri.parse('$NAS_BASE_URL/api/posts'));

  if(res.statusCode != 200) 
  {
    throw Exception('Faied to load posts1111');
  }
  else  
    print("111\n");

  final List<dynamic> data = json.decode(res.body);
  //final : const, only one time input.
  //dynamic : auto, any type,
  return data.map((e) => PostMeta.fromJson(e)).toList();
  //.toList() :  List<PostMeta>
  //data안의 각각 e에 대하여 fromJson를 적용한 결과들을 나열한 스트림.
  //Json -> map

  }
  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _future_posts = fetchPosts();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Posts'),
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