import 'package:test/test.dart';
import 'package:awareframework_core/awareframework_core.dart';

void main() {
  test('my first unit test', (){
    var config = AwareSensorConfig();
    expect(config.deviceId, "");
  });
}