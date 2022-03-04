import 'dart:convert';

import 'package:intl/intl.dart';

enum DDOSStatus {
  none,
  success,
  attack,
  error,
  waiting,
}

class DDOSInfo {
  String msg;
  Uri? target;
  DateTime dateTime;
  int responseCode;
  DDOSStatus status;

  DDOSInfo({
    required this.msg,
    this.target,
    required this.dateTime,
    required this.responseCode,
    required this.status,
  });

  DDOSInfo copyWith({
    String? msg,
    Uri? target,
    DateTime? dateTime,
    int? responseCode,
    DDOSStatus? status,
  }) {
    return DDOSInfo(
      msg: msg ?? this.msg,
      target: target ?? this.target,
      dateTime: dateTime ?? this.dateTime,
      responseCode: responseCode ?? this.responseCode,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'msg': msg,
      'target': target?.toString(),
      'dateTime': dateTime.millisecondsSinceEpoch,
      'responseCode': responseCode,
      'status': status.index,
    };
  }

  factory DDOSInfo.fromMap(Map<String, dynamic> map) {
    return DDOSInfo(
      msg: map['msg'] ?? '',
      target: map['target'] != null ? Uri.parse(map['target']) : null,
      dateTime: DateTime.fromMillisecondsSinceEpoch(map['dateTime']),
      responseCode: map['responseCode']?.toInt() ?? 0,
      status: DDOSStatus.values[map['status'] ?? 0],
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
        other.target == target &&
        other.dateTime == dateTime &&
        other.responseCode == responseCode &&
        other.status == status;
  }

  @override
  int get hashCode {
    return msg.hashCode ^
        target.hashCode ^
        dateTime.hashCode ^
        responseCode.hashCode ^
        status.hashCode;
  }
}
