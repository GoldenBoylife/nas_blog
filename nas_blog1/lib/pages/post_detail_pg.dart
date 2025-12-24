import 'dart:convert';  //json

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;



import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:nas_blog1/config/config.dart';
import 'package:nas_blog1/models/post_detail.dart';
import 'package:nas_blog1/utils/markdown/markdown.dart';


class PostDetailPg extends StatefulWidget {
  final String post_id;

  const PostDetailPg({super.key, required this.post_id});
  //get the post_id , and then show the post detail.

  @override
  State<PostDetailPg> createState() => _PostDetailPgState();
}

class _PostDetailPgState extends State<PostDetailPg> {
  // late Future<String> _futurePostContent;
  late Future<PostDetail> _future_post;
  //"_"prefix : private valiable

  @override
  void initState() {
    super.initState();
    // _futurePostContent = fetchPostContent();
    _future_post = _fetchPost();

  }

  /*Init Functions */
  Future<PostDetail> _fetchPost() async{
    final res = await http.get(Uri.parse('$NAS_BASE_URL/api/posts/${widget.post_id}'),  
    //get
  );

  if(res.statusCode != 200) 
  {
    throw Exception('Failed to load post content');
  }
  final Map<String,dynamic> json_data = json.decode(res.body);
  // return res.body; //not markdown. it is "JSON"
  return PostDetail.fromJson(json_data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(title: Text(widget.post_id)),
      body: FutureBuilder<PostDetail>(
        //"Future<T> : it will finish at future
        //"FutureBuilder<PostDetail>:" : waits until  it receives  data from server, and then draw UI widget.
        // async request to server -> depend on builder state -> return widget

        future: _future_post,
        //future : this parameter waits for _future_post value, and then call the builder again depending on the state.
        builder: (context, snapshot) {
          //snapshot  has several state value
          /*loading */
          if(snapshot.connectionState == ConnectionState.waiting) {
           
            return const Center(child: CircularProgressIndicator());
          }
          /*err */
          if(snapshot.hasError || !snapshot.hasData) 
          {
            return Center(
              child: Text('Error loading post\n${snapshot.error}'));

          }
                      print("2222");

          final post = snapshot.data!; // I promise data is never "null" so withdraw it.
          final meta = post.meta;
          // return Markdown(
          //   data: snapshot.data!,
          //   styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
          //     p: const TextStyle(fontSize: 16),
          //     h1: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          //     code: const TextStyle(fontFamily: 'monospace'),
          //    ),
          //   );  //return Markdown()
          return SafeArea(
            child: Center(
              //"child" : it is used in only one child widgets. (ex) SafeArea, Center,SingleChildScrollView
              //"children" : it is used in serveral  
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //Title
                        Text(
                          meta.title,
                          style : Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(fontWeight : FontWeight.bold),
                              // "?." doesn't use ":" at all
                              // If .headlineMedium is true(not null) , call copyWith
                              // otherwise, don't call it 
                        ),
                        const SizedBox(height: 8),
                        //Meta line (date + tags)
                        Row(
                          children: [
                            Text(
                              meta.created_at,
                              style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color : Colors.grey[700]),
                            ),
                            const SizedBox(width: 16),
                        //tags as chips
                        ...meta.tags.map(
                          (tag) => Padding(
                            padding:
                              const EdgeInsets.only(right:4.0),
                            child: Chip(
                              label: Text('#$tag'),
                              visualDensity: VisualDensity.compact,
                              materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            ),
                          )
                        ),

                        // Markdown(
                        //   data: post.body_markdown,
                        //   styleSheet: MarkdownStyleSheet.fromTheme(
                        //     Theme.of(context),
                        //   ).copyWith(
                        //     p: const TextStyle(fontSize: 16, height: 1.6),
                        //     h1: const TextStyle(
                        //       fontSize: 24, fontWeight: FontWeight.bold),
                        //     h2: const TextStyle(
                        //       fontFamily: 'monospace',
                        //       fontSize: 14,
                        //     )
                        //     )    
                        //   )
                          // ,
                        
                      ]  //Row children

                      
                      ),
                    const SizedBox(height: 24),
                    /*CONTENT */
                    BlogMarkdownBody(
                      data: post.body_markdown)
                    ]
                  ),
                  
                  
                ),
                
              )
            )
          ),
          );
          
        }
      )
    );
  }
}