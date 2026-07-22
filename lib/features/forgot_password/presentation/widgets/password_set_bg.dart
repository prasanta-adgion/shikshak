import 'package:Shikshak/core/constants/app_images_const.dart';
import 'package:flutter/material.dart';

class PasswordSetBackground extends StatelessWidget {
  final Widget child;

  const PasswordSetBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Image.asset(
              AppImagesConst.passwordForgotBg,
              fit: BoxFit.fill,
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: child,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
