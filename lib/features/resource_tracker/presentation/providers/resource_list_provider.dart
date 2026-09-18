import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/resource.dart';
import '../../domain/entities/resource_metrics.dart';
import '../../domain/entities/resource_status.dart';
import 'dashboard_filters_provider.dart';
import 'repository_providers.dart';

/// Loads and mutates the roster for [selectedDateProvider]. Rebuilds
/// automatically whenever the selected date changes, since [build] watches
/// it.
class ResourceListNotifier extends AsyncNotifier<List<Resource>> {
  @override
  Future<List<Resource>> build() async {
    final date = ref.watch(selectedDateProvider);
    final getResources = ref.watch(getResourcesUseCaseProvider);
    return getResources(date);
  }

  Future<void> updateStatus(String resourceId, ResourceStatus status) async {
    final current = state.value;
    if (current == null) return;

    // Optimistic update so the summary banner reacts instantly.
    state = AsyncData([
      for (final resource in current)
        if (resource.id == resourceId) resource.copyWith(status: status) else resource,
    ]);

    final date = ref.read(selectedDateProvider);
    final updateUseCase = ref.read(updateResourceStatusUseCaseProvider);
    await updateUseCase(date, resourceId, status);
  }

  Future<void> cycleStatus(String resourceId) async {
    final current = state.value;
    if (current == null) return;
    final resource = current.firstWhere((r) => r.id == resourceId);
    await updateStatus(resourceId, resource.status.next);
  }

  Future<void> updateNotes(String resourceId, String notes) async {
    final current = state.value;
    if (current == null) return;

    state = AsyncData([
      for (final resource in current)
        if (resource.id == resourceId) resource.copyWith(notes: notes) else resource,
    ]);

    final date = ref.read(selectedDateProvider);
    final updateUseCase = ref.read(updateResourceNotesUseCaseProvider);
    await updateUseCase(date, resourceId, notes);
  }

  Future<void> addResource({required String name, required String mobileNumber}) async {
    final addUseCase = ref.read(addResourceUseCaseProvider);
    final created = await addUseCase(name: name, mobileNumber: mobileNumber);

    final current = state.value ?? const [];
    state = AsyncData([...current, created]);
  }

  Future<void> updateResource(String resourceId, {required String name, required String mobileNumber}) async {
    final current = state.value;
    if (current == null) return;

    // Optimistic update; only the master-profile fields change here, the
    // resource's status/notes for the currently viewed day are untouched.
    state = AsyncData([
      for (final resource in current)
        if (resource.id == resourceId) resource.copyWith(name: name, mobileNumber: mobileNumber) else resource,
    ]);

    final updateUseCase = ref.read(updateResourceUseCaseProvider);
    await updateUseCase(resourceId, name: name, mobileNumber: mobileNumber);
  }

  Future<void> deleteResource(String resourceId) async {
    final current = state.value;
    if (current == null) return;

    state = AsyncData([for (final resource in current) if (resource.id != resourceId) resource]);

    final deleteUseCase = ref.read(deleteResourceUseCaseProvider);
    await deleteUseCase(resourceId);
  }
}

final resourceListProvider = AsyncNotifierProvider<ResourceListNotifier, List<Resource>>(
  ResourceListNotifier.new,
);

/// Full roster for the day, ignoring search/filter — the source of truth
/// for the metrics banner and filter chip counts.
final dailyResourcesProvider = Provider<List<Resource>>((ref) {
  return ref.watch(resourceListProvider).value ?? const [];
});

final resourceMetricsProvider = Provider<ResourceMetrics>((ref) {
  return ResourceMetrics.fromResources(ref.watch(dailyResourcesProvider));
});

/// Roster after applying the search query and the active status filter —
/// what the table/grid/card list actually renders. The search box matches
/// by name or by mobile number (digits only, so "9000 0123 45" or
/// "+91-9000012345" still finds the same person).
final filteredResourcesProvider = Provider<List<Resource>>((ref) {
  final resources = ref.watch(dailyResourcesProvider);
  final query = ref.watch(searchQueryProvider).trim().toLowerCase();
  final queryDigits = query.replaceAll(RegExp(r'\D'), '');
  final filter = ref.watch(statusFilterProvider);

  return resources.where((resource) {
    final matchesFilter = filter.matches(resource.status);
    final matchesQuery = query.isEmpty ||
        resource.name.toLowerCase().contains(query) ||
        (queryDigits.isNotEmpty && resource.mobileNumber.contains(queryDigits));
    return matchesFilter && matchesQuery;
  }).toList(growable: false);
});
