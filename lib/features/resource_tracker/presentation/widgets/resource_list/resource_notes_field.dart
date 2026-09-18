import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/resource.dart';
import '../../providers/resource_list_provider.dart';

/// Tap-to-expand text field for pasting a WhatsApp-style status update.
/// Reads as plain text until tapped, then becomes an editable field.
class ResourceNotesField extends ConsumerStatefulWidget {
  const ResourceNotesField({super.key, required this.resource, this.maxLines = 2});

  final Resource resource;
  final int maxLines;

  @override
  ConsumerState<ResourceNotesField> createState() => _ResourceNotesFieldState();
}

class _ResourceNotesFieldState extends ConsumerState<ResourceNotesField> {
  late final TextEditingController _controller;
  bool _editing = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.resource.notes);
  }

  @override
  void didUpdateWidget(covariant ResourceNotesField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_editing && widget.resource.notes != _controller.text) {
      _controller.text = widget.resource.notes;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    ref.read(resourceListProvider.notifier).updateNotes(widget.resource.id, _controller.text.trim());
    setState(() => _editing = false);
  }

  void _cancel() {
    _controller.text = widget.resource.notes;
    setState(() => _editing = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.5);

    if (_editing) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              autofocus: true,
              minLines: 1,
              maxLines: 4,
              style: const TextStyle(fontSize: 13),
              decoration: const InputDecoration(
                isDense: true,
                hintText: 'Paste WhatsApp update…',
                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              ),
              onSubmitted: (_) => _save(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.check_rounded, size: 18),
            color: theme.colorScheme.primary,
            tooltip: 'Save note',
            onPressed: _save,
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded, size: 18),
            color: muted,
            tooltip: 'Cancel',
            onPressed: _cancel,
          ),
        ],
      );
    }

    final hasNotes = widget.resource.notes.trim().isNotEmpty;
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => setState(() => _editing = true),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                hasNotes ? widget.resource.notes : 'Add note…',
                maxLines: widget.maxLines,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  color: hasNotes ? theme.colorScheme.onSurface.withValues(alpha: 0.8) : muted,
                  fontStyle: hasNotes ? FontStyle.normal : FontStyle.italic,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.edit_note_rounded, size: 16, color: muted),
          ],
        ),
      ),
    );
  }
}
