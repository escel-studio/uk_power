import 'dart:io';

import 'package:flutter/material.dart';
import 'package:uk_power/app/app.dart';
import 'package:window_size/window_size.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowTitle("UK - Power");

    if (Platform.isWindows) {
      setWindowMaxSize(const Size(500, 760));
      setWindowMinSize(const Size(500, 760));
    }
    if (Platform.isMacOS) {
      setWindowMaxSize(const Size(400, 600));
      setWindowMinSize(const Size(400, 600));
    }
    if (Platform.isLinux) {
      setWindowMaxSize(const Size(500, 650));
      setWindowMinSize(const Size(500, 650));
    }
  }
  
  runApp(const App());
}
