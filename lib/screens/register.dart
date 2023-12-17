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
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _password1Controller = TextEditingController();
  final TextEditingController _password2Controller = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final _imagePicker = ImagePicker();
  XFile? _imagePicked;
  Text imageName = const Text("");

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
              ),
            ),
            const SizedBox(height: 12.0),
            TextField(
              controller: _password1Controller,
              decoration: const InputDecoration(
                labelText: 'Password',
              ),
              obscureText: true,
            ),
            const SizedBox(height: 12.0),
            TextField(
              controller: _password2Controller,
              decoration: const InputDecoration(
                labelText: 'Password confirmation',
              ),
              obscureText: true,
            ),
            const SizedBox(height: 12.0),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
              ),
            ),
            const SizedBox(height: 24.0),
            Wrap(
              children: <Widget>[
                const Text("Profile image: "),
                imageName,
                const SizedBox(width: 24.0),
                ElevatedButton(
                  onPressed: () async {
                    XFile? imagePicked = await _imagePicker.pickImage(
                        source: ImageSource.gallery);
                    if (imagePicked == null) return;

                    debugPrint(imagePicked.path);

                    Text nextText = Text(imagePicked.name);

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
              decoration: const InputDecoration(
                labelText: 'Address',
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

                  //untuk dev gunakan http://localhost:8000/api/register/
                  final response = await request.postFormData(
                    "http://localhost:8000/api/register",
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
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(SnackBar(
                          content: Text("User $uname berhasil register.")));
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  } else {
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
                },
                child: const Text('Register'),
              ),
              const SizedBox(width: 12.0),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
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
