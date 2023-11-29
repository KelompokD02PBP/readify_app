import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:readify_app/screens/login.dart';


void main() {
  runApp(const LogoutApp());
}

class LogoutApp extends StatelessWidget {
  const LogoutApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Logout',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LogoutPage(),
    );
  }
}

class LogoutPage extends StatefulWidget {
  const LogoutPage({super.key});

  @override
  _LogoutPageState createState() => _LogoutPageState();
}

class _LogoutPageState extends State<LogoutPage> {
  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Logout'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("aeoijfef"),
            const SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: () async {
                // Ganti URL dan jangan lupa tambahkan trailing slash (/) di akhir URL!
                final response = await request.logout("http://localhost:8000/api/logout/");

                String message = response["message"];
                if (response['status']) {
                  String uname = response["username"];
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text("$message Sampai jumpa, $uname."),
                  ));
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text("$message"),
                  ));
                }
              },
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}