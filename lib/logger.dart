import 'package:intl/intl.dart';
import 'package:uk_power/ddos_status.dart';

class Logger {
  static String logTitle(DDOSInfo info) {
    String msg =
        "[${DateFormat("dd.MM.yy hh:mm:ss").format(info.dateTime)}] Атака - ";

    switch (info.status) {
      case DDOSStatus.none:
        msg += "????????????????????\n";
        break;
      case DDOSStatus.success:
        msg += "В процесі";
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
    var target = info.target.toString();

    String msg =
        "Ресурс: $target, Статус: ${info.responseCode}, Повідомлення: ${info.msg}";

    return msg;
  }
}
