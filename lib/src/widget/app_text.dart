import 'package:flutter/material.dart';

class AppText extends StatelessWidget {
  final String data;
  final double size;
  final Color color;
  final FontWeight? weight;
  final TextOverflow? overflow;
  final double? height;
  final int? maxLines;
  final TextDecoration? decoration;
  final TextAlign? textAlign;

  const AppText(
    this.data, {
    this.size = 18,
    this.color = Colors.black,
    this.weight,
    this.overflow,
    this.height,
    this.maxLines,
    this.decoration,
    this.textAlign,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      data,
      maxLines: maxLines,
      textAlign: textAlign,
      style: TextStyle(
        fontSize: size,
        color: color,
        fontWeight: weight,
        height: height,
        overflow: overflow,
        decoration: decoration,
      ),
    );
  }
}
