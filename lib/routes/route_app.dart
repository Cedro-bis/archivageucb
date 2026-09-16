import 'package:archivageucb/export_pages.dart';
import 'package:archivageucb/pages/doc_academ.dart';
import 'package:archivageucb/pages/doc_admin.dart';
import 'package:archivageucb/pages/doc_etudiants.dart';
import 'package:archivageucb/pages/doc_finance.dart';
import 'package:archivageucb/pages/livres.dart';
import 'package:archivageucb/pages/travaux.dart';
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
    GoRoute(path: '/docadmin', builder: (context, state) => const DocAdmin()),
    GoRoute(path: '/docetu', builder: (context, state) => const DocEtudiants()),
    GoRoute(path: '/docacad', builder: (context, state) => const DocAcadem()),
    GoRoute(path: '/travaux', builder: (context, state) => const Travaux()),
    GoRoute(path: '/docfina', builder: (context, state) => const DocFinance()),
    GoRoute(path: '/livres', builder: (context, state) => const Livres()),
  ],
);
