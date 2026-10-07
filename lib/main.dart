import 'package:flutter/material.dart';

import 'app/app_shell.dart';
import 'theme/lock_in_theme.dart';

void main() => runApp(const LockInApp());

class LockInApp extends StatelessWidget {
  const LockInApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lock In',
      debugShowCheckedModeBanner: false,
      theme: buildLockInTheme(),
      home: const AppShell(),
    );
  }
}

