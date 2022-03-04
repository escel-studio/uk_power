import 'package:flutter/material.dart';

/// app version
const appVersion = '3.0.0';

/// github app version
const pubspecURL = "https://raw.githubusercontent.com/escel-studio/uk_power/main/pubspec.yaml";

/// github releases url template
const updateURL = "https://github.com/escel-studio/uk_power/releases/download/VERSION/";

/// files
const androidFile = "Android.apk";
const windowsFile = "Windows.rar";
const linuxFile = "Linux.zip";

/// default timeout for requests
const timeout = Duration(seconds: 15);

/// primary color
const primaryColor = Color(0xFF2697FF);

/// secondary color
const secondaryColor = Color(0xFF2A2D3E);

/// background color
const bgColor = Color(0xFF212332);

/// default widget padding
const defaultPadding = 16.0;

/// our list of targets
const sourceURL = "https://raw.githubusercontent.com/senpaiburado/zxcvbnty/main/ttqtet.txt";

/// default url
const defaultHost = "http://65.108.20.65";

/// ukrainian api's for attacks
const apiURL = "https://gitlab.com/cto.endel/atack_hosts/-/raw/master/hosts.json";

/// global list of proxies
const proxySource = "https://proxylist.geonode.com/api/proxy-list?page=1&sort_by=lastChecked&sort_type=desc";

// logs msgs
const initError = "Виникла помилка при звертанні до джерел: ";
const invalidBodyError = "Неможливо розпізнати файл з цілями\n";
const hostsConnected = "Успішно з'єднано до COUNT ресурсів";
const directFound = "Успішно знайдено COUNT цілей";
const tryAgainHosts = "Спробуйте ще раз, щось пішло не так\n";
const tryAgainDirect = "Неможливо отримати список цілей\n";
const hostsKW = "HOSTS: ";
const directKW = "DIRECT: ";
const timeoutError = "Перевищенно очікування COUNT сек.";
const timeoutProxyError = "[Proxy] Перевищенно очікування COUNT сек.";
const success = "Достукались";
const successProxy = "[Proxy] Достукались";

// tooltips
const easyModeTT = "Легкий режим атаки - він призначений використовувати оптимальні налаштування та алгоритми, щоб не перенавантажувати ваш пристрій.";
const rageModeTT = "Rage (лютий) режим атаки - він призначений для тих, хто готовий використовувати максимум ресурсу свого пристрою. Не рекомендуємо для телефонів.";
