import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:readify_app/classes/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:readify_app/screens/login.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    /*
    biar gk bisa rotate app
    */
    // SystemChrome.setPreferredOrientations([
    //   DeviceOrientation.portraitUp,
    //   DeviceOrientation.portraitDown
    // ]);
    return Provider(
      create: (_) {
        CookieRequest request = CookieRequest();
        return request;
      },
      child: MaterialApp(
          title: 'Flutter App',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
            useMaterial3: true,
          ),
          home: const LoginPage(),
      ),
    );
  }
}
