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
    EdgeInsets padding = const EdgeInsets.only(
      left: 10.0,
      right: 10.0,
      bottom: 15.0,
    );
    Color color = Colors.greenAccent;

    if (isError) color = Colors.red;

    return Padding(
      padding: padding,
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              textAlign: TextAlign.center,
              maxLines: 3,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 14.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
