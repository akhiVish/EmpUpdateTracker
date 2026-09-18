import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/resource.dart';
import 'resource_list_provider.dart';

/// Search box on the Resources directory screen. Kept separate from the
/// Dashboard's [searchQueryProvider] since the two screens are searched
/// independently.
class ResourcesSearchController extends Notifier<String> {
  @override
  String build() => '';

  void set(String value) => state = value;

  void clear() => state = '';
}

final resourcesSearchQueryProvider = NotifierProvider<ResourcesSearchController, String>(
  ResourcesSearchController.new,
);

/// The full roster (name + mobile are day-independent, so whichever day is
/// currently loaded works) filtered by the directory's own search box.
final filteredDirectoryProvider = Provider<List<Resource>>((ref) {
  final resources = ref.watch(dailyResourcesProvider);
  final query = ref.watch(resourcesSearchQueryProvider).trim().toLowerCase();
  final queryDigits = query.replaceAll(RegExp(r'\D'), '');

  if (query.isEmpty) return resources;

  return resources.where((resource) {
    return resource.name.toLowerCase().contains(query) ||
        (queryDigits.isNotEmpty && resource.mobileNumber.contains(queryDigits));
  }).toList(growable: false);
});
