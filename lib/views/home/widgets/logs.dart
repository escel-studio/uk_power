import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import 'package:uk_power/models/ddos_info.dart';
import 'package:uk_power/utils/constants.dart';
import 'package:uk_power/utils/logger.dart';

// ignore: must_be_immutable
class HomeLogs extends StatelessWidget {
  ScrollController loggerController;
  List<DDOSInfo> logs;

  HomeLogs({
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
                    "Повідомлення від ${DateFormat("hh:mm:ss", "uk").format(info.dateTime)} - Скопійовано",
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
                    maxLines:
                        description.startsWith("Виник збій під час роботи")
                            ? null
                            : 3,
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
