import 'package:uuid/uuid.dart';

Future<String> getDeviceId() async {
  return const Uuid().v4();
}
