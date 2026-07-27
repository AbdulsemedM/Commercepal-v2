class FcmUnregisterRequest {
  final String fcmToken;

  FcmUnregisterRequest({required this.fcmToken});

  Map<String, dynamic> toJson() => {
        'fcmToken': fcmToken,
      };
}
