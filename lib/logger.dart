import 'package:intl/intl.dart';
import 'package:uk_power/ddos_info.dart';

class Logger {
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
}
