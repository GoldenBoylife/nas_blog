/*this class is responsible only for Purely managing category HTTP, like "PostService" */
/*
func
  1. req http 
  2. parsing JSON
  3. 인증 header

 */
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/config.dart';
import '../models/blog_category.dart';


class CategoryService {

  const CategoryService._(); //전부 static라서 인스턴스 막기.

  /*get category list */
  static Future<List<BlogCategory>> fetchCategories() async{
    final res = await http.get(
      Uri.parse('$NAS_BASE_URL/api/categories'),
    );


    if(res.statusCode != 200) 
    {
      throw Exception(
        'Failed to load Categories (status : ${res.statusCode}) ${res.body}', 
      );
    }

    final List<dynamic> list = json.decode(res.body) as List<dynamic>;
    return list
            .map((e)=> BlogCategory.fromJson(e as Map<String,dynamic>))
            .toList();
  }

  /*카테고리 새로 만들기 */
  // - parent_id가 있으면 sub category로 생성됨
  // - null이면 최상위 카테고리
   static Future<BlogCategory> createCategory(String name,String parent_id) async {

    final trimmed = name.trim();
    if(trimmed.isEmpty) {
      throw Exception('Category name is empty');
    }

    final Map<String, dynamic> payload = {'name' : trimmed};

      payload['parent_id'] = parent_id; 

    final res = await http.post(
      Uri.parse('$NAS_BASE_URL/api/categories'),
      headers: {
        'Content-Type': 'application/json',
        'X-ADMIN-TOKEN': NAS_ADMIN_,
      },
      body: json.encode(payload),
    );


    if(res.statusCode !=200) 
    {
      throw Exception(
        'Failed to create category (status: ${res.statusCode}) ${res.body}',
      );
    }

    //형식:  { ok : true, category: {...}, existed: bool? }
    final Map<String, dynamic> data = json.decode(res.body) as Map<String,dynamic>;

    return BlogCategory.fromJson(
      data['category'] as Map<String, dynamic>,
    );
   }
}
