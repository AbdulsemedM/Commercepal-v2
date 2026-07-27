class FcmRegisterRequest {
  final String fcmToken;
  final String deviceType;
  final String deviceId;

  FcmRegisterRequest({
    required this.fcmToken,
    required this.deviceType,
    required this.deviceId,
  });

  Map<String, dynamic> toJson() => {
        'fcmToken': fcmToken,
        'deviceType': deviceType,
        'deviceId': deviceId,
      };
}
