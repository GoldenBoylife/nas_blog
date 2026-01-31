/*button for image upload */
// lib/utils/markdown/upload_button.dart
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'package:nas_blog1/config/config.dart';
import 'package:nas_blog1/utils/markdown/markdown_upload_service.dart';

class MarkdownUploadButton extends StatefulWidget {
  final TextEditingController controller;

  const MarkdownUploadButton({
    super.key,
    required this.controller,
  });

  @override
  State<MarkdownUploadButton> createState() => _MarkdownUploadButtonState();
}

class _MarkdownUploadButtonState extends State<MarkdownUploadButton> {
  bool _uploading = false;

  Future<void> _pickAndUpload() async {
    setState(() => _uploading = true);

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['png', 'jpg', 'jpeg', 'gif', 'mp4', 'mov'],
        withData: true,
      );

      if (result == null) {
        return;
      }

      final file = result.files.single;
      final Uint8List? bytes = file.bytes;
      if (bytes == null) {
        throw Exception('No file data');
      }

      final relUrl = await MarkdownUploadService.uploadBytes(
        bytes: bytes,
        filename: file.name,
      );
      final fullUrl = '$NAS_BASE_URL$relUrl';

      MarkdownUploadService.insertImageMarkdown(
        controller: widget.controller,
        fullUrl: fullUrl,
        alt: file.name,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _uploading
        ? const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          )
        : IconButton(
            icon: const Icon(Icons.image),
            tooltip: 'Insert image / video',
            onPressed: _pickAndUpload,
          );
  }
}
