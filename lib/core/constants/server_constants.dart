import 'dart:io';

class ServerConstants {
  static String serverUrl =
      Platform.isAndroid ? 'http://10.0.2.2:8000' : "http://0.0.0.0:8000";
}
