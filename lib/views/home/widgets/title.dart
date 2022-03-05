import 'package:flutter/material.dart';

class HomeTitle extends StatelessWidget {
  const HomeTitle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const FittedBox(
      fit: BoxFit.fitWidth,
      child: Text(
        "Атака на ресурси окупанта",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
