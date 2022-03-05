import 'dart:io';
import 'dart:isolate';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:uk_power/controllers/ddos_controller.dart';
import 'package:uk_power/controllers/update_controller.dart';
import 'package:uk_power/models/ddos_info.dart';
import 'package:uk_power/models/enums.dart';
import 'package:uk_power/utils/constants.dart';
import 'package:uk_power/utils/logger.dart';
import 'package:uk_power/utils/tutorial.dart';
import 'package:uk_power/views/home/widgets/logs.dart';
import 'package:uk_power/views/home/widgets/status.dart';
import 'package:uk_power/views/home/widgets/switch.dart';
import 'package:uk_power/views/home/widgets/title.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  AppStatus appStatus = AppStatus.stopped;
  AttackType attackType = AttackType.easy;

  ScrollController loggerController = ScrollController();

  String msg = "";

  bool isError = false;
  bool allowLogsToFile = true;

  final GlobalKey _updateKey = GlobalKey();
  final GlobalKey _settingsKey = GlobalKey();
  final GlobalKey _switchKey = GlobalKey();
  final GlobalKey _btnKey = GlobalKey();

  List<DDOSInfo> logs = [];
  List<ReceivePort> ports = [];
  List<Isolate> isolates = [];

  void _checkForUpdate({bool init = false}) async {
    UpdateController updateController = UpdateController();

    if (await updateController.needUpdate()) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.QUESTION,
        title: "Доступне оновлення",
        desc:
            "Ми знайшли новішу версію додатку - ${updateController.publishedVersion}, "
            "Ви використовуєте - $appVersion.\n"
            "Бажаєте оновитись?",
        btnOkText: "Так",
        btnCancelText: "Ні",
        btnOkOnPress: () async {
          await updateController.downloadUpdate();
        },
        btnCancelOnPress: () {},
      ).show();
    } else {
      if (!init) {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.SUCCES,
          title: "Оновлення не потрібні",
          desc: "Ви вже використовуєте останню версію додатку!",
          btnOkText: "Гаразд",
          btnOkOnPress: () {},
        ).show();
      }
    }
  }

  @override
  void initState() {
    super.initState();

    _checkForUpdate(init: true);

    Tutorial(context: context).show(
      updateKey: _updateKey,
      switchKey: _switchKey,
      btnKey: _btnKey,
      settingsKey: _settingsKey,
    );

    SharedPreferences.getInstance().then(
      (pref) {
        bool? allowed = pref.getBool('allowLogsToFile');

        if (allowed == null) {
          allowLogsToFile = true;
          pref.setBool('allowLogsToFile', true);
        } else {
          allowLogsToFile = allowed;
        }

        setState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: Material(
            color: Colors.transparent,
            child: PopupMenuButton(
              key: _settingsKey,
              tooltip: "Налаштування",
              elevation: 5.0,
              child: const Icon(
                CupertinoIcons.ellipsis_vertical,
              ),
              itemBuilder: (context) => [
                PopupMenuItem(
                  child: StatefulBuilder(
                    builder: (_context, _setState) => CheckboxListTile(
                      activeColor: primaryColor,
                      value: allowLogsToFile,
                      onChanged: (value) {
                        _setState(() => allowLogsToFile = value!);
                        SharedPreferences.getInstance().then(
                          (pref) {
                            pref.setBool('allowLogsToFile', allowLogsToFile);
                          },
                        );
                      },
                      title: const Text('Дозволити логування'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        title: const HomeTitle(),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 5.0),
            child: IconButton(
              key: _updateKey,
              splashRadius: 25,
              onPressed: _checkForUpdate,
              tooltip: "Перевірити оновлення",
              icon: const Icon(
                CupertinoIcons.refresh,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            HomeStatus(isError: isError, text: msg),
            // attack mods
            SwitchButton(
              key: _switchKey,
              callback: (type) {
                setState(() {
                  if (attackType != type) {
                    appStatus = AppStatus.stopped;
                  }
                  attackType = type;
                });
              },
              type: attackType,
            ),
            // start/stop btn
            _getBtn(),
            // logs
            HomeLogs(
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

    switch (appStatus) {
      case AppStatus.started:
        title = "Зупинити атаку";
        borderColor = Colors.red;
        break;
      case AppStatus.stopped:
        title = "Розпочати атаку";
        borderColor = Colors.greenAccent;
        break;
    }

    return Row(
      children: [
        Expanded(
          child: Padding(
            key: _btnKey,
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
    if (appStatus == AppStatus.stopped) {
      _clean();
      _killThreadsTasks();
      await start();
    } else {
      _killThreadsTasks();
      setState(() {
        appStatus = AppStatus.stopped;
      });
    }
  }

  void _clean() {
    setState(() {
      appStatus = AppStatus.started;
      logs.clear();
      isError = false;
      msg = "";
    });
  }

  void _killThreadsTasks() {
    for (Isolate i in isolates) {
      i.kill(priority: Isolate.beforeNextEvent);
    }

    isolates.clear();

    for (ReceivePort port in ports) {
      port.close();
    }

    ports.clear();
  }

  /// start function, will create 5 tasks with last one on await
  Future<void> start() async {
    switch (attackType) {
      case AttackType.easy:
        await _easyMode();
        break;
      case AttackType.rage:
        await _rageMode();
        break;
    }
  }

  Future<void> _easyMode() async {
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

  Future<void> _rageMode() async {
    int maxThreads = Platform.numberOfProcessors;

    for (int i = 0; i < maxThreads; ++i) {
      ReceivePort receiverPort = ReceivePort("Thread #$i port");
      ports.add(receiverPort);

      isolates.add(
        await Isolate.spawn(
          rageAttack,
          receiverPort.sendPort,
          debugName: "Thread #$i",
        ),
      );

      receiverPort.listen((data) {
        if (data is Map<String, dynamic>) {
          String _msg = data['msg'];
          DDOSInfo _info = data['info'];

          switch (_msg) {
            case "stop":
              setState(() {
                appStatus = AppStatus.stopped;
                isError = true;
              });
              _log(_info);
              _killThreadsTasks();
              break;
            case "log":
              _log(_info);
              break;
            case "info":
              setState(() {
                if (_info.responseCode >= 302 && _info.responseCode >= 200) {
                  appStatus = AppStatus.stopped;
                  isError = true;
                  _killThreadsTasks();
                }
                if (!msg.contains(_info.msg)) {
                  if (msg.isNotEmpty) msg += "\n";
                  msg += _info.msg;
                }
              });
              _log(_info);
              break;
          }
        } else if (data is String) {
          if (data == "stop") {
            setState(() {
              appStatus = AppStatus.stopped;
              isError = true;
            });
            _killThreadsTasks();
          }
        }

        if (logs.length > 100) {
          logs.removeRange(0, 9);
        }
      });
    }
  }

  /// main attack activity
  Future<void> _attack() async {
    DDOSController controller = DDOSController();
    // 1) init hosts and/or targets
    await controller.init((info) {
      _log(info);

      setState(() {
        if (info.responseCode >= 302 && info.responseCode >= 200) {
          appStatus = AppStatus.stopped;
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
    while (appStatus != AppStatus.stopped) {
      try {
        //TODO: ADD ATTACK TYPE HANDLER
        await controller.dance((_info) {
          // lets not flood in the memory with old logs and clean first 10 of them
          if (logs.length > 100) {
            logs.removeRange(0, 9);
          }

          _log(_info);
        });
      } catch (ex) {
        appStatus = AppStatus.stopped;

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
        return;
      }
    }
  }

  /// update logs
  void _log(DDOSInfo info) async {
    if (allowLogsToFile) await Logger.logToFile(info);

    if (appStatus == AppStatus.stopped) return;

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

void rageAttack(SendPort port) async {
  DDOSController controller = DDOSController();
  // 1) init hosts and/or targets
  await controller.init((info) {
    port.send(
      {
        'msg': "info",
        'info': info,
      },
    );

    if (info.responseCode >= 302 && info.responseCode >= 200) {
      port.send('stop');
    }
  });

  // 3) if no errors:
  //    - start main loop
  while (true) {
    try {
      await controller.dance((_info) {
        port.send(
          {
            'msg': "log",
            'info': _info,
          },
        );
      });
    } catch (ex) {
      // stop
      port.send(
        {
          'msg': "stop",
          'info': DDOSInfo(
            msg: "Виник збій під час роботи\n"
                "${ex.toString()}\n"
                "Спробуйте ще раз, або скопіюйте помилку та надішліть мені.",
            dateTime: DateTime.now(),
            responseCode: 500,
            status: DDOSStatus.error,
          ),
        },
      );
      return;
    }
  }
}
