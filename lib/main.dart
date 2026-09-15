import 'package:archivageucb/pages/upload_sceen.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'export_pages.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Supabase.initialize(
    url: 'https://ypxvrqcjlwjnebsroopv.supabase.co',
    publishableKey: 'sb_publishable_7Wioj9JkNh3eCBFt8hcMUQ_8alki7vE',
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      builder: (context, child) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Archivage des documents',
        theme: Provider.of<ThemeProvider>(context).themeData,
        home: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.userChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator.adaptive()),
              );
            }
            if (snapshot.hasData && snapshot.data!.emailVerified) {
              return const UploadScreen();
            }
            return LoginPage();
          },
        ),
      ),
    );
  }
}
