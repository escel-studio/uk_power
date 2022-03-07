import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:uk_power/models/proxy.dart';
import 'package:uk_power/utils/constants.dart';

class ProxiesController {
  List<Proxy> proxies = [];
  final Dio _dio = Dio();

  Future<void> fetchAll() async {
    proxies.addAll(await _getSrc1());
    proxies.addAll(await _getSrc2());
    proxies.addAll(await _getSrc3());
  }

  Future<List<Proxy>> _getSrc1() async {
    List<Proxy> proxies = [];

    try {
      Response response = await _dio.getUri(Uri.parse(proxySource1));
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

  Future<List<Proxy>> _getSrc2() async {
    List<Proxy> proxies = [];

    try {
      Response response = await _dio.getUri(Uri.parse(proxySource2));
      String data = "";

      try {
        data = response.data;
      } catch (ex) {
        Logger().e(ex.toString());
      }

      List<String> rows = data.split("\n");
      for (String row in rows) {
        if (rows.indexOf(row) < 6 || row.isEmpty) continue;

        String ip = row.replaceRange(row.indexOf(":"), row.length, "").trim();
        String port = row.replaceRange(0, row.indexOf(":") + 1, "");
        port = port.replaceRange(port.indexOf(" "), port.length, "").trim();

        proxies.add(Proxy(ip: ip, port: port));
      }
    } catch (ex) {
      Logger().e(ex.toString());
    }

    return proxies;
  }

  Future<List<Proxy>> _getSrc3() async {
    List<Proxy> proxies = [];

    try {
      Response response = await _dio.getUri(Uri.parse(proxySource3));
      String data = "";

      try {
        data = response.data;
      } catch (ex) {
        Logger().e(ex.toString());
      }

      List<String> rows = data.split("\n");
      for (String row in rows) {
        if (row.isEmpty) continue;

        String ip = row.replaceRange(row.indexOf(":"), row.length, "").trim();
        String port = row.replaceRange(0, row.indexOf(":") + 1, "").trim();

        proxies.add(Proxy(ip: ip, port: port));
      }
    } catch (ex) {
      Logger().e(ex.toString());
    }

    return proxies;
  }

  List<Proxy> formateProxy(List<dynamic> proxiesRaw) {
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
}
