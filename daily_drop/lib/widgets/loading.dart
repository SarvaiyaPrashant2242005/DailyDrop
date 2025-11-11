import 'package:flutter/material.dart';

class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        ignoring: true,
        child: Container(
          color: Colors.black.withOpacity(0.4),
          child: Center(
            child: Image.asset(
              'assets/images/loader.gif',
              width: 120,
              height: 120,
            ),
          ),
        ),
      ),
    );
  }
}