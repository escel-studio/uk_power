import 'package:flutter/material.dart';

const appVersion = '2.0.3';
const pubspecURL = "https://raw.githubusercontent.com/escel-studio/uk_power/main/pubspec.yaml";

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
const sourceURL =
    "https://raw.githubusercontent.com/senpaiburado/zxcvbnty/main/ttqtet.txt";

/// ukrainian api's for attacks
const apiURL = "http://rockstarbloggers.ru/hosts.json";

/// global list of proxies
const proxySource =
    "https://proxylist.geonode.com/api/proxy-list?page=1&sort_by=lastChecked&sort_type=desc";

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
