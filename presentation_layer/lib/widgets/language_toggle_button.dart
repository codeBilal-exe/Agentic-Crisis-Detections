import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/language_provider.dart';

class LanguageToggleButton extends ConsumerWidget {
  const LanguageToggleButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isUrdu = ref.watch(languageProvider) == AppLanguage.urdu;

    return IconButton(
      icon: Text(
        isUrdu ? 'EN' : 'اردو',
        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
      ),
      onPressed: () {
        ref.read(languageProvider.notifier).toggleLanguage();
      },
      tooltip: isUrdu ? 'English' : 'اردو',
    );
  }
}
