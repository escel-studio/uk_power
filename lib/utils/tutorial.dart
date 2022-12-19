import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class Tutorial {
  BuildContext context;
  final List<TargetFocus> _targets = [];

  Tutorial({
    required this.context,
  });

  void show({
    GlobalKey? updateKey,
    GlobalKey? switchKey,
    GlobalKey? btnKey,
    GlobalKey? settingsKey,
  }) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    bool tutorialShown = pref.getBool('tutorialShown') ?? false;

    if (tutorialShown) return;

    if (switchKey != null) _createSwitchTutorial(switchKey);
    if (btnKey != null) _createBtnTutorial(btnKey);
    if (updateKey != null) _createUpdateTutorial(updateKey);
    if (settingsKey != null) _createSettingsTutorial(settingsKey);

    if (_targets.isNotEmpty) {
      TutorialCoachMark(
        targets: _targets,
        colorShadow: Colors.pink,
        textSkip: "Пропустити",
        paddingFocus: 10,
        opacityShadow: 0.8,
        onFinish: () {
          pref.setBool('tutorialShown', true);
        },
        onSkip: () {
          pref.setBool('tutorialShown', true);
        },
      ).show(context: context);
    }
  }

  void _createSwitchTutorial(GlobalKey? switchKey) {
    _targets.add(
      TargetFocus(
        identify: "Перемикач",
        keyTarget: switchKey,
        shape: ShapeLightFocus.RRect,
        radius: 5,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  "Режими атаки",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 10.0),
                  child: Text(
                    "Було вирішено створити два режими атаки:\n"
                    "\n1) Легкий режим - мінімально навантажує ваш пристрій, та використовує легкі алгоритми роботи, забезпечуючи середній рівень атаки на ресурси;\n"
                    "\n2) Rage (лютий) режим - він використовую ваш пристрій по максимуму, забезпечуючи стабільне велике навантаження на ворожі ресурси, цей режим не рекомендований для мобільних пристроїв.",
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _createBtnTutorial(GlobalKey? btnKey) {
    _targets.add(
      TargetFocus(
        identify: "Запуск",
        keyTarget: btnKey,
        shape: ShapeLightFocus.RRect,
        radius: 5,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  "Початок атаки",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 10.0),
                  child: Text(
                    "Щоб розпочати атаку на ворожі ресурси, Вам потрібно натиснути на кнопку \"Розпочати атаку\". Щоб припинити атаку, Вам потрібно натиснути на \"Зупинити атаку\".",
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _createUpdateTutorial(GlobalKey? updateKey) {
    _targets.add(
      TargetFocus(
        identify: "Оновлення",
        keyTarget: updateKey,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  "Перевірка оновлень",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 10.0),
                  child: Text(
                    "Ми спростили роботу з новими оновленнями додатку, більше не потрібно шукати їх у соц. мережах, а можна завантажити одразу через додаток.",
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _createSettingsTutorial(GlobalKey? settingsKey) {
    _targets.add(
      TargetFocus(
        identify: "Налаштування",
        keyTarget: settingsKey,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  "Додаткові налаштування",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 10.0),
                  child: Text(
                    "Ми додали можливість логувати інформацію про ваші атаки у файл \"uk-power-logs.log\". Ви можете увімкнути, або вимкнути цю можливість.",
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
