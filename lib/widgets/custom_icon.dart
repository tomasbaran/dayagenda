import 'package:flutter/material.dart';

class CustomIcon extends StatelessWidget {
  final String imagePath;
  final double size;
  final Color color;

  CustomIcon({required this.imagePath, this.size = 24, this.color = Colors.black});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      imagePath,
      width: size,
      height: size,
      color: color,
    );
  }
}
