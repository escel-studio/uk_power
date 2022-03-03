import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:uk_power/controllers/ddos_controller.dart';
import 'package:uk_power/controllers/update_controller.dart';
import 'package:uk_power/models/ddos_info.dart';
import 'package:uk_power/utils/constants.dart';
import 'package:uk_power/views/home/widgets/logs.dart';
import 'package:uk_power/views/home/widgets/status.dart';
import 'package:uk_power/views/home/widgets/title.dart';

enum _AppStatus {
  started,
  stopped,
}

enum _AttackType {
  easy,
  hard,
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  _AppStatus appStatus = _AppStatus.stopped;
  _AttackType attackType = _AttackType.easy;
  ScrollController loggerController = ScrollController();
  String msg = "";
  bool isError = false;
  List<DDOSInfo> logs = [];

  void _checkForUpdate({bool init = false}) async {
    UpdateController updateController = UpdateController();

    if (await updateController.needUpdate()) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.QUESTION,
        title: "Доступне оновлення",
        desc:
            "Ми знайшли новішу версію додатку - ${updateController.publishedVersion},"
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        title: const HomeTitle(),
        centerTitle: true,
        actions: [
          IconButton(
            splashRadius: 25,
            onPressed: _checkForUpdate,
            tooltip: "Перевірити оновлення",
            icon: const Icon(
              CupertinoIcons.refresh,
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
            _SwitchButton(
              callback: (type) {
                setState(() {
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
      case _AppStatus.started:
        title = "Зупинити атаку";
        borderColor = Colors.red;
        break;
      case _AppStatus.stopped:
        title = "Розпочати атаку";
        borderColor = Colors.greenAccent;
        break;
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
    if (appStatus == _AppStatus.stopped) {
      setState(() {
        appStatus = _AppStatus.started;
        logs.clear();
        isError = false;
        msg = "";
      });
      await start();
    } else {
      setState(() {
        appStatus = _AppStatus.stopped;
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
          appStatus = _AppStatus.stopped;
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
    while (appStatus != _AppStatus.stopped) {
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
          appStatus = _AppStatus.stopped;
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

// ignore: must_be_immutable
class _SwitchButton extends StatefulWidget {
  _AttackType type;
  void Function(_AttackType) callback;

  _SwitchButton({
    Key? key,
    required this.type,
    required this.callback,
  }) : super(key: key);

  @override
  State<_SwitchButton> createState() => __SwitchButtonState();
}

class __SwitchButtonState extends State<_SwitchButton> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15.0),
      decoration: BoxDecoration(
        // color: const Color(0xffF5F7FB),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
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
                          color: widget.type == _AttackType.easy
                              ? Colors.blueAccent
                              : Colors.transparent,
                        ),
                      ),
                    ),
                  ),
                  onPressed: () {
                    widget.callback(_AttackType.easy);
                    widget.type = _AttackType.easy;
                  },
                  child: Text(
                    "Easy mode",
                    style: TextStyle(
                      color: widget.type == _AttackType.easy
                          ? const Color(0xffF5F7FB)
                          : const Color(0xffD0D0D0),
                    ),
                  ),
                ),
              ),
            ),
          ),
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
                          color: widget.type == _AttackType.hard
                              ? Colors.blueAccent
                              : Colors.transparent,
                        ),
                      ),
                    ),
                  ),
                  onPressed: () {
                    widget.callback(_AttackType.hard);
                    widget.type = _AttackType.hard;
                  },
                  child: Text(
                    "Rage mode",
                    style: TextStyle(
                      color: widget.type == _AttackType.hard
                          ? const Color(0xffF5F7FB)
                          : const Color(0xffD0D0D0),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
