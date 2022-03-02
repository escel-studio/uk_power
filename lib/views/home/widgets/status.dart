import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

// ignore: must_be_immutable
class HomeStatus extends StatelessWidget {
  bool isError;
  String text;

  HomeStatus({
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
