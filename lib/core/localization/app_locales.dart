import 'dart:ui';

import 'package:timeago/timeago.dart' as timeago;

/// Custom Indonesian time ago messages
class IdMessages implements timeago.LookupMessages {
  @override
  String prefixAgo() => '';
  @override
  String prefixFromNow() => '';
  @override
  String suffixAgo() => 'yang lalu';
  @override
  String suffixFromNow() => 'dari sekarang';
  @override
  String lessThanOneMinute(int seconds) => 'baru saja';
  @override
  String aboutAMinute(int minutes) => 'sekitar satu menit';
  @override
  String minutes(int minutes) => '$minutes menit';
  @override
  String aboutAnHour(int minutes) => 'sekitar satu jam';
  @override
  String hours(int hours) => '$hours jam';
  @override
  String aDay(int hours) => 'satu hari';
  @override
  String days(int days) => '$days hari';
  @override
  String aboutAMonth(int days) => 'sekitar satu bulan';
  @override
  String months(int months) => '$months bulan';
  @override
  String aboutAYear(int year) => 'sekitar satu tahun';
  @override
  String years(int years) => '$years tahun';
  @override
  String wordSeparator() => ' ';
}

class AppLocales {
  static Locale indonesian = const Locale('id', 'ID');
  static Locale english = const Locale('en', 'US');

  static List<Locale> supportedLocales = [
    indonesian,
    english,
  ];

  /// Returns a formatted version of language
  /// if nothing is present than it will pass the locale to a string
  static String formattedLanguageName(Locale locale) {
    if (locale == indonesian) {
      return 'Bahasa Indonesia';
    } else if (locale == english) {
      return 'English';
    } else {
      return locale.countryCode.toString();
    }
  }

  /// If you want custom messages on time ago (eg. a minute ago, a while ago)
  /// you can modify the below code, otherwise don't modify it unless necesarry
  static void setLocaleMessages() {
    // Using custom Indonesian messages for Indonesian locale
    timeago.setLocaleMessages(indonesian.toString(), IdMessages());
    timeago.setLocaleMessages(english.toString(), timeago.EnMessages());
  }
}
