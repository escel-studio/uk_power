import 'dart:io';

import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uk_power/utils/constants.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateController {
  String publishedVersion = "";

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
      publishedVersion = version.replaceRange(
        version.indexOf("+"),
        version.length,
        "",
      );

      return _isVersionGreaterThan(publishedVersion, appVersion);
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

  Future<void> downloadUpdate() async {
    String url = updateURL.replaceFirst("VERSION", publishedVersion);
    String savePath = "";

    if (Platform.isWindows) {
      url += windowsFile;
      savePath = (await getDownloadsDirectory())!.path + "\\$windowsFile";
    } else if (Platform.isAndroid) {
      url += androidFile;
      savePath =
          (await getApplicationDocumentsDirectory()).path + "\\$androidFile";
    } else if (Platform.isLinux) {
      url += linuxFile;
      savePath = (await getDownloadsDirectory())!.path + "\\$linuxFile";
    }

    await launch(url);
  }
}
