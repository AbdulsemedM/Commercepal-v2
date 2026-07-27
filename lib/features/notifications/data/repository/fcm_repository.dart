import '../data_provider/fcm_data_provider.dart';
import '../models/fcm_register_request.dart';
import '../models/fcm_unregister_request.dart';

class FcmRepository {
  FcmRepository({FcmDataProvider? dataProvider})
      : _dataProvider = dataProvider ?? FcmDataProvider();

  final FcmDataProvider _dataProvider;

  Future<void> register({
    required String fcmToken,
    required String deviceType,
    required String deviceId,
  }) {
    return _dataProvider.register(
      FcmRegisterRequest(
        fcmToken: fcmToken,
        deviceType: deviceType,
        deviceId: deviceId,
      ),
    );
  }

  Future<void> unregister({required String fcmToken}) {
    return _dataProvider.unregister(
      FcmUnregisterRequest(fcmToken: fcmToken),
    );
  }
}
