import 'package:flutter/material.dart';

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
const String sourceURL = "https://raw.githubusercontent.com/senpaiburado/zxcvbnty/main/ttqtet.txt";

/// ukrainian api's for attacks
const String apiURL = "http://rockstarbloggers.ru/hosts.json";

/// global list of proxies
const String proxySource = "https://proxylist.geonode.com/api/proxy-list?page=1&sort_by=lastChecked&sort_type=desc";

const String initError = "Виникла помилка при звертанні до джерел: ";
const String invalidBodyError = "Неможливо розпізнати файл з цілями\n";
const String hostsConnected = "Успішно з'єднано до COUNT ресурсів";
const String directFound = "Успішно знайдено COUNT цілей";
const String tryAgainHosts = "Спробуйте ще раз, щось пішло не так\n";
const String tryAgainDirect = "Неможливо отримати список цілей\n";
const String hostsKW = "HOSTS: ";
const String directKW = "DIRECT: ";
const String timeoutError = "Перевищенно очікування COUNT сек.";
const String timeoutProxyError = "[Proxy] Перевищенно очікування COUNT сек.";
const String success = "Достукались";
const String successProxy = "[Proxy] Достукались";
