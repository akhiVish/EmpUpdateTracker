import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/resource.dart';
import '../providers/nav_provider.dart';
import '../providers/reports_provider.dart';
import '../providers/resource_list_provider.dart';
import '../providers/resources_directory_provider.dart';
import '../widgets/header/add_resource_dialog.dart';
import '../widgets/resource_list/resource_avatar.dart';
import '../widgets/resources/delete_resource_dialog.dart';
import '../widgets/resources/edit_resource_dialog.dart';

/// Full employee directory: every resource on the roster, independent of
/// any single day, with the ability to add, edit or remove someone. Tap a
/// row/card to open that person's report on the Reports tab.
class ResourcesScreen extends ConsumerWidget {
  const ResourcesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncResources = ref.watch(resourceListProvider);
    final isInitialLoading = asyncResources.isLoading && !asyncResources.hasValue;
    final hasFailed = asyncResources.hasError && !asyncResources.hasValue;

    if (isInitialLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (hasFailed) {
      return const Center(child: Text('Could not load the resource directory'));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final deviceType = AppBreakpoints.deviceTypeFor(constraints.maxWidth);
        final horizontalPadding = switch (deviceType) {
          DeviceType.mobile => AppSpacing.md,
          DeviceType.tablet => AppSpacing.lg,
          DeviceType.desktop => AppSpacing.xl,
        };

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ResourcesHeader(deviceType: deviceType),
              const SizedBox(height: AppSpacing.lg),
              switch (deviceType) {
                DeviceType.desktop => const _DirectoryTable(),
                DeviceType.tablet => const _DirectoryGrid(),
                DeviceType.mobile => const _DirectoryList(),
              },
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        );
      },
    );
  }
}

/// Opens this resource's report on the Reports tab.
void _openReport(WidgetRef ref, Resource resource) {
  ref.read(selectedReportResourceIdProvider.notifier).set(resource.id);
  ref.read(selectedTabProvider.notifier).set(AppTab.reports);
}

class _ResourcesHeader extends ConsumerWidget {
  const _ResourcesHeader({required this.deviceType});

  final DeviceType deviceType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isMobile = deviceType == DeviceType.mobile;
    final total = ref.watch(dailyResourcesProvider).length;
    final hasQuery = ref.watch(resourcesSearchQueryProvider).isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Resources',
          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        Text(
          '$total ${total == 1 ? 'person' : 'people'} on the roster. Tap anyone to see their report.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        if (isMobile)
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _SearchField(hasQuery: hasQuery),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () => AddResourceDialog.show(context),
                icon: const Icon(Icons.add_rounded, size: 20),
                label: const Text('Add Resource'),
              ),
            ],
          )
        else
          Row(
            children: [
              Expanded(child: _SearchField(hasQuery: hasQuery)),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () => AddResourceDialog.show(context),
                icon: const Icon(Icons.add_rounded, size: 20),
                label: const Text('Add Resource'),
              ),
            ],
          ),
      ],
    );
  }
}

class _SearchField extends ConsumerStatefulWidget {
  const _SearchField({required this.hasQuery});

  final bool hasQuery;

  @override
  ConsumerState<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends ConsumerState<_SearchField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: ref.read(resourcesSearchQueryProvider));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 360),
      child: TextField(
        controller: _controller,
        onChanged: (value) => ref.read(resourcesSearchQueryProvider.notifier).set(value),
        decoration: InputDecoration(
          isDense: true,
          hintText: 'Search by name or mobile number…',
          prefixIcon: const Icon(Icons.search_rounded, size: 20),
          suffixIcon: widget.hasQuery
              ? IconButton(
                  icon: const Icon(Icons.close_rounded, size: 18),
                  onPressed: () {
                    _controller.clear();
                    ref.read(resourcesSearchQueryProvider.notifier).clear();
                  },
                )
              : null,
        ),
      ),
    );
  }
}

class _RowActions extends ConsumerWidget {
  const _RowActions({required this.resource});

  final Resource resource;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: 'Edit',
          icon: const Icon(Icons.edit_outlined, size: 19),
          onPressed: () => EditResourceDialog.show(context, resource),
        ),
        IconButton(
          tooltip: 'Remove',
          icon: const Icon(Icons.delete_outline_rounded, size: 19),
          color: Theme.of(context).colorScheme.error,
          onPressed: () => DeleteResourceDialog.show(context, ref, resource),
        ),
      ],
    );
  }
}

class _DirectoryTable extends ConsumerWidget {
  const _DirectoryTable();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resources = ref.watch(filteredDirectoryProvider);
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            color: theme.colorScheme.onSurface.withValues(alpha: 0.03),
            child: Row(
              children: [
                const SizedBox(width: 44),
                const Expanded(child: _HeaderLabel('Resource Details')),
                const SizedBox(width: 96, child: _HeaderLabel('Actions', align: TextAlign.center)),
              ],
            ),
          ),
          Divider(height: 1, color: theme.dividerColor),
          if (resources.isEmpty)
            const _DirectoryEmptyState()
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: resources.length,
              separatorBuilder: (context, index) => Divider(height: 1, color: theme.dividerColor),
              itemBuilder: (context, index) {
                final resource = resources[index];
                return InkWell(
                  onTap: () => _openReport(ref, resource),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              ResourceAvatar(resource: resource),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      resource.name,
                                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.phone_rounded, size: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.45)),
                                        const SizedBox(width: 4),
                                        Text(
                                          resource.mobileNumber,
                                          style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.55)),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 96, child: Center(child: _RowActions(resource: resource))),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _HeaderLabel extends StatelessWidget {
  const _HeaderLabel(this.text, {this.align = TextAlign.left});

  final String text;
  final TextAlign align;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: align,
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            letterSpacing: 0.3,
          ),
    );
  }
}

class _DirectoryCard extends ConsumerWidget {
  const _DirectoryCard({required this.resource});

  final Resource resource;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _openReport(ref, resource),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  ResourceAvatar(resource: resource, radius: 18),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          resource.name,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.phone_rounded, size: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.45)),
                            const SizedBox(width: 4),
                            Text(
                              resource.mobileNumber,
                              style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.55)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  _RowActions(resource: resource),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DirectoryGrid extends ConsumerWidget {
  const _DirectoryGrid();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resources = ref.watch(filteredDirectoryProvider);
    if (resources.isEmpty) return const _DirectoryEmptyState();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: resources.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 3.1,
      ),
      itemBuilder: (context, index) => _DirectoryCard(resource: resources[index]),
    );
  }
}

class _DirectoryList extends ConsumerWidget {
  const _DirectoryList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resources = ref.watch(filteredDirectoryProvider);
    if (resources.isEmpty) return const _DirectoryEmptyState();

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: resources.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) => _DirectoryCard(resource: resources[index]),
    );
  }
}

class _DirectoryEmptyState extends StatelessWidget {
  const _DirectoryEmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.5);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 64),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.person_search_rounded, size: 40, color: muted),
          const SizedBox(height: 12),
          Text('No resources match your search', style: theme.textTheme.titleMedium?.copyWith(color: muted)),
        ],
      ),
    );
  }
}
