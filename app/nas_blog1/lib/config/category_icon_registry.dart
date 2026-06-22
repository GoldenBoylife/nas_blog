import 'package:flutter/material.dart';

class  CategoryIconRegistry {
  CategoryIconRegistry._();

  static const String default_key = 'folder';

  /*key -> icon */
  static const Map<String, IconData> _map = {
    'folder': Icons.folder_outlined,
    'portfolio': Icons.badge_outlined,
    'slam': Icons.explore_outlined,
    'paper': Icons.article_outlined,
    'robot': Icons.smart_toy_outlined,
    'system': Icons.account_tree_outlined,
    'path': Icons.alt_route_outlined,
    'vision': Icons.visibility_outlined,
    'chip': Icons.memory_outlined,
    'circuit': Icons.developer_board_outlined,
    'cube': Icons.view_in_ar_outlined,
    'print': Icons.print_outlined,
    'tool': Icons.build_outlined,
    'code': Icons.code_outlined,
    'book': Icons.menu_book_outlined,
    'data': Icons.storage_outlined,
    'devops': Icons.hub_outlined,
    'travel': Icons.flight_outlined,
    'car': Icons.directions_car_outlined,
    'daily': Icons.today_outlined,
    'sensor' : Icons.sensors_outlined,
    'programming' : Icons.code_outlined,
    'knowledge' : Icons.menu_book_outlined,
  };


  static IconData iconFromKey(String? key) {
    return _map[key] ?? _map[default_key]!;
    
  }

  static List<String> get keys => _map.keys.toList(growable: false);
  //dialog에서 보여줄 후보 목록

}