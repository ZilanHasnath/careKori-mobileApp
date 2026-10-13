import 'package:flutter/material.dart';

import '../core/network/api_exception.dart';
import 'care_loader.dart';
import 'state_views.dart';

typedef Reload = Future<void> Function();

class AsyncBody<T> extends StatefulWidget {
  const AsyncBody({super.key, required this.load, required this.builder});

  final Future<T> Function() load;
  final Widget Function(BuildContext context, T data, Reload reload) builder;

  @override
  State<AsyncBody<T>> createState() => _AsyncBodyState<T>();
}

class _AsyncBodyState<T> extends State<AsyncBody<T>> {
  late Future<T> _future = widget.load();

  Future<void> _reload() async {
    final next = widget.load();
    setState(() => _future = next);
    try {
      await next;
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const CareLoader();
        }
        if (snapshot.hasError) {
          return ErrorState(message: errorMessage(snapshot.error!), onRetry: _reload);
        }
        return widget.builder(context, snapshot.requireData, _reload);
      },
    );
  }
}
