import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/firebase_holiday_data_source.dart';
import '../../data/datasources/firebase_resource_data_source.dart';
import '../../data/datasources/holiday_data_source.dart';
import '../../data/datasources/resource_data_source.dart';
import '../../data/repositories/holiday_repository_impl.dart';
import '../../data/repositories/resource_repository_impl.dart';
import '../../domain/repositories/holiday_repository.dart';
import '../../domain/repositories/resource_repository.dart';
import '../../domain/usecases/add_holiday_usecase.dart';
import '../../domain/usecases/add_resource_usecase.dart';
import '../../domain/usecases/delete_holiday_usecase.dart';
import '../../domain/usecases/delete_resource_usecase.dart';
import '../../domain/usecases/get_holidays_usecase.dart';
import '../../domain/usecases/get_metrics_history_usecase.dart';
import '../../domain/usecases/get_resource_history_usecase.dart';
import '../../domain/usecases/get_resources_usecase.dart';
import '../../domain/usecases/update_resource_notes_usecase.dart';
import '../../domain/usecases/update_resource_status_usecase.dart';
import '../../domain/usecases/update_resource_usecase.dart';

/// Dependency-injection wiring — the one place that knows about the
/// concrete data source. Swapping [FirebaseResourceDataSource] back for
/// `MockResourceDataSource` (offline demo mode) means changing only the
/// line below; nothing else in the app needs to know.
final resourceDataSourceProvider = Provider<ResourceDataSource>((ref) {
  return FirebaseResourceDataSource();
});

final resourceRepositoryProvider = Provider<ResourceRepository>((ref) {
  return ResourceRepositoryImpl(ref.watch(resourceDataSourceProvider));
});

final getResourcesUseCaseProvider = Provider<GetResourcesUseCase>((ref) {
  return GetResourcesUseCase(ref.watch(resourceRepositoryProvider));
});

final updateResourceStatusUseCaseProvider = Provider<UpdateResourceStatusUseCase>((ref) {
  return UpdateResourceStatusUseCase(ref.watch(resourceRepositoryProvider));
});

final updateResourceNotesUseCaseProvider = Provider<UpdateResourceNotesUseCase>((ref) {
  return UpdateResourceNotesUseCase(ref.watch(resourceRepositoryProvider));
});

final addResourceUseCaseProvider = Provider<AddResourceUseCase>((ref) {
  return AddResourceUseCase(ref.watch(resourceRepositoryProvider));
});

final updateResourceUseCaseProvider = Provider<UpdateResourceUseCase>((ref) {
  return UpdateResourceUseCase(ref.watch(resourceRepositoryProvider));
});

final deleteResourceUseCaseProvider = Provider<DeleteResourceUseCase>((ref) {
  return DeleteResourceUseCase(ref.watch(resourceRepositoryProvider));
});

final getMetricsHistoryUseCaseProvider = Provider<GetMetricsHistoryUseCase>((ref) {
  return GetMetricsHistoryUseCase(ref.watch(resourceRepositoryProvider));
});

final getResourceHistoryUseCaseProvider = Provider<GetResourceHistoryUseCase>((ref) {
  return GetResourceHistoryUseCase(ref.watch(resourceRepositoryProvider));
});

// Holidays: same pattern, separate data source.
final holidayDataSourceProvider = Provider<HolidayDataSource>((ref) {
  return FirebaseHolidayDataSource();
});

final holidayRepositoryProvider = Provider<HolidayRepository>((ref) {
  return HolidayRepositoryImpl(ref.watch(holidayDataSourceProvider));
});

final getHolidaysUseCaseProvider = Provider<GetHolidaysUseCase>((ref) {
  return GetHolidaysUseCase(ref.watch(holidayRepositoryProvider));
});

final addHolidayUseCaseProvider = Provider<AddHolidayUseCase>((ref) {
  return AddHolidayUseCase(ref.watch(holidayRepositoryProvider));
});

final deleteHolidayUseCaseProvider = Provider<DeleteHolidayUseCase>((ref) {
  return DeleteHolidayUseCase(ref.watch(holidayRepositoryProvider));
});
