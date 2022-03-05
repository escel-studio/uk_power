import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:logger/logger.dart' as l;
import 'package:uk_power/models/ddos_info.dart';
import 'package:uk_power/utils/constants.dart';

class Logger {
  static Directory? _outDir;

  static String logTitle(DDOSInfo info) {
    String msg = "[${DateFormat("dd.MM.yy hh:mm:ss").format(info.dateTime)}] ";
    if (info.responseCode >= 500) {
      info.status = DDOSStatus.success;
      msg += "Ресурс лежить!";

      return msg;
    }

    switch (info.status) {
      case DDOSStatus.none:
        msg += "????????????????????";
        break;
      case DDOSStatus.success:
        msg += "З'єднанно, обробка в процесі";
        break;
      case DDOSStatus.error:
        msg += "Помилка";
        break;
      case DDOSStatus.waiting:
        msg += "Очікуємо";
        break;
      case DDOSStatus.attack:
        msg += "Атакуємо";
        break;
    }

    return msg;
  }

  static String logDescription(DDOSInfo info) {
    Uri? target = info.target;

    String msg = "Статус: ${info.responseCode}, Повідомлення: ${info.msg}";

    if (target != null) {
      msg = "Ресурс: $target, " + msg;
    }

    return msg;
  }

  static Future<void> logToFile(DDOSInfo info) async {
    String pathToFile = "";

    if (Platform.isWindows) {
      _outDir ??= await getApplicationDocumentsDirectory();
      pathToFile += "${_outDir!.path}\\$logsFileName";
    } else if (Platform.isAndroid) {
      _outDir ??= await getExternalStorageDirectory();
      pathToFile += "${_outDir!.path}/$logsFileName";
    }

    File logsFile = File(pathToFile);
    await logsFile.writeAsString(
      info.toString() + "\n",
      flush: true,
      mode: FileMode.append,
    );
  }
}
