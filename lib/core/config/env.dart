class EnvConfig {
  const EnvConfig({
    required this.baseUrl,
    this.connectTimeoutMs = 15000,
    this.receiveTimeoutMs = 20000,
  });

  final String baseUrl;
  final int connectTimeoutMs;
  final int receiveTimeoutMs;
}

class Env {
  static EnvConfig current = const EnvConfig(
    baseUrl: 'https://api.example.com',
  );
}
