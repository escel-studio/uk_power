import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:uk_power/utils/constants.dart';

class UpdateController {
  static Future<bool> isUpdateAvailable() async {
    Dio dio = Dio();

    try {
      Response response = await dio.getUri(Uri.parse(pubspecURL));
      String body = "";

      try {
        body = response.data.toString();
      } catch (ex) {
        Logger().e(ex.toString());
        return false;
      }

      List<String> split = body.split("\n");
      String version = split
          .singleWhere(
            (element) => element.contains("version:"),
          )
          .replaceFirst(
            "version:",
            "",
          ).replaceRange(start, end, "")
          .trim();
      return version == appVersion;
    } catch (ex) {
      Logger().e(ex.toString());
      return false;
    }
  }

  static Future<void> downloadUpdate() async {}
}
