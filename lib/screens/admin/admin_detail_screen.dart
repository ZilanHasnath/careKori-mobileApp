import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/ui_helpers.dart';

class AdminDetailScreen extends StatefulWidget {
  const AdminDetailScreen({
    super.key,
    required this.title,
    required this.rows,
    required this.onDelete,
    this.onApprove,
    this.extra = const [],
  });

  final String title;
  final List<(String, String)> rows;
  final Future<void> Function() onDelete;
  final Future<void> Function()? onApprove;
  final List<Widget> extra;

  @override
  State<AdminDetailScreen> createState() => _AdminDetailScreenState();
}

class _AdminDetailScreenState extends State<AdminDetailScreen> {
  bool _busy = false;

  Future<void> _run(Future<void> Function() action, String done) async {
    final navigator = Navigator.of(context);
    setState(() => _busy = true);
    try {
      await action();
      if (!mounted) return;
      showMessage(context, done);
      navigator.pop(true);
    } catch (error) {
      if (mounted) {
        setState(() => _busy = false);
        showError(context, error);
      }
    }
  }

  Future<void> _delete() async {
    final ok = await confirm(
      context,
      title: 'Delete',
      message: 'This permanently deletes the record. Continue?',
      confirmLabel: 'Delete',
      destructive: true,
    );
    if (ok) await _run(widget.onDelete, 'Deleted');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SectionCard(
            child: Column(
              children: [for (final row in widget.rows) InfoRow(label: row.$1, value: row.$2)],
            ),
          ),
          for (final extra in widget.extra) ...[const SizedBox(height: 16), extra],
          const SizedBox(height: 24),
          if (widget.onApprove != null) ...[
            FilledButton.icon(
              onPressed: _busy ? null : () => _run(widget.onApprove!, 'Approved'),
              icon: const Icon(Icons.verified_outlined),
              label: const Text('Approve account'),
            ),
            const SizedBox(height: 12),
          ],
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(foregroundColor: AppTheme.danger),
            onPressed: _busy ? null : _delete,
            icon: const Icon(Icons.delete_outline),
            label: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
