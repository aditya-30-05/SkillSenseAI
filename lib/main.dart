import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trainer_app/app/theme.dart';
import 'package:trainer_app/app/app_shell.dart';
import 'package:trainer_app/features/auth/login_screen.dart';
import 'package:trainer_app/providers/app_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: SkillSenseApp(),
    ),
  );
}

class SkillSenseApp extends ConsumerWidget {
  const SkillSenseApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoggedIn = ref.watch(isLoggedInProvider);
    final isDarkMode = ref.watch(darkModeProvider);

    return MaterialApp(
      title: 'SkillSense AI — Trainer Dashboard',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      darkTheme: AppTheme.dark,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: isLoggedIn ? const AppShell() : const LoginScreen(),
    );
  }
}
