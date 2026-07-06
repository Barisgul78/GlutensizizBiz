import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'core/routing/app_router.dart';
import 'features/auth/data/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Android'de google-services.json + Gradle eklentisi native tarafta
  // "[DEFAULT]" app'i zaten kuruyor; options ile init etmek onunla çakışıp
  // "duplicate-app" hatası fırlatıyor. Parametresiz çağrı native'i devralır.
  await Firebase.initializeApp();
  final prefs = await SharedPreferences.getInstance();
  // Debug'da her seferinde onboarding göster; release'de sadece bir kez
  final onboardingDone =
      kReleaseMode ? (prefs.getBool('onboarding_done') ?? false) : false;
  // currentUser yerine stream'in ilk event'i beklenir — oturum disk'ten
  // henüz geri yüklenmeden senkron kontrol yanlışlıkla null dönebilir
  await AuthService.authStateChanges.first;
  runApp(MyApp(showOnboarding: !onboardingDone));
}

class MyApp extends StatefulWidget {
  final bool showOnboarding;
  const MyApp({super.key, required this.showOnboarding});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final GoRouter _router =
      createAppRouter(showOnboarding: widget.showOnboarding);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'GluFree',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      // Şimdilik sabit TR; dinamik dil değişimi ayrı bir iş (LocaleProvider)
      locale: const Locale('tr'),
      supportedLocales: const [Locale('tr'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: _router,
    );
  }
}
