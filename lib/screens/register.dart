import 'package:flutter/material.dart';
import 'package:readify_app/classes/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:readify_app/screens/login.dart';
import 'package:http_parser/http_parser.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _password1Controller = TextEditingController();
  final TextEditingController _password2Controller = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final _imagePicker = ImagePicker();
  XFile? _imagePicked;
  Text imageName = const Text("",
      style: TextStyle(color: Color.fromARGB(179, 255, 255, 255)));

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Register',
          style: TextStyle(fontFamily: "GoogleDisplay"),
        ),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.amberAccent,
      ),
      backgroundColor: const Color.fromARGB(255, 43, 39, 49),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
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
              controller: _password1Controller,
              style: const TextStyle(color: Color.fromARGB(179, 255, 255, 255)),
              decoration: const InputDecoration(
                labelText: 'Password',
                labelStyle: TextStyle(color: Colors.amberAccent),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 12.0),
            TextField(
              controller: _password2Controller,
              style: const TextStyle(color: Color.fromARGB(179, 255, 255, 255)),
              decoration: const InputDecoration(
                labelText: 'Password confirmation',
                labelStyle: TextStyle(color: Colors.amberAccent),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 12.0),
            TextField(
              controller: _emailController,
              style: const TextStyle(color: Color.fromARGB(179, 255, 255, 255)),
              decoration: const InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(color: Colors.amberAccent),
              ),
            ),
            const SizedBox(height: 24.0),
            Wrap(
              children: <Widget>[
                const Text(
                  "Profile image: ",
                  style: TextStyle(fontSize: 16, color: Colors.amberAccent),
                ),
                imageName,
                const SizedBox(width: 24.0),
                ElevatedButton(
                  onPressed: () async {
                    XFile? imagePicked = await _imagePicker.pickImage(
                        source: ImageSource.gallery);
                    if (imagePicked == null) return;

                    debugPrint(imagePicked.path);

                    Text nextText = Text(imagePicked.name,
                        style: const TextStyle(
                            color: Color.fromARGB(179, 255, 255, 255)));

                    _imagePicked = imagePicked;
                    setState(() {
                      imageName = nextText;
                    });
                  },
                  child: const Text('Choose a picture'),
                ),
              ],
            ),
            const SizedBox(height: 24.0),
            TextField(
              controller: _addressController,
              style: const TextStyle(color: Color.fromARGB(179, 255, 255, 255)),
              decoration: const InputDecoration(
                labelText: 'Address',
                labelStyle: TextStyle(color: Colors.amberAccent),
              ),
            ),
            const SizedBox(height: 12.0),
            Wrap(children: <Widget>[
              ElevatedButton(
                onPressed: () async {
                  String username = _usernameController.text;
                  String password1 = _password1Controller.text;
                  String password2 = _password1Controller.text;
                  String email = _emailController.text;
                  String address = _addressController.text;
                  List<http.MultipartFile> files = [];

                  final imagePicked = _imagePicked;
                  if (imagePicked != null) {
                    files.add(http.MultipartFile.fromBytes(
                      "profile_picture",
                      await imagePicked.readAsBytes(),
                      contentType: MediaType.parse(imagePicked.mimeType!),
                      filename: imagePicked.name,
                    ));
                  }

                  final response = await request.postFormData(
                    "https://readify-d02-tk.pbp.cs.ui.ac.id/api/register/",
                    {
                      'username': username,
                      'password1': password1,
                      'password2': password2,
                      'email': email,
                      'address': address,
                    },
                    files,
                  );

                  bool status = response["status"];

                  if (status) {
                    String uname = response['username'];
                    if(context.mounted){
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(SnackBar(
                          content: Text("User $uname berhasil register.")));
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginPage()),
                    );

                    }
                  } else {
                    if(context.mounted){

                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Register Gagal'),
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
                child: const Text('Register'),
              ),
              const SizedBox(width: 12.0),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                },
                child: const Text('Kembali'),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}
