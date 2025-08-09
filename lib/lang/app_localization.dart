import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:touria/services/provider/language_provider.dart';

class AppLocalization {
  final Locale locale;
  AppLocalization({required this.locale});

  String get languageCode => locale.languageCode;

  String get safeLangCode {
    if (languageCode.contains('si')) return 'si';
    if (languageCode.contains('ta')) return 'ta';
    return 'en';
  }

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'welcome': 'Welcome to Touria',
      'logout': 'Logout',
      'profile': 'My Profile',
      'my_bookings': 'My Bookings',
      'settings': 'Settings',
      'language': 'Language',
      'dark_mode': 'Dark Mode',
      'support': 'Support',
      'confirm_logout': 'Confirm Logout',
      'are_you_sure_logout': 'Are you sure you want to logout?',
      'cancel': 'Cancel',
      // ignore: equal_keys_in_map
      'logout': 'Logout',
    },
    'si': {
      'welcome': 'ටුරියා වෙත සාදරයෙන් පිළිගනිමු',
      'logout': 'පිටවීම',
      'profile': 'මගේ පැතිකඩ',
      'my_bookings': 'මගේ බුක්කින්ග්',
      'settings': 'සැකසුම්',
      'language': 'භාෂාව',
      'dark_mode': 'අඳුරු මෝඩ්',
      'support': 'අදාල අරමුදල්',
      'confirm_logout': 'පිටවීමට අනුමැතියක්',
      'are_you_sure_logout': 'ඔබට පිටවීමට සහතිකයිද?',
      'cancel': 'අවලංගු',
      // ignore: equal_keys_in_map
      'logout': 'පිටවීම',
    },
    'ta': {
      'welcome': 'டூரியா வரவேற்கிறது',
      'logout': 'வெளியேறு',
      'profile': 'என் சுயவிவரம்',
      'my_bookings': 'என் பதிவு',
      'settings': 'அமைப்புகள்',
      'language': 'மொழி',
      'dark_mode': 'அண்மைய முறை',
      'support': 'உதவி',
      'confirm_logout': 'வெளியேற்றத்தை உறுதிப்படுத்துக',
      'are_you_sure_logout': 'நீங்கள் வெளியேற்ற விரும்புகிறீர்களா?',
      'cancel': 'ரத்து',
      // ignore: equal_keys_in_map
      'logout': 'வெளியேறு',
    },
  };

  String translate(String key) {
    final translations = _localizedValues[safeLangCode];

    if (translations == null || !translations.containsKey(key)) {
      debugPrint('⚠️ Missing translation for "$key" in "$safeLangCode');
      return key;
    }
    return _localizedValues[languageCode]?[key] ?? key;
  }

  static AppLocalization of(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );
    return AppLocalization(locale: languageProvider.locale);
  }
}
