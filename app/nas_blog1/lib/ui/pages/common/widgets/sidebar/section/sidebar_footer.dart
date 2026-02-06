import 'package:flutter/material.dart';

class SidebarFooter extends StatelessWidget {
  const SidebarFooter({super.key});

  /*
  UI
  padding 
    Container
    - boxDecoration
    Column
      Text
      SizedBox
      Text
      SizedBox
      Text

   */
  @override
  Widget build(BuildContext context) {
    return  Padding(
      padding: const EdgeInsets.all(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.04),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.black.withOpacity(0.06)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children : const [
              Text(
                'Dr.GoldenBoy Lab',
                style: TextStyle(fontWeight: FontWeight.w800),

              ),
              SizedBox(height: 6),
              Text(
              'Robotics • SLAM • Embedded • Maker',
              style: TextStyle(fontSize: 12),

              ),
              SizedBox(height: 6,),
              Text( '@ 2026', style:TextStyle(fontSize: 12))
            ]
          )

          )
        );
  }
}