import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../features/auth/data/services/auth_service.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/sign_screen.dart';
import '../../features/favorites/presentation/screens/favorites_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/product_detail/presentation/screens/detail_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/settings_screen.dart';
import '../../features/search/data/models/product.dart';
import '../../features/search/presentation/screens/search_screen.dart';
import '../../features/tips/data/models/tip.dart';
import '../../features/tips/presentation/screens/rehber_screen.dart';
import '../../features/tips/presentation/screens/tip_detail_screen.dart';
import '../../features/tips/presentation/screens/tips_list_screen.dart';
import '../../features/venues/presentation/screens/venue_map_screen.dart';
import '../../features/venues/presentation/screens/venues_screen.dart';
import 'main_shell.dart';

// Sekme sırası MainShell'deki NavigationBar destinations sırasıyla aynı olmalı.
const _branchPaths = ['/home', '/search', '/rehber', '/favorites', '/profile'];

GoRouter createAppRouter({required bool showOnboarding}) {
  final rootNavigatorKey = GlobalKey<NavigatorState>();
  // Onboarding tamamlanınca bu bayrak flip edilir — kReleaseMode kontrolü
  // sadece ilk açılış davranışını belirler, tekrar geri dönmez.
  var onboardingDone = !showOnboarding;

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: showOnboarding ? '/onboarding' : '/home',
    refreshListenable: GoRouterRefreshStream(AuthService.authStateChanges),
    redirect: (context, state) {
      final loc = state.matchedLocation;
      if (!onboardingDone) {
        return loc == '/onboarding' ? null : '/onboarding';
      }
      if (loc == '/onboarding') return '/home';

      final loggedIn = AuthService.currentUser != null;
      final onAuthRoute = loc.startsWith('/sign');
      if (!loggedIn && !onAuthRoute) return '/sign';
      if (loggedIn && onAuthRoute) return '/home';
      return null;
    },
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => OnboardingScreen(
          onCompleted: () => onboardingDone = true,
        ),
      ),
      GoRoute(
        path: '/sign',
        builder: (context, state) => const SignScreen(),
        routes: [
          GoRoute(
            path: 'login',
            builder: (context, state) => const LoginScreen(),
          ),
          GoRoute(
            path: 'register',
            builder: (context, state) => const RegisterScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/tips',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const TipsListScreen(),
        routes: [
          GoRoute(
            path: 'detay',
            parentNavigatorKey: rootNavigatorKey,
            builder: (context, state) =>
                TipDetailScreen(tip: state.extra as Tip),
          ),
        ],
      ),
      GoRoute(
        path: '/venues',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const VenuesScreen(),
        routes: [
          GoRoute(
            path: 'map',
            parentNavigatorKey: rootNavigatorKey,
            builder: (context, state) {
              final args = state.extra as Map<String, Object?>;
              return VenueMapScreen(
                center: args['center'] as LatLng,
                hasUserLocation: args['hasUserLocation'] as bool,
              );
            },
          ),
        ],
      ),
      GoRoute(
        path: '/urun',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => DetailScreen(
          product: state.extra as Product,
          onBack: () => context.pop(),
        ),
      ),
      GoRoute(
        path: '/settings',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const SettingsScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: _branchPaths[0],
              builder: (context, state) => HomeScreen(
                onTabChange: (i) => context.go(_branchPaths[i]),
              ),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: _branchPaths[1],
              builder: (context, state) => const SearchScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: _branchPaths[2],
              builder: (context, state) => const RehberScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: _branchPaths[3],
              builder: (context, state) => FavoritesScreen(
                onProductSelect: (_) {},
              ),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: _branchPaths[4],
              builder: (context, state) => const ProfileScreen(),
            ),
          ]),
        ],
      ),
    ],
  );
}

// Firebase Auth durumu değiştiğinde router'ın redirect'ini yeniden
// değerlendirmesini sağlar.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
