import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uk_power/models/enums.dart';
import 'package:uk_power/utils/constants.dart';

// ignore: must_be_immutable
class SwitchButton extends StatefulWidget {
  AttackType type;
  void Function(AttackType) callback;

  SwitchButton({
    Key? key,
    required this.type,
    required this.callback,
  }) : super(key: key);

  @override
  State<SwitchButton> createState() => _SwitchButtonState();
}

class _SwitchButtonState extends State<SwitchButton> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18.0),
      ),
      child: Row(
        children: [
          Expanded(
            child: Tooltip(
              message: easyModeTT,
              child: Padding(
                padding: const EdgeInsets.all(0.0),
                child: SizedBox(
                  height: 50.h,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateColor.resolveWith(
                        (states) => Colors.transparent,
                      ),
                      shape: MaterialStateProperty.resolveWith(
                        (states) => RoundedRectangleBorder(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(18.0),
                            bottomLeft: Radius.circular(18.0),
                          ),
                          side: BorderSide(
                            width: widget.type == AttackType.easy ? 1.2 : 1.0,
                            color: widget.type == AttackType.easy
                                ? Colors.blueAccent
                                : Colors.white60,
                          ),
                        ),
                      ),
                    ),
                    onPressed: () {
                      widget.callback(AttackType.easy);
                      widget.type = AttackType.easy;
                    },
                    child: Text(
                      "Легкий режим",
                      style: TextStyle(
                        color: widget.type == AttackType.easy
                            ? const Color(0xffF5F7FB)
                            : Colors.white60,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Tooltip(
              message: rageModeTT,
              child: Padding(
                padding: const EdgeInsets.all(0.0),
                child: SizedBox(
                  height: 50.h,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateColor.resolveWith(
                        (states) => Colors.transparent,
                      ),
                      shape: MaterialStateProperty.resolveWith(
                        (states) => RoundedRectangleBorder(
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(18.0),
                            bottomRight: Radius.circular(18.0),
                          ),
                          side: BorderSide(
                            width: widget.type == AttackType.rage ? 1.2 : 1.0,
                            color: widget.type == AttackType.rage
                                ? Colors.pink
                                : Colors.white60,
                          ),
                        ),
                      ),
                    ),
                    onPressed: () {
                      widget.callback(AttackType.rage);
                      widget.type = AttackType.rage;
                    },
                    child: Text(
                      "Rage режим",
                      style: TextStyle(
                        color: widget.type == AttackType.rage
                            ? const Color(0xffF5F7FB)
                            : Colors.white60,
                      ),
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
