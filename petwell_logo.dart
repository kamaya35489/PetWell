import 'package:flutter/material.dart';
import '../app_colors.dart';

class PetWellLogo extends StatelessWidget {
  final double imageSize;
  final double fontSize;
  final Color textColor;
  const PetWellLogo({
    super.key,
    this.imageSize = 48,
    this.fontSize = 26,
    this.textColor = kNavy,
  });
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Image.asset(
        'assets/images/logo.png',
        width: imageSize,
        height: imageSize,
        fit: BoxFit.contain,
      ),
      SizedBox(width: imageSize * 0.2),
      Text(
        'PetWell',
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w800,
          color: textColor,
          letterSpacing: -0.5,
        ),
      ),
    ],
  );
}
