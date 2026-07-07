import 'package:flutter/material.dart';

/// The official Aligo wordmark (ALIGO + arrow), used on the login and
/// language-picker screens.
class AligoLogo extends StatelessWidget {
  final double size;

  const AligoLogo({super.key, this.size = 220});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/branding/aligo_wordmark.png',
      width: size,
      fit: BoxFit.contain,
    );
  }
}
