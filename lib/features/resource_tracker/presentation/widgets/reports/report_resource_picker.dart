import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/resource.dart';
import '../../providers/reports_provider.dart';
import '../../providers/resource_list_provider.dart';
import '../resource_list/resource_avatar.dart';

/// Search-to-select control that drills the Reports screen into one
/// resource's history, or clears back to the all-resources aggregate view.
/// Typing filters by name or mobile number; each option in the open list
/// shows the person's avatar, name and mobile number.
class ReportResourcePicker extends ConsumerStatefulWidget {
  const ReportResourcePicker({super.key, this.width});

  final double? width;

  @override
  ConsumerState<ReportResourcePicker> createState() => _ReportResourcePickerState();
}

class _ReportResourcePickerState extends ConsumerState<ReportResourcePicker> {
  static final ButtonStyle _entryStyle = MenuItemButton.styleFrom(
    minimumSize: const Size(double.infinity, 56),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    alignment: Alignment.centerLeft,
  );

  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode()
      ..addListener(() {
        // Selecting all on focus means typing immediately replaces the
        // current value/hint instead of appending after it.
        if (_focusNode.hasFocus) {
          _controller.selection = TextSelection(baseOffset: 0, extentOffset: _controller.text.length);
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final resources = ref.watch(dailyResourcesProvider);
    final selectedId = ref.watch(selectedReportResourceIdProvider);

    final sorted = [...resources]..sort((a, b) => a.name.compareTo(b.name));
    final byId = {for (final resource in sorted) resource.id: resource};

    return DropdownMenu<String?>(
      key: ValueKey(selectedId),
      controller: _controller,
      focusNode: _focusNode,
      width: widget.width,
      menuHeight: 360,
      initialSelection: selectedId,
      enableFilter: true,
      leadingIcon: const Icon(Icons.search_rounded, size: 20),
      hintText: 'Search resources…',
      inputDecorationTheme: InputDecorationTheme(
        isDense: true,
        filled: true,
        fillColor: theme.inputDecorationTheme.fillColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: theme.dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: theme.dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF6366F1), width: 1.5),
        ),
      ),
      menuStyle: MenuStyle(
        shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
      ),
      filterCallback: (entries, filter) {
        final query = filter.trim().toLowerCase();
        if (query.isEmpty) return entries;
        final digits = query.replaceAll(RegExp(r'\D'), '');

        return entries.where((entry) {
          if (entry.value == null) return 'all resources'.contains(query);
          final resource = byId[entry.value];
          if (resource == null) return false;
          final matchesName = resource.name.toLowerCase().contains(query);
          final matchesMobile = digits.isNotEmpty && resource.mobileNumber.contains(digits);
          return matchesName || matchesMobile;
        }).toList();
      },
      onSelected: (value) => ref.read(selectedReportResourceIdProvider.notifier).set(value),
      dropdownMenuEntries: [
        DropdownMenuEntry(
          value: null,
          label: 'All Resources',
          labelWidget: const _OptionRow(resource: null),
          style: _entryStyle,
        ),
        for (final resource in sorted)
          DropdownMenuEntry(
            value: resource.id,
            label: resource.name,
            labelWidget: _OptionRow(resource: resource),
            style: _entryStyle,
          ),
      ],
    );
  }
}

class _OptionRow extends StatelessWidget {
  const _OptionRow({required this.resource});

  final Resource? resource;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.55);

    if (resource == null) {
      return Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.12),
            child: Icon(Icons.groups_rounded, size: 17, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: 12),
          const Text('All Resources', style: TextStyle(fontWeight: FontWeight.w600)),
        ],
      );
    }

    return Row(
      children: [
        ResourceAvatar(resource: resource!, radius: 16),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(resource!.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14), overflow: TextOverflow.ellipsis),
              Text(resource!.mobileNumber, style: TextStyle(fontSize: 12, color: muted)),
            ],
          ),
        ),
      ],
    );
  }
}
