import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../config/config.dart';
import 'package:nas_blog1/config/config.dart';
import 'package:nas_blog1/services/upload_service.dart';
import 'package:nas_blog1/models/blog_category.dart';
import 'package:nas_blog1/services/post_service.dart';
import 'package:nas_blog1/services/category_service.dart';
import 'package:nas_blog1/utils/markdown/markdown_insert.dart';



/// 이미지 삽입 옵션(크기/정렬 정보)
class _ImageInsertOption {
  final String size;   // small, medium, large, full
  final String align;  // left, center, right

  _ImageInsertOption({
    required this.size,
    required this.align,
  });
}

/// 옵션 선택 다이얼로그 (크기/정렬 선택)
class _ImageOptionDialog extends StatefulWidget {
  const _ImageOptionDialog({super.key});

  @override
  State<_ImageOptionDialog> createState() => _ImageOptionDialogState();
}

class _ImageOptionDialogState extends State<_ImageOptionDialog> {
  String _size = 'medium';
  String _align = 'center';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Image option'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Size'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: const Text('Small'),
                selected: _size == 'small',
                onSelected: (_) => setState(() => _size = 'small'),
              ),
              ChoiceChip(
                label: const Text('Medium'),
                selected: _size == 'medium',
                onSelected: (_) => setState(() => _size = 'medium'),
              ),
              ChoiceChip(
                label: const Text('Large'),
                selected: _size == 'large',
                onSelected: (_) => setState(() => _size = 'large'),
              ),
              ChoiceChip(
                label: const Text('Full'),
                selected: _size == 'full',
                onSelected: (_) => setState(() => _size = 'full'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Align'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: const Text('Left'),
                selected: _align == 'left',
                onSelected: (_) => setState(() => _align = 'left'),
              ),
              ChoiceChip(
                label: const Text('Center'),
                selected: _align == 'center',
                onSelected: (_) => setState(() => _align = 'center'),
              ),
              ChoiceChip(
                label: const Text('Right'),
                selected: _align == 'right',
                onSelected: (_) => setState(() => _align = 'right'),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop<_ImageInsertOption>(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(
              context,
              _ImageInsertOption(size: _size, align: _align),
            );
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}



class EditorPg extends StatefulWidget {
  const EditorPg({super.key});

  @override
  State<EditorPg> createState() => _EditorPgState();
}



class _EditorPgState extends State<EditorPg> {
  late final TextEditingController title_ctrl_;
  late final TextEditingController body_ctrl_;

  late bool is_saving_;
  String? error_msg_;
  String? _thumbnail_rel_url; //상대 경로 /assets/uuid.png
  String? _thumbnail_full_url; //미리 보기용 full url 


  List<BlogCategory> _categories = [];
  BlogCategory? _selectedCategory; //현재 선택된 카테고리



  @override
  void initState() {
    super.initState();
    title_ctrl_ = TextEditingController();
    body_ctrl_ = TextEditingController();
    is_saving_ = false;

    _fetchCategories(); //카테고리 로딩

  }

/*funcs */


  Future<void> _fetchCategories() async {
    try {
      // final res = await http.get(Uri.parse('$NAS_BASE_URL/api/categories'));
      final cats = await CategoryService.fetchCategories();


        setState(() {
          _categories = cats;
          if (_categories.isNotEmpty && _selectedCategory == null) {
            _selectedCategory = _categories.first;
          }
          error_msg_ = null;
        });
      } 
    catch (e) {
      setState(() {
        error_msg_ = 'Category load error: $e';
      });
    }
  }


  /*새 카테고리 추가 다이얼로그 */
  Future<void> _addCategoryDialog() async {
    final ctrl = TextEditingController();

    final String? name = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('New category'),
          content: TextField(
            controller: ctrl,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Category name',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, ctrl.text.trim());
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );

    if (name == null || name.isEmpty) return;

    try {
      final cat = await CategoryService.createCategory(name);

        setState(() {
          // 중복 방지
          if (_categories.indexWhere((c) => c.id == cat.id) < 0) {
            _categories.add(cat);
          }
          _selectedCategory = cat;
          error_msg_ = null;
        });
      } 
     catch (e) {
      setState(() {
        error_msg_ = 'Create category error: $e';
      });
    }
  }

  
Future<void> _pickThumbnail() async {
  try {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['png','jpg','jpeg', 'gif'],
      withData:true,
    );
  
    if( result == null) return; //사용자가 취소
    final file = result.files.single;
    final Uint8List? bytes = file.bytes;
    //이미지 데이터는 보통 Uint8List로 다룬다. 

    if(bytes ==null) 
    {
  
      setState(() {
        error_msg_ = "cannot read the thumbnail file! ㅜㅜ";
      });
      return;
    }

    // 1) NAS로 업로드(UploadService 사용) 
    final uploadResult = await UploadService.uploadBytes(
      bytes: bytes, 
      filename: file.name
      );

      setState(() {
        _thumbnail_rel_url = uploadResult.url;
        _thumbnail_full_url = uploadResult.full_url;
        error_msg_ = null;
      });

  } catch(e){
    setState(() {
      error_msg_ = 'Thumbnail upload error: $e';
    });
  }
}


  Future<void> _savePost() async {
    setState(() {
      is_saving_ = true;
      error_msg_ = null;
    });

  //   final payload = {
  //     "title": title_ctrl_.text,
  //     "body_markdown": body_ctrl_.text,
  //     "tags": ["flutter1", "note"], // TODO: 나중에 UI로 변경
  //     "category": _selectedCategory?.slug,  // ✅ 서버 메타에 기록

  //   };

  try {
    if(widget.post_id ==null) {
      await PostService.createPost(
        title: title_ctrl_.text,
        body_markdown: body_ctrl_.text,
        tags: const ['flutter1', 'note'],  // TODO: 나중에 UI로
        category_slug: _selectedCategory?.slug,
        thumbnail_rel_url: _thumbnail_rel_url,
      );
    } else {
      await PostService.updatePost(
        id: widget.post_id!,
        title: title_ctrl_.text,
        body_markdown: body_ctrl_.text,
        category_slug: _selected_category_slug,
        thumbnail_rel_url: _thumbnail_rel_url,
        status: _status,
        tag: const ['flutter1', 'note'],
      )
    }

      if (!mounted) return;
      Navigator.pop(context, true); // 작성 완료 후 이전 화면으로
    } catch (e) {
      setState(() {
        error_msg_ = 'Save failed: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          is_saving_ = false;
        });
      }
    }
  }

  Future<void> _pickAndUploadImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['png', 'jpg', 'jpeg', 'gif', 'mp4', 'mov'],
        withData: true,
      );

      if (result == null) return; // cancel

      final file = result.files.single;
      final Uint8List? bytes = file.bytes;

      if (bytes == null) {
        setState(() {
          error_msg_ = '파일 데이터를 읽을 수 없습니다.';
        });
        return;
      }

      // 1) NAS로 업로드
      final upload_result = await UploadService.uploadBytes(bytes: bytes, filename: file.name);
      final full_url = upload_result.full_url;


      // 2) image option dialogue
      final opt = await showDialog<_ImageInsertOption>(
        context: context,
        builder: (_) => const _ImageOptionDialog(),
        //(_): 함수에서 굳이 인자를 쓰지 않아서 _씀.
        //원래는 context를 인자로 쓰는데, 내부에서 직접 자체 UI를 그리면 굳이 필요 없음. 
        //써야할때는 화면 크기에 따라서 다르게 해야 할 때,

      );
      if(opt == null) return;
      final String alt = file.name.isNotEmpty ? file.name : 'image';
      final title_meta = 'size=${opt.size};align=${opt.align}';

      // 3) insert markdown 
      MarkdownInsert.insertImageMarkdown(
                      controller: body_ctrl_,
                      full_url: full_url,
                      alt:alt,
                      title_meta: title_meta
                      );

      setState(() {
        error_msg_ = null;
      });
    } catch (e) {
      setState(() {
        error_msg_ = 'Upload error: $e';
      });
    }
  }

  void _insertAtCursor(String text) {
    final value = body_ctrl_.value;
    final selection = value.selection;

    if (!selection.isValid) {
      // 커서 정보가 없으면 맨 뒤에 추가
      body_ctrl_.value = value.copyWith(
        text: value.text + text,
        selection:
            TextSelection.collapsed(offset: (value.text + text).length),
      );
      return;
    }

    final newText = value.text.replaceRange(
      selection.start,
      selection.end,
      text,
    );
    final newSelectionPos = selection.start + text.length;

    body_ctrl_.value = value.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newSelectionPos),
    );
  }

  @override
  void dispose() {
    title_ctrl_.dispose();
    body_ctrl_.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final save_btn = is_saving_
        ? const CircularProgressIndicator()
        : ElevatedButton.icon(
            onPressed: _savePost,
            icon: const Icon(Icons.save),
            label: const Text("Save to Nas1"),
          );

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Post'),
        actions: [
          IconButton(
            icon: const Icon(Icons.image),
            tooltip: 'Insert image',
            onPressed: _pickAndUploadImage,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /* 대표 섬네일 영역(새로추가)*/
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade400),
                      color: Colors.grey.shade100,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: _thumbnail_full_url == null
                      ? const Center(
                        child: Text(
                          'No thumnail',
                          style: TextStyle(color: Colors.grey), 
                        ),
                        )
                      : Image.network(
                        _thumbnail_full_url!,
                        fit: BoxFit.cover,
                      )
                  )),
                  const SizedBox(width:8),
                  IconButton(
                    icon: const Icon(Icons.photo),
                    tooltip: 'Pick thumbnail',
                    onPressed:  _pickThumbnail,
                  )
              ]
            ),
            /* 카테고리 선택 영역*/
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<BlogCategory>(
                    value: _selectedCategory,
                    isExpanded: true,
                    items: _categories
                        .map(
                          (c) => DropdownMenuItem<BlogCategory>(
                            value: c,
                            child: Text(c.name),
                          ),
                        )
                        .toList(),
                    onChanged: (cat) {
                      setState(() {
                        _selectedCategory = cat;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.add),
                  tooltip: 'Add category',
                  onPressed: _addCategoryDialog,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ✅ 기존 Title / Body 입력
            TextField(
              controller: title_ctrl_,
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
            if (error_msg_ != null)
              Text(
                error_msg_!,
                style: const TextStyle(color: Colors.red),
              ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: save_btn,
            ),
          ],
        ),
      ),
    );
  }
}