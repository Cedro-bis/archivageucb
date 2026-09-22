import 'package:archivageucb/export_pages.dart';
import 'package:archivageucb/pages/upload_sceen.dart';
import 'package:archivageucb/pages/verify_email_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

GoRouter goRouter = GoRouter(
  initialLocation: '/',
  refreshListenable: GoRouterRefreshStream(
    FirebaseAuth.instance.authStateChanges(),
  ),
  redirect: (context, state) {
    final bool loggedIn = FirebaseAuth.instance.currentUser != null;
    final bool loggingIn = state.matchedLocation == '/login';
    if (!loggedIn && !loggingIn) return '/login';
    if (loggedIn && loggingIn) return '/';
    return null;
  },
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomePage()),
    GoRoute(
      path: '/registred',
      builder: (context, state) => const Enregistrement(),
    ),
    GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
    GoRoute(path: '/profil', builder: (context, state) => const Profil()),
    GoRoute(
      path: '/redirection',
      builder: (context, state) => const Redirection(),
    ),
    GoRoute(path: '/upload', builder: (context, state) => const UploadScreen()),
    GoRoute(
      path: '/verify',
      builder: (context, state) => const VerifyEmailScreen(email: ''),
    ),
  ],
);
