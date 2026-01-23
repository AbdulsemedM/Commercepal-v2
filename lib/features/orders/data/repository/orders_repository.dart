import '../data_provider/orders_data_provider.dart';
import '../models/orders_response.dart';
import 'package:commercepal/core/storage/storage.dart';
import 'package:commercepal/core/logging/app_logger.dart';
import 'package:commercepal/features/profile/data/repository/profile_repository.dart';

class OrdersRepository {
  OrdersRepository({
    OrdersDataProvider? dataProvider,
    Storage? storage,
    ProfileRepository? profileRepository,
  })  : _dataProvider = dataProvider ?? OrdersDataProvider(),
        _storage = storage ?? Storage(),
        _profileRepository = profileRepository ?? ProfileRepository();

  final OrdersDataProvider _dataProvider;
  final Storage _storage;
  final ProfileRepository _profileRepository;

  Future<OrdersResponse> getOrders({
    int? customerId,
    String? stageCategory,
    String? searchQuery,
    String? dateFrom,
    String? dateTo,
    int? page,
    int? size,
    String? sort,
    String? direction,
  }) async {
    print('🟡 OrdersRepository: getOrders called with customerId: $customerId');
    // Get customerId from storage if not provided
    var storedCustomerId = await _storage.getCustomerId();
    var finalCustomerId = customerId ?? storedCustomerId;
    print('🟡 OrdersRepository: customerId from param: $customerId, from storage: $storedCustomerId, final: $finalCustomerId');
    AppLogger.i('OrdersRepository.getOrders - customerId from param: $customerId, from storage: $storedCustomerId, final: $finalCustomerId');

    // If customerId is missing, try to load profile to get it
    if (finalCustomerId == null) {
      print('🟡 OrdersRepository: Customer ID missing, attempting to load profile...');
      try {
        final profileResponse = await _profileRepository.getProfile();
        if (profileResponse.data.customerId != null) {
          await _storage.saveCustomerId(profileResponse.data.customerId!);
          finalCustomerId = profileResponse.data.customerId;
          print('✅ OrdersRepository: Loaded customerId from profile: $finalCustomerId');
        }
      } catch (e) {
        print('❌ OrdersRepository: Failed to load profile: $e');
        AppLogger.e('Failed to load profile to get customerId', error: e);
      }
    }

    if (finalCustomerId == null) {
      print('❌ OrdersRepository: Customer ID is still missing after loading profile!');
      AppLogger.e('Customer ID is missing');
      throw Exception('Customer ID is required. Please ensure you are logged in and your profile is loaded.');
    }

    print('🟡 OrdersRepository: Calling data provider with customerId: $finalCustomerId');
    AppLogger.i('Calling data provider with customerId: $finalCustomerId');
    return await _dataProvider.getOrders(
      customerId: finalCustomerId,
      stageCategory: stageCategory,
      searchQuery: searchQuery,
      dateFrom: dateFrom,
      dateTo: dateTo,
      page: page,
      size: size,
      sort: sort,
      direction: direction,
    );
  }
}
