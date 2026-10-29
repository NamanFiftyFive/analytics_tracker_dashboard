import 'package:analytics_tracker/core/config/app_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

DotEnv envOf(String text) => DotEnv()..loadFromString(envString: text);

void main() {
  const env = '''
API_BASE_URL=http://localhost:8000/api/v1/
API_BASE_URL_ANDROID=http://10.0.2.2:8000/api/v1
CONNECT_TIMEOUT_SECONDS=5
RECEIVE_TIMEOUT_SECONDS=30
''';

  test('reads the base URL and timeouts, without a trailing slash', () {
    final config = AppConfig.fromEnv(envOf(env), platform: TargetPlatform.iOS);
    expect(config.apiBaseUrl, 'http://localhost:8000/api/v1');
    expect(config.connectTimeout, const Duration(seconds: 5));
    expect(config.receiveTimeout, const Duration(seconds: 30));
  });

  test('Android uses API_BASE_URL_ANDROID (emulator reaches the Mac via 10.0.2.2)', () {
    final config = AppConfig.fromEnv(envOf(env), platform: TargetPlatform.android);
    expect(config.apiBaseUrl, 'http://10.0.2.2:8000/api/v1');
  });

  test('missing optional values fall back to defaults', () {
    final config = AppConfig.fromEnv(envOf('API_BASE_URL=http://api.test/api/v1'), platform: TargetPlatform.android);
    expect(config.apiBaseUrl, 'http://api.test/api/v1');
    expect(config.connectTimeout, const Duration(seconds: 10));
    expect(config.receiveTimeout, const Duration(seconds: 20));
  });
}
