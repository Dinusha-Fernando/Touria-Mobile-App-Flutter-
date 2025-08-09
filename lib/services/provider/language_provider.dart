import 'package:flutter/widgets.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');
  Locale get locale => _locale;

  void setLocale(Locale locale) {
    if (!Lang.all.contains(locale)) return;
    _locale = locale;
    notifyListeners();
  }

  void clearLocale() {
    _locale = Locale('en');
    notifyListeners();
  }
}

class Lang {
  static final all = [
    const Locale('en'),
    const Locale('si'),
    const Locale('ta'),
  ];
}
