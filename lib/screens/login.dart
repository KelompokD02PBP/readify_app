import 'package:flutter/material.dart';
import 'package:readify_app/classes/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:readify_app/screens/register.dart';
import 'package:readify_app/screens/HomePage.dart';

void main() {
  runApp(const LoginApp());
}

class LoginApp extends StatelessWidget {
  const LoginApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Login',
          style: TextStyle(fontFamily:"GoogleDisplay"),
        ),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.amberAccent,
      ),
      backgroundColor: const Color.fromARGB(255, 43, 39, 49),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              style: const TextStyle(color: Color.fromARGB(179, 255, 255, 255)),
              decoration: const InputDecoration(
                labelText: 'Username',
                labelStyle: TextStyle(color: Colors.amberAccent),
              ),
            ),
            const SizedBox(height: 12.0),
            TextField(
              controller: _passwordController,
              style: const TextStyle(
                color: Color.fromARGB(179, 255, 255, 255),
              ),
              decoration: const InputDecoration(
                labelText: 'Password',
                labelStyle: TextStyle(color: Colors.amberAccent),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 24.0),
            Row(children: <Widget>[
              ElevatedButton(
                onPressed: () async {
                  String username = _usernameController.text;
                  String password = _passwordController.text;

                  // Cek kredensial
                  // Ganti URL dan jangan lupa tambahkan trailing slash (/) di akhir URL!
                  // Untuk menyambungkan Android emulator dengan Django pada localhost,
                  // gunakan URL http://10.0.2.2/
                  final response = await request.login(
                      "https://readify-d02-tk.pbp.cs.ui.ac.id/api/login/", {
                    'username': username,
                    'password': password,
                  });

                  if (request.loggedIn) {
                    String message = response['message'];
                    String uname = response['username'];
                    if (context.mounted) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const MyHomePage()),
                      );
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(SnackBar(
                            content: Text("$message Selamat datang, $uname.")));
                    }
                  } else {
                    if (context.mounted) {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Login Gagal'),
                          content: Text(response['message']),
                          actions: [
                            TextButton(
                              child: const Text('OK'),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        ),
                      );
                    }
                  }
                },
                child: const Text('Login'),
              ),
              const SizedBox(width: 12.0),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const RegisterPage()),
                  );
                },
                child: const Text('Register'),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}
