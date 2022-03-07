import 'dart:convert';

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

  Proxy copyWith({
    String? ip,
    String? port,
    String? auth,
  }) {
    return Proxy(
      ip: ip ?? this.ip,
      port: port ?? this.port,
      auth: auth ?? this.auth,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ip': ip,
      'port': port,
      'auth': auth,
    };
  }

  factory Proxy.fromMap(Map<String, dynamic> map) {
    return Proxy(
      ip: map['ip'] ?? '',
      port: map['port'] ?? '',
      auth: map['auth'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Proxy.fromJson(String source) => Proxy.fromMap(json.decode(source));

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Proxy &&
        other.ip == ip &&
        other.port == port &&
        other.auth == auth;
  }

  @override
  int get hashCode => ip.hashCode ^ port.hashCode ^ auth.hashCode;
}
