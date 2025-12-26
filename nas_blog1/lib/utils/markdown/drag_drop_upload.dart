// lib/utils/markdown/drag_drop_upload.dart
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';

import 'package:nas_blog1/config/config.dart';
import 'package:nas_blog1/services/upload_service.dart';
import 'package:nas_blog1/utils/markdown/markdown_insert.dart';
import 'package:nas_blog1/utils/markdown/markdown_upload_service.dart';

class DragDropUpload extends StatefulWidget {
  final TextEditingController controller;
  final Widget child;

  const DragDropUpload({
    super.key,
    required this.controller,
    required this.child,
  });

  @override
  State<DragDropUpload> createState() => _DragDropUploadState();
}

class _DragDropUploadState extends State<DragDropUpload> {
  DropzoneViewController? _dzCtrl;
  bool _highlight = false;
  bool _uploading = false;
  String? _error;

  Future<void> _handleDrop(dynamic event) async {
    if (_dzCtrl == null) return;

    setState(() {
      _highlight = false;
      _uploading = true;
      _error = null;
    });

    try {
      final name = await _dzCtrl!.getFilename(event);
      final Uint8List bytes = await _dzCtrl!.getFileData(event);

      // 1) 업로드
      final relUrl = await UploadService.uploadBytes(
        bytes: bytes,
        filename: name,
      );
      final full_url = '$NAS_BASE_URL$relUrl';

      // 2) 마크다운 삽입
      MarkdownInsert.insertImageMarkdown(
        controller: widget.controller,
        full_url: full_url,
        alt: name,
      );
    } catch (e) {
      setState(() => _error = 'Upload failed: $e');
    } finally {
      if (mounted) {
        setState(() => _uploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 웹이 아니면 그냥 child만 리턴 (드래그드롭은 의미 없음)
    if (!kIsWeb) {
      return widget.child;
    }

    return Stack(
      children: [
        widget.child,

        // 드래그 시 하이라이트
        Positioned.fill(
          child: IgnorePointer(
            ignoring: true,
            child: AnimatedOpacity(
              opacity: _highlight ? 0.12 : 0.0,
              duration: const Duration(milliseconds: 120),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue,
                  border: Border.all(color: Colors.blueAccent, width: 2),
                ),
              ),
            ),
          ),
        ),

        // Dropzone
        Positioned.fill(
          child: DropzoneView(
            onCreated: (c) => _dzCtrl = c,
            operation: DragOperation.copy,
            onHover: () => setState(() => _highlight = true),
            onLeave: () => setState(() => _highlight = false),
            onDrop: _handleDrop,
          ),
        ),

        if (_uploading)
          const Positioned(
            right: 8,
            bottom: 8,
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Text('Uploading...'),
              ),
            ),
          ),

        if (_error != null)
          Positioned(
            right: 8,
            bottom: 8,
            child: Card(
              color: Colors.redAccent,
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Text(
                  'Error',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
