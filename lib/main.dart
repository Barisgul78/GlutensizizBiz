import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'core/routing/main_shell.dart';
import 'features/auth/data/services/auth_service.dart';
import 'features/onboarding/presentation/screens/onboarding_screen.dart';
import 'features/auth/presentation/screens/sign_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final prefs = await SharedPreferences.getInstance();
  // Debug'da her seferinde onboarding göster; release'de sadece bir kez
  final onboardingDone = kReleaseMode
    ? (prefs.getBool('onboarding_done') ?? false)
      : false;
  // currentUser yerine stream'in ilk event'i beklenir — oturum disk'ten
  // henüz geri yüklenmeden senkron kontrol yanlışlıkla null dönebilir
  final user = await AuthService.authStateChanges.first;
  runApp(MyApp(showOnboarding: !onboardingDone, isLoggedIn: user != null));
}

class MyApp extends StatelessWidget {
  final bool showOnboarding;
  final bool isLoggedIn;
  const MyApp({super.key, required this.showOnboarding, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    final Widget home;
    if (showOnboarding) {
      home = const OnboardingScreen();
    } else if (isLoggedIn) {
      // Oturum açık kalmış — direkt ana sayfaya
      home = const MainShell();
    } else {
      home = const SignScreen();
    }

    return MaterialApp(
      title: 'GluFree',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: home,
    );
  }
}
