import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:uk_power/utils/constants.dart';

class UpdateController {
  Future<bool> needUpdate() async {
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
          .replaceFirst("version:", "")
          .trim();
      version = version.replaceRange(
        version.indexOf("+"),
        version.length,
        "",
      );

      return _isVersionGreaterThan(version, appVersion);
    } catch (ex) {
      Logger().e(ex.toString());
      return false;
    }
  }

  bool _isVersionGreaterThan(String newVersion, String currentVersion) {
    List<String> currentV = currentVersion.split(".");
    List<String> newV = newVersion.split(".");
    bool a = false;
    for (var i = 0; i <= 2; i++) {
      a = int.parse(newV[i]) > int.parse(currentV[i]);
      if (int.parse(newV[i]) != int.parse(currentV[i])) break;
    }
    return a;
  }

  Future<void> downloadUpdate() async {}
}
