class AwareData {
  Map<String, dynamic> source = {};

  int timestamp = 0;
  String deviceId = "";
  String label = "";
  int timezone = 0;
  String os = "";
  int jsonVersion = 0;

  AwareData(Map<String, dynamic> data) {
    deviceId = data["deviceId"] ?? "";
    timestamp = data["timestamp"] ?? 0;
    label = data["label"] ?? "";
    timezone = data["timezone"] ?? 0;
    os = data["os"] ?? "";
    jsonVersion = data["jsonVersion"] ?? 0;
    source = data;
  }

  @override
  String toString() {
    if (source != null) {
      return source.toString();
    }
    return super.toString();
  }
}
