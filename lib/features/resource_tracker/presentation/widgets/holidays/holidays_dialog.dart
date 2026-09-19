import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../../core/utils/date_formatter.dart';
import '../../../domain/entities/holiday.dart';
import '../../providers/dashboard_filters_provider.dart';
import '../../providers/holidays_provider.dart';

/// Add and remove holidays. Sundays and the 2nd/4th Saturdays are already
/// weekly offs, so only extra days off need to be added here.
class HolidaysDialog extends ConsumerStatefulWidget {
  const HolidaysDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(context: context, builder: (_) => const HolidaysDialog());
  }

  @override
  ConsumerState<HolidaysDialog> createState() => _HolidaysDialogState();
}

class _HolidaysDialogState extends ConsumerState<HolidaysDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  late DateTime _date;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _date = ref.read(selectedDateProvider);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 2, 12, 31),
    );
    if (picked != null) {
      setState(() => _date = AppDateFormatter.dateOnly(picked));
      _formKey.currentState?.validate();
    }
  }

  bool _isTaken(DateTime date) {
    final holidays = ref.read(holidaysProvider).value ?? const <Holiday>[];
    return holidays.any((holiday) => AppDateFormatter.isSameDay(holiday.date, date));
  }

  Future<void> _add() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    await ref.read(holidaysProvider.notifier).addHoliday(date: _date, name: _nameController.text.trim());
    if (!mounted) return;
    _nameController.clear();
    setState(() => _submitting = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.6);
    final holidays = ref.watch(holidaysProvider).value ?? const <Holiday>[];
    final today = AppDateFormatter.dateOnly(DateTime.now());
    final upcoming = holidays.where((h) => !h.date.isBefore(today)).toList();
    final past = holidays.where((h) => h.date.isBefore(today)).toList().reversed.toList();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 480,
          maxHeight: MediaQuery.sizeOf(context).height * 0.85,
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text('Holidays', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              Text(
                'Sundays and the 2nd & 4th Saturdays are already off. Add any other days off here — '
                'they are skipped on the dashboard and left out of reports.',
                style: theme.textTheme.bodySmall?.copyWith(color: muted),
              ),
              const SizedBox(height: 16),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    FormField<DateTime>(
                      validator: (_) => _isTaken(_date) ? 'A holiday is already set for this date' : null,
                      builder: (state) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          OutlinedButton.icon(
                            onPressed: _pickDate,
                            icon: const Icon(Icons.calendar_month_rounded, size: 18),
                            label: Text(DateFormat('EEE, MMM d, y').format(_date)),
                            style: OutlinedButton.styleFrom(alignment: Alignment.centerLeft),
                          ),
                          if (state.hasError)
                            Padding(
                              padding: const EdgeInsets.only(top: 6, left: 4),
                              child: Text(
                                state.errorText!,
                                style: TextStyle(color: theme.colorScheme.error, fontSize: 12),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(labelText: 'Holiday name'),
                            validator: (value) => (value == null || value.trim().isEmpty) ? 'Name is required' : null,
                            onFieldSubmitted: (_) => _add(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _submitting ? null : _add,
                          child: const Text('Add'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Divider(height: 1),
              Flexible(
                child: holidays.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: Center(child: Text('No holidays added yet', style: TextStyle(color: muted))),
                      )
                    : ListView(
                        shrinkWrap: true,
                        children: [
                          if (upcoming.isNotEmpty) ...[
                            _SectionLabel('Upcoming'),
                            for (final holiday in upcoming) _HolidayRow(holiday: holiday),
                          ],
                          if (past.isNotEmpty) ...[
                            _SectionLabel('Past'),
                            for (final holiday in past) _HolidayRow(holiday: holiday, dimmed: true),
                          ],
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 4),
      child: Text(
        text.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
      ),
    );
  }
}

class _HolidayRow extends ConsumerWidget {
  const _HolidayRow({required this.holiday, this.dimmed = false});

  final Holiday holiday;
  final bool dimmed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    return Opacity(
      opacity: dimmed ? 0.55 : 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Container(
              width: 44,
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    DateFormat('d').format(holiday.date),
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: theme.colorScheme.primary),
                  ),
                  Text(
                    DateFormat('MMM').format(holiday.date).toUpperCase(),
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 10, color: theme.colorScheme.primary),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(holiday.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  Text(
                    DateFormat('EEEE, y').format(holiday.date),
                    style: TextStyle(fontSize: 12, color: onSurface.withValues(alpha: 0.55)),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Remove holiday',
              icon: const Icon(Icons.delete_outline_rounded, size: 19),
              color: theme.colorScheme.error,
              onPressed: () => ref.read(holidaysProvider.notifier).deleteHoliday(holiday.id),
            ),
          ],
        ),
      ),
    );
  }
}
