import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/dashboard_filters_provider.dart';

/// Quick search by resource name or mobile number.
class ResourceSearchBar extends ConsumerStatefulWidget {
  const ResourceSearchBar({super.key, this.maxWidth});

  final double? maxWidth;

  @override
  ConsumerState<ResourceSearchBar> createState() => _ResourceSearchBarState();
}

class _ResourceSearchBarState extends ConsumerState<ResourceSearchBar> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: ref.read(searchQueryProvider));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasQuery = ref.watch(searchQueryProvider).isNotEmpty;

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: widget.maxWidth ?? 320),
      child: TextField(
        controller: _controller,
        onChanged: (value) => ref.read(searchQueryProvider.notifier).set(value),
        decoration: InputDecoration(
          isDense: true,
          hintText: 'Search by name or mobile number…',
          prefixIcon: const Icon(Icons.search_rounded, size: 20),
          suffixIcon: hasQuery
              ? IconButton(
                  icon: const Icon(Icons.close_rounded, size: 18),
                  onPressed: () {
                    _controller.clear();
                    ref.read(searchQueryProvider.notifier).clear();
                  },
                )
              : null,
        ),
      ),
    );
  }
}
