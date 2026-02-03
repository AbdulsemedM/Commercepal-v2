import 'package:dio/dio.dart';

import '../data_provider/affiliate_register_data_provider.dart';
import '../models/affiliate_register_request_dto.dart';

class AffiliateRegisterRepository {
  AffiliateRegisterRepository({
    AffiliateRegisterDataProvider? dataProvider,
  }) : _dataProvider = dataProvider ?? AffiliateRegisterDataProvider();

  final AffiliateRegisterDataProvider _dataProvider;

  Future<void> register(AffiliateRegisterRequestDto request) async {
    try {
      await _dataProvider.register(request);
    } on DioException catch (e) {
      final message = e.response?.data?['message'] as String? ??
          e.response?.data?['error'] as String? ??
          e.message ??
          'Registration failed. Please try again.';
      throw Exception(message);
    }
  }
}
