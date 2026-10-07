import 'package:flutter/material.dart';

import '../theme/lock_in_theme.dart';

class LockInCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;

  const LockInCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: LockInColors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: LockInColors.line),
      ),
      child: child,
    );
  }
}
