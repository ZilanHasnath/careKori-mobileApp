import 'package:flutter/material.dart';

import 'async_body.dart';
import 'state_views.dart';

class RefreshableList extends StatelessWidget {
  const RefreshableList({
    super.key,
    required this.onRefresh,
    required this.children,
    this.emptyIcon = Icons.inbox_outlined,
    this.emptyMessage = 'Nothing here yet',
    this.header,
    this.padding = const EdgeInsets.all(16),
  });

  final Reload onRefresh;
  final List<Widget> children;
  final IconData emptyIcon;
  final String emptyMessage;
  final Widget? header;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final body = children.isEmpty
        ? [
            SizedBox(
              height: 360,
              child: EmptyState(icon: emptyIcon, message: emptyMessage),
            ),
          ]
        : [
            for (var i = 0; i < children.length; i++) ...[
              if (i > 0) const SizedBox(height: 12),
              children[i],
            ],
          ];

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: padding,
        children: [
          if (header != null) ...[header!, const SizedBox(height: 12)],
          ...body,
        ],
      ),
    );
  }
}
