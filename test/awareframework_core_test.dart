import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:awareframework_core/awareframework_core.dart';

void main() {
  const MethodChannel channel = MethodChannel('awareframework_core');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await AwareframeworkCore.platformVersion, '42');
  });
}
