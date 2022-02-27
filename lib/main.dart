import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:window_size/window_size.dart';

import 'package:uk_power/ddos_controller.dart';
import 'package:uk_power/ddos_status.dart';
import 'package:uk_power/logger.dart';

const primaryColor = Color(0xFF2697FF);
const secondaryColor = Color(0xFF2A2D3E);
const bgColor = Color(0xFF212332);

const defaultPadding = 16.0;

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
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: () => MaterialApp(
        title: 'UK Power',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: bgColor,
          textTheme: GoogleFonts.robotoTextTheme(
            Theme.of(context).textTheme,
          ).apply(
            bodyColor: Colors.white,
          ),
          canvasColor: secondaryColor,
        ),
        home: const Home(),
      ),
    );
  }
}

enum AppStatus {
  started,
  stopped,
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  AppStatus status = AppStatus.stopped;
  ScrollController loggerController = ScrollController();
  String msg = "";
  bool isError = false;
  List<DDOSInfo> logs = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        "Атака на ресурси окупанта",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 21.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // status icon
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Icon(
                isError
                    ? CupertinoIcons.clear_circled
                    : CupertinoIcons.checkmark_circle,
                size: 35.h,
                color: isError ? Colors.red : Colors.greenAccent,
              ),
            ),
            // status text
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      msg,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isError ? Colors.red : Colors.greenAccent,
                        fontWeight: FontWeight.w600,
                        fontSize: 16.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // start/stop btn
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: SizedBox(
                      height: 50.h,
                      child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateColor.resolveWith(
                            (states) => Colors.transparent,
                          ),
                          shape: MaterialStateProperty.resolveWith(
                            (states) => RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                              side: BorderSide(
                                color: status == AppStatus.started
                                    ? Colors.red
                                    : Colors.greenAccent,
                              ),
                            ),
                          ),
                        ),
                        onPressed: () async {
                          if (status == AppStatus.stopped) {
                            setState(() {
                              status = AppStatus.started;
                            });
                            start();
                            start();
                            start();
                            start();
                            await start();
                          } else {
                            setState(() {
                              status = AppStatus.stopped;
                              logs.clear();
                            });
                          }
                        },
                        child: Text(
                          status == AppStatus.started
                              ? "Зупинити атаку"
                              : "Розпочати атаку",
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // logs
            _Logs(
              loggerController: loggerController,
              logs: logs,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> start() async {
    var controller = DDOSController();
    var info = await controller.init();

    // check if resources available
    if (info.responseCode < 0) {
      setState(() {
        status = AppStatus.stopped;
        isError = true;
      });
    } else {
      setState(() {
        isError = false;
      });
    }

    setState(() {
      msg = info.msg;
      logs.add(info);
    });

    // lets dance
    for (int i = 0; i < 500; i++) {
      if (status == AppStatus.stopped) {
        return;
      }

      await controller.dance((_info) {
        setState(() {
          info = _info;
          logs.add(info);
        });
      });

      if (logs.length > 100) {
        logs.removeAt(0);
      }

      await Future.delayed(const Duration(seconds: 3));

      loggerController.animateTo(
        loggerController.position.maxScrollExtent,
        curve: Curves.easeOut,
        duration: const Duration(milliseconds: 100),
      );
    }

    start();
  }
}

class _Logs extends StatelessWidget {
  ScrollController loggerController;
  List<DDOSInfo> logs;

  _Logs({
    Key? key,
    required this.loggerController,
    required this.logs,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(
          horizontal: 15.0,
        ),
        controller: loggerController,
        itemCount: logs.length,
        itemBuilder: (context, index) {
          var info = logs.elementAt(index);
          String title = Logger.logTitle(info);
          String description = Logger.logDescription(info);

          return ListTile(
            minVerticalPadding: 15.0,
            leading: Icon(
              info.status == DDOSStatus.error
                  ? CupertinoIcons.clear_circled
                  : info.status == DDOSStatus.success
                      ? CupertinoIcons.checkmark_circle
                      : CupertinoIcons.timer,
              size: 35.h,
              color: info.status == DDOSStatus.error
                  ? Colors.red
                  : info.status == DDOSStatus.success
                      ? Colors.greenAccent
                      : Colors.yellowAccent,
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                  ),
                ),
              ],
            ),
            subtitle: Row(
              children: [
                Expanded(
                  child: Text(
                    description,
                    style: const TextStyle(
                      color: Color.fromARGB(255, 161, 161, 161),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
