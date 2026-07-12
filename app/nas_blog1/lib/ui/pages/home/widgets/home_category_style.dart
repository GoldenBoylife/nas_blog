import 'package:flutter/material.dart';
import 'package:nas_blog1/models/post_meta.dart';

class HomeCategoryStyle {
  final String label;
  final Color bg_color;
  final Color text_color;
  final Color border_color;

  const HomeCategoryStyle({
    required this.label,
    required this.bg_color,
    required this.text_color,
    required this.border_color,
  });
}

HomeCategoryStyle resolveHomeCategoryStyle(PostMeta post) {
  final source = [
    post.category ?? '',
    post.title,
    ...post.tags,
  ].join(' ').toLowerCase();

  if (_containsAny(source, [
    'slam',
    'mapping',
    'mapping-algorithms',
    'localization',
    'lidar',
    'imu',
    'ekf',
    'eskf',
    'iekf',
    'fast-lio',
    'goldenslam',
    'point cloud',
    'plane residual',
    'scan-to-map',
    'ikd-tree',
  ])) {
    return const HomeCategoryStyle(
      label: 'SLAM',
      bg_color: Color(0xFF6D28D9),
      text_color: Colors.white,
      border_color: Color(0xFF5B21B6),
    );
  }

  if (_containsAny(source, [
    'petbot',
    'gb-02-pet-robot',
    'pet robot',
    'zbrush',
    'fusion',
    'fusion360',
    'cad',
    '3d',
    'hardware',
    'electronics',
    'printing',
    '프린팅',
  ])) {
    return const HomeCategoryStyle(
      label: 'PetBot',
      bg_color: Color(0xFF15803D),
      text_color: Colors.white,
      border_color: Color(0xFF166534),
    );
  }

  if (_containsAny(source, [
    'vscode',
    'github',
    'programming',
    'dev',
    'flutter',
    'dart',
    'markdown',
    'synology',
    'nas',
  ])) {
    return const HomeCategoryStyle(
      label: 'Dev',
      bg_color: Color(0xFF2563EB),
      text_color: Colors.white,
      border_color: Color(0xFF1D4ED8),
    );
  }

    return const HomeCategoryStyle(
      label: 'Post',
      bg_color: Color(0xFFEA580C),
      text_color: Colors.white,
      border_color: Color(0xFFC2410C),
    );
}

bool _containsAny(String source, List<String> keywords) {
  for (final keyword in keywords) {
    if (source.contains(keyword.toLowerCase())) {
      return true;
    }
  }
  return false;
}