import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:logger/logger.dart' as l;
import 'package:uk_power/models/ddos_info.dart';
import 'package:uk_power/utils/constants.dart';

class Logger {
  static Directory? _documents;

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

  static void logToFile(DDOSInfo info) async {
    _documents ??= await getApplicationDocumentsDirectory();

    String pathToFile = "${_documents!.path}\\$logsFileName";
    File logsFile = File(pathToFile);

    String data = "";

    try {
      data = await logsFile.readAsString();
    } catch (ex) {
      l.Logger().e(ex);
    }

    logsFile.writeAsString(data + info.toString() + "\n", flush: true);
  }
}
