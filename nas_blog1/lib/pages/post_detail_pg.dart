import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:http/http.dart' as http;
import 'package:nas_blog1/config/config.dart';
class PostDetailPg extends StatefulWidget {
  final String post_id;

  const PostDetailPg({super.key, required this.post_id});

  @override
  State<PostDetailPg> createState() => _PostDetailPgState();
}

class _PostDetailPgState extends State<PostDetailPg> {
  late Future<String> _futurePostContent;

  Future<String> fetchPostContent() async{
    final res = await http.get(Uri.parse('$NAS_BASE_URL/api/posts/${widget.post_id}'),  
  );
  if(res.statusCode != 200) 
  {
    throw Exception('Failed to load post content');
  }
  return res.body;
  }

  @override
  void initState() {
    super.initState();
    _futurePostContent = fetchPostContent();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(title: Text(widget.post_id)),
      body: FutureBuilder<String>(
        future: _futurePostContent,
        builder: (context, snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if(snapshot.hasError || !snapshot.hasData) 
          {
            return const Center(child: Text('Error loading post'));

          }
          return Markdown(
            data: snapshot.data!,
            styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
              p: const TextStyle(fontSize: 16),
              h1: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              code: const TextStyle(fontFamily: 'monospace'),
             ),
            );
            
          
        }
      )
    );
  }
}