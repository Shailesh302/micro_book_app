// lib/widgets/app_footer.dart

import 'package:flutter/material.dart';

class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).cardTheme.color?.withAlpha(150),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: const Text(
        'Made with ❤️ by Shailesh',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w200),
      ),
    );
  }
}