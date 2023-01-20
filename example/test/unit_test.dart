import 'package:test/test.dart';
import 'package:awareframework_core/awareframework_core.dart';
import 'package:awareframework_core/aware_sensor_config.dart';

void main() {
  test('my first unit test', () {
    var config = AwareSensorConfig();
    expect(config.deviceId, "");
  });
}
