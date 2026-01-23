/*posts GET / POST */
/*
기능:
  글목록 불러오기, 글 하나 상세 불러오기, 새글 저장하기
  Post관련 http 통신만 담당 (UI와 파싱은 안함)
  communication with server to get JSON and then return converted model.


*/

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nas_blog1/config/config.dart'; 

import 'package:nas_blog1/models/post_detail.dart';
import 'package:nas_blog1/models/post_meta.dart';
import 'package:nas_blog1/models/post_status.dart';






class PostService{
  const PostService._(); 
  //private construction ->  all method is "static"


  //call post list
  // static Future<List<PostMeta>> fetchPosts();
  /*funcs*/
  static Future<List<PostMeta>> fetchPosts() async 
  {
  //static : 외부에서 쓰더라도 객체 없이 쓰게 만듬. c++에서도 마찬가지 개념
  //Future<T> : 지금 당장은 <T>없고, 나중에 완료되면 그걸 주는 약속(핸들)
  //async : 비동기함수됨. 내부에서 await쓸수 있고, 자동으로 결과가 Future<T>로 감싸져서 반환됨. 


    final res = await http.get(
        Uri.parse('$NAS_BASE_URL/api/posts')
      );
    //await : Future가 끝날 때까지 기다렸다가 결과를 꺼냄.
    // http.get()은 바로 결과가 안오니까 일단 Future<http.Response>를 반환합니다. 그리고 await로 기다렸다가 res에 응답을 넣음.


    /*call fail*/
    if (res.statusCode != 200) {
      throw Exception('Failed to load posts (status: ${res.statusCode})');
    }

    final List<dynamic> data = json.decode(res.body) as List<dynamic>;
    //final : const같은 거고 재할당 금지임, 즉 data변수에 다른 값을 다시 못 넣음. 
    //dynamic : void같은 아무타입이나 들어올 수 잇는 타입이다. 
    //json.decode(res.body) : 결과는 dynamic이다. 
    //as List<dynamic> : 이거 List로 취급할거임(캐스팅)
      return data
              .map((e) => PostMeta.fromJson(e as Map<String, dynamic>))
              .toList();
      //JSON배열 안의 각 원소이고 dynamic타입인 e를 Map<String, dynamic>타입일거라고 가정하고 캐스팅한다 
      //PostMeta.fromJson(...): 그 Map을 PostMeta로 변환해서 새 List<PostMeta>를 만들어 리턴하는 코드 
      //.toList() : 그 Iterable을 진짜 List로 만들어줌.
  }

  //call post detail
  // static Future<PostDetail> fetchPost(String id);
  //private로 한이유: 외부에 공개할 API 제한하려고, 
  static Future<PostDetail> fetchPost(String id) async
  {
    final res = await http.get(Uri.parse('$NAS_BASE_URL/api/posts/$id'),  
      //get
    );

    if(res.statusCode != 200) 
    {
      throw Exception('Failed to load post content (status: ${res.statusCode})');
    }

    final Map<String,dynamic> json_data = json.decode(res.body) as Map<String, dynamic>;
    //왜 여기선 Map?  postDetail은 보통 Json이 {...} 객체 형태니까. 
  
    return PostDetail.fromJson(json_data);
  }

  //create new post
  static Future<PostMeta> createPost({
    required String title,
    //required : 반드시넣어야 하는 parameter
    required String body_markdown,
    required List<String> tags,
    String? category_slug,
    //? nullable 타입, String또는 null일수도 있다.
    //여기에다가 thumnail추가하기.
    String? thumbnail_rel_url, //서버쪽에다가는 상대경로만 보낼 것\

    PostStatus? status,
  }) async{
    //서버로 보낼 JSON payload
    final payload = <String, dynamic> {
      'title': title,
      'body_markdown' : body_markdown,
      'tags': tags,
      if( category_slug != null) 'category': category_slug,
      if( thumbnail_rel_url !=null) 'thumbnail': thumbnail_rel_url,
      if(status != null) 'status': status.value
      //이 함수 쓰인 곳에서 status값을 넣었으면 null아닐것임. 그값을 payload 문자열에 적용해줌.
    };

    final res = await http.post(
      Uri.parse('$NAS_BASE_URL/api/posts'),
      headers: {
        'Content-Type': 'application/json',
        'X-ADMIN-TOKEN': NAS_ADMIN_, //관리자 토큰
      },
      body: json.encode(payload),
      );


    if (res.statusCode != 200) {
      throw Exception(
        'Failed to load posts (status : ${res.statusCode}) ${res.body}',
      );
    }

    /*{ ok: true, post:{...} 형태 */
    final Map<String,dynamic> data = json.decode(res.body) as Map<String, dynamic>;
    //Map<String,dynamic>  : 이 형식으로 파싱함.  왜나하면,  {...} 형식이니까.

    final Map<String,dynamic> meta_json = data['post'] as Map<String, dynamic>;
    return PostMeta.fromJson(meta_json);
    
  }
  

}