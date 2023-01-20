import 'dart:io';

///
/// A default sensor configuration
///
/// You can make a configuration class for a subclass of AwareSensor.
/// NOTE: Please don't forget overwrite -toMap() method. This method is called
/// when AwareSensor send the configuration instance as a Map object.
///
/// You can initialize the instance as following:
/// [Example 1]
/// var config = AwareSensorConfig(debug:true, label:"sample");
///
/// [Example 2]
/// var config = AwareSenorConfig();
///   ..debug = true
///   ..label = "sample";
///
class AwareSensorConfig {
  /// The status of sensor enabled of not (default = false)
  bool enabled = false;

  /// The status of debug mode (default = false)
  bool debug = false;

  /// The label for the sensor data (default = "")
  String label = "";

  /// The deviceId of the sensor (default = `null`).
  String? deviceId;

  /// The database encryption key (default = `null`)
  String? dbEncryptionKey;

  /// The database type on Android (default = DatabaseTypeAndroid.ROOM)
  DatabaseType dbType = DatabaseType.DEFAULT;

  /// The local database path (default = "aware")
  String dbPath = "aware";

  /// The remote database host name (default = `null`)
  String? dbHost;

  AwareSensorConfig(
      {this.debug = false,
      this.enabled = false,
      this.label = "",
      this.deviceId,
      this.dbEncryptionKey,
      this.dbType = DatabaseType.DEFAULT,
      this.dbPath = "aware",
      this.dbHost});

  /// Generate a Map<String,dynamic> object for sensing the configuration via
  /// MethodChannel. Sending the configuration object through the MethodChannel,
  /// we have to use a Map object.
  ///
  /// If you need to save the data into database, please set
  /// DatabaseType.DEFAULT to dbType. In the setting, iOS uses Realm,
  /// and Android uses Room database internally. In addition, If you do NOT
  /// want to save data into database, please set NONE as a dbType.
  ///
  /// When you call -toMap(), the method converts the dbType element depends on the
  /// current platform.
  Map<String, dynamic> toMap() {
    var config = {
      "enabled": enabled,
      "debug": debug,
      "label": label,
      "deviceId": deviceId,
      "dbPath": dbPath
    };

    if (dbEncryptionKey != null) {
      config["dbEncryptionKey"] = dbEncryptionKey;
    }

    if (dbHost != null) {
      config["dbHost"] = dbHost;
    }

    // change dbType setting depends on the platform (iOS or Android)
    if (Platform.isIOS) {
      if (this.dbType == DatabaseType.NONE) {
        config["dbType"] = 0;
      } else if (this.dbType == DatabaseType.DEFAULT) {
        config["dbType"] = 1;
      }
    }

    return config;
  }
}

/// The list of supported database types on iOS
///
/// NONE:  No database
/// REALM: Realm database [Realm](https://realm.io)
enum DatabaseType {
  NONE,
  DEFAULT,
}

class AwareDbSyncManagerConfig {
  double syncInterval = 1.0;
  bool wifiOnly = true;
  bool batteryChargingOnly = false;
  bool debug = false;
  List<String> sensors = <String>[];

  Map<String, dynamic> toMap() {
    var config = {
      "syncInterval": syncInterval,
      "wifiOnly": wifiOnly,
      "batteryChargingOnly": batteryChargingOnly,
      "debug": debug,
      "sensors": sensors
    };
    return config;
  }
}
