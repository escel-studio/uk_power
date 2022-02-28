import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:window_size/window_size.dart';

import 'package:uk_power/ddos_controller.dart';
import 'package:uk_power/ddos_info.dart';
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
    if (Platform.isLinux) {
      setWindowMaxSize(const Size(500, 650));
      setWindowMinSize(const Size(500, 650));
    }
  }

  runApp(const App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

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
            const _Title(),
            _Status(isError: isError, text: msg),
            // start/stop btn
            _getBtn(),
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

  Widget _getBtn() {
    String title;
    Color borderColor;

    if (status == AppStatus.started) {
      title = "Зупинити атаку";
      borderColor = Colors.red;
    } else {
      title = "Розпочати атаку";
      borderColor = Colors.greenAccent;
    }

    return Row(
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
                      side: BorderSide(color: borderColor),
                    ),
                  ),
                ),
                onPressed: _btnPressed,
                child: Text(title),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _btnPressed() async {
    if (status == AppStatus.stopped) {
      setState(() {
        status = AppStatus.started;
        logs.clear();
        isError = false;
        msg = "";
      });
      await start();
    } else {
      setState(() {
        status = AppStatus.stopped;
      });
    }
  }

  /// start function, will create 5 tasks with last one on await
  Future<void> start() async {
    // lets create 5 tasks
    _attack();
    await Future.delayed(const Duration(seconds: 1));
    _attack();
    await Future.delayed(const Duration(seconds: 1));
    _attack();
    await Future.delayed(const Duration(seconds: 1));
    _attack();
    // ast one should be await
    await _attack();
  }

  /// main attack activity
  Future<void> _attack() async {
    DDOSController controller = DDOSController();
    // 1) init hosts and/or targets
    await controller.init((info) {
      _log(info);

      setState(() {
        if (info.responseCode >= 302 && info.responseCode >= 200) {
          status = AppStatus.stopped;
          isError = true;
        }
        if (!msg.contains(info.msg)) {
          if (msg.isNotEmpty) msg += "\n";
          msg += info.msg;
        }
      });
    });
    // 2) if error:
    //    - should exit from this function
    if (isError) return;

    // 3) if no errors:
    //    - start main loop
    while (status != AppStatus.stopped) {
      try {
        await controller.dance((_info) {
          _log(_info);

          // lets not flood in the memory with old logs and clean first 10 of them
          if (logs.length > 100) {
            setState(() {
              logs.removeRange(0, 9);
            });
          }
        });
      } catch (ex) {
        _log(
          DDOSInfo(
            msg: "Виник збій під час роботи\n"
                "${ex.toString()}\n"
                "Спробуйте ще раз, або скопіюйте помилку та надішліть мені.",
            dateTime: DateTime.now(),
            responseCode: 500,
            status: DDOSStatus.error,
          ),
        );
        setState(() {
          status = AppStatus.stopped;
        });
        return;
      }
    }
  }

  /// update logs
  void _log(DDOSInfo info) async {
    setState(() {
      logs.add(info);
    });
    // lets take a break for a 1 seconds
    await Future.delayed(const Duration(seconds: 1));
    // lets scroll to the latest logs
    loggerController.animateTo(
      loggerController.position.maxScrollExtent,
      curve: Curves.easeOut,
      duration: const Duration(milliseconds: 100),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
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
    );
  }
}

// ignore: must_be_immutable
class _Status extends StatelessWidget {
  bool isError;
  String text;

  _Status({
    Key? key,
    required this.isError,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    EdgeInsets padding = const EdgeInsets.all(10.0);
    IconData iconData;
    Color color;

    if (isError) {
      iconData = CupertinoIcons.clear_circled;
      color = Colors.red;
    } else {
      iconData = CupertinoIcons.checkmark_circle;
      color = Colors.greenAccent;
    }

    return Column(
      children: [
        // status icon
        Padding(
          padding: padding,
          child: Icon(
            iconData,
            size: 35.h,
            color: color,
          ),
        ),
        // status text
        Padding(
          padding: padding,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: 16.sp,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ignore: must_be_immutable
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

          IconData iconData;
          Color color;

          switch (info.status) {
            case DDOSStatus.success:
              iconData = CupertinoIcons.checkmark_circle;
              color = Colors.greenAccent;
              break;
            case DDOSStatus.attack:
              iconData = CupertinoIcons.square_stack_3d_down_dottedline;
              color = Colors.blueAccent;
              break;
            case DDOSStatus.error:
              iconData = CupertinoIcons.clear_circled;
              color = Colors.red;
              break;
            case DDOSStatus.none:
            case DDOSStatus.waiting:
              iconData = CupertinoIcons.timer;
              color = Colors.yellowAccent;
              break;
          }

          return ListTile(
            onTap: () {
              Clipboard.setData(ClipboardData(text: "$title\n$description"));

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    "Повідомлення від ${DateFormat("hh:mm:ss").format(info.dateTime)} - Скопійовано",
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: secondaryColor,
                ),
              );
            },
            minVerticalPadding: 15.0,
            leading: Icon(
              iconData,
              size: 35.h,
              color: color,
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
