import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/list_notifier.dart';
import 'package:http/http.dart' as http; //json
import 'dart:convert'; //?
import 'package:nas_blog1/config/config.dart';

class EditorPg extends StatefulWidget {
  const EditorPg({super.key});

  @override
  State<EditorPg> createState() => _EditorPgState();
}

class _EditorPgState extends State<EditorPg> {
  @override
  late final TextEditingController title_ctrl_ ;
  late final TextEditingController body_ctrl_ ;

  late bool is_saving_;
  String? error_msg_;
  //String? means the field is nullable,and  is automatically set to null.
  //late String? means it isn't initialzed now, but I promise to initialize it later.

  // // depend on my  synology ip,
  //  static late  String nas_url = 'http://192.168.0.4:5050';
  //  static late  String admin_token = 'qwerhh33'; // should be same with  docker run


  @override
  void initState() 
  {
    super.initState();
    title_ctrl_ = TextEditingController();
    body_ctrl_ = TextEditingController();
    is_saving_ = false;

  }


/* Init Functions */
  Future<void> savePost() async{
    setState((){
      is_saving_ = true;
      error_msg_ = null;
    });

    final payload  = {
      "title" : title_ctrl_.text,
      "body_markdown" : body_ctrl_.text,
      "tags": ["flutter", "note"] //나중에 UI로 고친다. 
    };

    try {
      final res = await http.post(
        Uri.parse('$NAS_BASE_URL/api/posts'),
        headers: {
          "Content-Type": "application/json",
          "X-ADMIN-TOKEN": NAS_ADMIN_,
        },
        body: json.encode(payload),
      );
      if(res.statusCode == 200) 
      {
        //success : create file in nas
        if(!mounted) return;
        
        Navigator.pop(context,true);
        //if true ->  sign of new page.

      }else {
        setState(() {
          error_msg_ = 'Save failed: ${res.statusCode} ${res.body}';
        });
      }
    } catch (e) {
      setState(() {
        error_msg_ ='Network error: $e';
      });
    } finally{
      if(mounted) {
        setState(() {
          is_saving_ = false;
        });
      }
    }
  }
  @override
  void dispose() 
  {
    title_ctrl_.dispose();
    body_ctrl_.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final save_btn = is_saving_
      ? const CircularProgressIndicator()
      : ElevatedButton.icon(
        onPressed: savePost,
        icon: const Icon(Icons.save),
        label: const Text("Save to Nas1"),
      );

    return Scaffold(
      appBar: AppBar(title: const Text('New Post')),
      body: Padding(
        padding : const EdgeInsets.all(16),
        child: Column(
          children : [
            TextField(
              controller : title_ctrl_,
              decoration: const InputDecoration(
                labelText: "Title",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: TextField(
                controller: body_ctrl_,
                maxLines: null,
                expands: true,
                keyboardType: TextInputType.multiline,
                decoration: const InputDecoration(
                  alignLabelWithHint: true,
                  labelText: "Markdown content",
                  hintText: "# Heading\nYour content here ...",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 12),
            //if Error msg exists
            if(error_msg_ !=null)
              Text(
                error_msg_!,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child:save_btn
              )
              


          ]
        )
      )

      
    );
  }
}