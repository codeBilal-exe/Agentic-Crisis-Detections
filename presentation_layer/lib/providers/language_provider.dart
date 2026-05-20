import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/l10n/app_en.dart';
import '../core/l10n/app_ur.dart';

enum AppLanguage { english, urdu }

extension AppLanguageHelpers on AppLanguage {
  Locale get locale => this == AppLanguage.urdu ? const Locale('ur') : const Locale('en');
  TextDirection get direction => this == AppLanguage.urdu ? TextDirection.rtl : TextDirection.ltr;
}

class LanguageNotifier extends StateNotifier<AppLanguage> {
  LanguageNotifier() : super(AppLanguage.english);

  void toggleLanguage() {
    state = state == AppLanguage.english ? AppLanguage.urdu : AppLanguage.english;
  }

  void setLanguage(AppLanguage lang) {
    state = lang;
  }
}

final languageProvider = StateNotifierProvider<LanguageNotifier, AppLanguage>(
  (ref) => LanguageNotifier(),
);

String tr(dynamic ref, String key) {
  final AppLanguage lang;
  if (ref is WidgetRef) {
    lang = ref.watch(languageProvider);
  } else {
    lang = AppLanguage.english;
  }
  final strings = lang == AppLanguage.urdu ? urStrings : enStrings;
  return strings[key] ?? key;
}
