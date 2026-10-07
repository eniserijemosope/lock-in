import 'package:flutter/material.dart';

import '../theme/lock_in_theme.dart';

class PageHeader extends StatelessWidget {
  final String title;
  final String sub;

  const PageHeader({super.key, required this.title, required this.sub});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(sub, style: dot(11, color: LockInColors.grey)),
            const SizedBox(height: 4),
            Text(title, style: dot(24, weight: FontWeight.w700)),
          ]),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: LockInColors.line),
            ),
            child: const Icon(
              Icons.notifications_none,
              size: 20,
              color: LockInColors.white,
            ),
          ),
        ],
      ),
    );
  }
}
