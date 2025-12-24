import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:nas_blog1/config/config.dart';


class BlogCategory{
  final String id;
  final String name;
  final String slug;

  BlogCategory({
    required this.id,
    required this.name,
    required this.slug
  });

  factory BlogCategory.fromJson(Map<String, dynamic> j) {
    return BlogCategory(
      id: j['id'] as String,
      name: j['name'] as String,
      slug: (j['slug'] ?? j['name']) as String,
    );
  }
}


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

  Future<void> _fetchCategories() async {
    try {
      final res = await http.get(Uri.parse('$NAS_BASE_URL/api/categories'));

      if (res.statusCode == 200) {
        final List<dynamic> list = json.decode(res.body) as List<dynamic>;
        final cats = list
            .map((e) => BlogCategory.fromJson(e as Map<String, dynamic>))
            .toList();

        setState(() {
          _categories = cats;
          if (_categories.isNotEmpty && _selectedCategory == null) {
            _selectedCategory = _categories.first;
          }
        });
      } else {
        setState(() {
          error_msg_ =
              'Failed to load categories: ${res.statusCode} ${res.body}';
        });
      }
    } catch (e) {
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
      final res = await http.post(
        Uri.parse('$NAS_BASE_URL/api/categories'),
        headers: {
          'Content-Type': 'application/json',
          'X-ADMIN-TOKEN': NAS_ADMIN_,
        },
        body: json.encode({'name': name}),
      );

      if (res.statusCode == 200) {
        final Map<String, dynamic> jsonRes =
            json.decode(res.body) as Map<String, dynamic>;
        final cat =
            BlogCategory.fromJson(jsonRes['category'] as Map<String, dynamic>);

        setState(() {
          // 중복 방지
          if (_categories.indexWhere((c) => c.id == cat.id) < 0) {
            _categories.add(cat);
          }
          _selectedCategory = cat;
          error_msg_ = null;
        });
      } else {
        setState(() {
          error_msg_ =
              'Create category failed: ${res.statusCode} ${res.body}';
        });
      }
    } catch (e) {
      setState(() {
        error_msg_ = 'Create category error: $e';
      });
    }
  }

  Future<void> savePost() async {
    setState(() {
      is_saving_ = true;
      error_msg_ = null;
    });

    final payload = {
      "title": title_ctrl_.text,
      "body_markdown": body_ctrl_.text,
      "tags": ["flutter1", "note"], // TODO: 나중에 UI로 변경
      "category": _selectedCategory?.slug,  // ✅ 서버 메타에 기록

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

      if (res.statusCode == 200) {
        if (!mounted) return;
        Navigator.pop(context, true);
      } else {
        setState(() {
          error_msg_ = 'Save failed: ${res.statusCode} ${res.body}';
        });
      }
    } catch (e) {
      setState(() {
        error_msg_ = 'Network error: $e';
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

      final uri = Uri.parse('$NAS_BASE_URL/api/upload');

      final req = http.MultipartRequest('POST', uri)
        ..headers['X-ADMIN-TOKEN'] = NAS_ADMIN_
        ..files.add(
          http.MultipartFile.fromBytes(
            'file',
            bytes,
            filename: file.name,
          ),
        );

      final streamedRes = await req.send();
      final resBody = await streamedRes.stream.bytesToString();

      if (streamedRes.statusCode != 200) {
        setState(() {
          error_msg_ =
              'Upload failed: HTTP ${streamedRes.statusCode} $resBody';
        });
        return;
      }

      final Map<String, dynamic> jsonRes = json.decode(resBody);
      final String relUrl = jsonRes['url'] as String;
      final String fullUrl = '$NAS_BASE_URL$relUrl';

      // 옵션 다이얼로그
      final opt = await showDialog<_ImageInsertOption>(
        context: context,
        builder: (_) => const _ImageOptionDialog(),
      );
      if (opt == null) return;

      const String altBase = 'image';
      final String alt = file.name.isNotEmpty ? file.name : altBase;

      final titleMeta = 'size=${opt.size};align=${opt.align}';
      final insertText = '\n![$alt]($fullUrl "$titleMeta")\n';

      _insertAtCursor(insertText);

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
            onPressed: savePost,
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
            // ✅ 카테고리 선택 영역
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