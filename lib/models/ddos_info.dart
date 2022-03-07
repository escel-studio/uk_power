import 'dart:convert';

import 'package:intl/intl.dart';

import 'package:uk_power/models/enums.dart';
import 'package:uk_power/models/proxy.dart';

class DDOSInfo {
  String msg;
  int responseCode;
  DDOSStatus status;
  DateTime dateTime;
  Uri? target;
  Proxy? proxy;

  DDOSInfo({
    required this.msg,
    required this.responseCode,
    required this.status,
    required this.dateTime,
    this.target,
    this.proxy,
  });

  DDOSInfo copyWith({
    String? msg,
    int? responseCode,
    DDOSStatus? status,
    DateTime? dateTime,
    Uri? target,
    Proxy? proxy,
  }) {
    return DDOSInfo(
      msg: msg ?? this.msg,
      responseCode: responseCode ?? this.responseCode,
      status: status ?? this.status,
      dateTime: dateTime ?? this.dateTime,
      target: target ?? this.target,
      proxy: proxy ?? this.proxy,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'msg': msg,
      'responseCode': responseCode,
      'status': status.index,
      'dateTime': dateTime.millisecondsSinceEpoch,
      'target': target?.toString(),
      'proxy': proxy?.toMap(),
    };
  }

  factory DDOSInfo.fromMap(Map<String, dynamic> map) {
    return DDOSInfo(
      msg: map['msg'] ?? '',
      responseCode: map['responseCode']?.toInt() ?? 0,
      status: DDOSStatus.values[map['status']?.toInt() ?? 0],
      dateTime: DateTime.fromMillisecondsSinceEpoch(map['dateTime']),
      target: map['target'] != null ? Uri.parse(map['target']) : null,
      proxy: map['proxy'] != null ? Proxy.fromMap(map['proxy']) : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory DDOSInfo.fromJson(String source) =>
      DDOSInfo.fromMap(json.decode(source));

  @override
  String toString() {
    return "DateTime: ${DateFormat("dd.MM.yy hh:mm:ss").format(dateTime)}, "
        "Resource: ${target.toString()}, "
        "Status: $responseCode, "
        "Msg: $msg;";
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DDOSInfo &&
        other.msg == msg &&
        other.responseCode == responseCode &&
        other.status == status &&
        other.dateTime == dateTime &&
        other.target == target &&
        other.proxy == proxy;
  }

  @override
  int get hashCode {
    return msg.hashCode ^
        responseCode.hashCode ^
        status.hashCode ^
        dateTime.hashCode ^
        target.hashCode ^
        proxy.hashCode;
  }
}
