import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:readify_app/classes/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:readify_app/widgets/carousel.dart';
import 'dart:convert';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;

  String userName = "";
  String userPassword = "";
  String userAddress = "";
  String userEmail = "";
  String userProfileImage = "";
  final _imagePicker = ImagePicker();
  XFile? _imagePicked;
  Text imageName = const Text(
    "",
    style: TextStyle(color: Colors.white),
  );

  bool isEditing = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: userName);
    _emailController = TextEditingController(text: userEmail);
    _addressController = TextEditingController(text: userAddress);
    _passwordController = TextEditingController(text: userPassword);
    fetchProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> fetchProfile() async {
    try {
      final request = context.read<CookieRequest>();
      final response = await request.postJson(
        "http://127.0.0.1:8000/show_profile_flutter/",
        jsonEncode({
          "username": request.jsonData["username"],
          "id": request.jsonData["id"],
        }),
      );

      setState(() {
        userName = request.jsonData["username"];
        userAddress = response["profile"]["address"];
        userEmail = response["profile"]["email"];
        userPassword = request.jsonData["password"];

        if (response["profile"]["pp_exist"] == false) {
          userProfileImage = 'assets/images/anon.png';
        } else {
          userProfileImage =
              'http://127.0.0.1:8000/${response["profile"]["profile_picture"]}';
        }
        _nameController.text = userName;
        _emailController.text = userEmail;
        _addressController.text = userAddress;
        _passwordController.text = userPassword;
      });
    } catch (error) {
      debugPrint('Error fetching profile: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    debugPrint(request.jsonData.toString());
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text('Profile'),
          titleTextStyle: const TextStyle(
            color: Color.fromRGBO(236, 190, 23, 1.0),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          backgroundColor: Colors.black,
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 40.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: userProfileImage.isNotEmpty
                            ? NetworkImage(userProfileImage)
                            : null,
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            isEditing = !isEditing;
                          });
                        },
                        icon: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Icon(
                              isEditing ? Icons.camera_alt_rounded : Icons.edit,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  isEditing
                      ? Form(
                        key: _formKey,
                        child:SingleChildScrollView(
                          child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(children: [
                            TextFormField(
                              controller: _nameController,
                              decoration: const InputDecoration(
                                labelText: 'Username',
                                labelStyle: TextStyle(
                                  color: Colors.white,
                                ),
                                border: OutlineInputBorder(),
                              ),
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                              validator: (String?value){
                                if(value==null||value.isEmpty){
                                  return 'Username is required';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 10),
                            TextFormField(
                              controller: _passwordController,
                              decoration: const InputDecoration(
                                labelText: 'Password',
                                labelStyle: TextStyle(
                                  color: Colors.white,
                                ),
                                border: OutlineInputBorder(),
                              ),
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                              validator: (String? value){
                                if(value==null||value.isEmpty){
                                  return 'Password is required';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 10),
                            TextFormField(
                              controller: _addressController,
                              decoration: const InputDecoration(
                                labelText: 'Address',
                                labelStyle: TextStyle(
                                  color: Colors.white,
                                ),
                                border: OutlineInputBorder(),
                              ),
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                              validator: (String? value){
                                if(value==null||value.isEmpty){
                                  return 'Address is required';
                                }
                              
                              

                                return null;
                              },
                            ),
                            const SizedBox(height: 10),
                            TextFormField(
                              controller: _emailController,
                              decoration: const InputDecoration(
                                labelText: 'Email',
                                labelStyle: TextStyle(
                                  color: Colors.white,
                                ),
                                border: OutlineInputBorder(),
                              ),
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                              validator: (String? value){
                                if(value==null||value.isEmpty){
                                  return 'Email is required';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            Column(
                              children: [
                                const Text(
                                  "Profile image: ",
                                  style: TextStyle(color: Colors.white),
                                ),
                                const SizedBox(height: 10.0),
                                imageName,
                                const SizedBox(height: 10.0),
                                ElevatedButton(
                                  style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                      Colors.white,
                                    ),
                                    foregroundColor:
                                        MaterialStateProperty.all<Color>(
                                      Colors.black,
                                    ),
                                  ),
                                  onPressed: () async {
                                    XFile? imagePicked = await _imagePicker
                                        .pickImage(source: ImageSource.gallery);
                                    if (imagePicked == null) return;

                                    debugPrint(imagePicked.path);

                                    Text nextText = Text(imagePicked.name,
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ));

                                    _imagePicked = imagePicked;
                                    setState(() {
                                      imageName = nextText;
                                    });
                                  },
                                  child: const Text('Choose a picture'),
                                ),
                              ],
                            ),
                          ]),
                        ),
                        )
                      )
                      : Column(
                          children: [
                            Text(
                              userName,
                              style: const TextStyle(
                                fontSize: 24,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              userAddress,
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              userEmail,
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                  const SizedBox(height: 10),
                  !isEditing
                      ? const Column(
                          children: [
                            Text(
                              'My Liked Books',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 10),
                            Carousel(),
                            SizedBox(height: 10),
                          ],
                        )
                      : isLoading
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : const SizedBox(
                              height: 10,
                            ),
                  if (isEditing && !isLoading)
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                          Colors.white,
                        ),
                        foregroundColor: MaterialStateProperty.all<Color>(
                          Colors.black,
                        ),
                      ),
                      onPressed: () async {
                        if (!_formKey.currentState!.validate()) {
                          return;
                        }
                        setState(() {
                          isLoading = true;
                        });
                        String username = _nameController.text;
                        String password = _passwordController.text;

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
                        isLoading = true;

                        final response = await request.postFormData(
                          "http://localhost:8000/update-profile/",
                          {
                            'id': request.jsonData['id'].toString(),
                            'username': username,
                            'password': password,
                            'email': email,
                            'address': address,
                          },
                          files,
                        );
                        print(response);
                        setState(() {
                          isLoading = false;
                        });

                        if (response['status'] == "success") {
                          if (context.mounted) {
                            userName = response["profile"]["username"];
                            userAddress = response["profile"]["address"];
                            userEmail = response["profile"]["email"];
                            userPassword = response["profile"]["password"];
                            userProfileImage =
                                response["profile"]["profile_picture"];
                            if (response["profile"]["pp_exist"] == false) {
                              userProfileImage = 'assets/images/anon.png';
                            } else {
                              userProfileImage =
                                  'http://127.0.0.1:8000/${response["profile"]["profile_picture"]}';
                            }

                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Update Berhasil'),
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
                            setState(() {
                              userName = userName;
                              userPassword = userPassword;
                              userEmail = email;
                              userAddress = address;
                              userProfileImage = userProfileImage;
                              isEditing = false;
                            });
                          }
                        } else {
                          if (context.mounted) {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Update Gagal'),
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
                      child: isEditing && !isLoading
                          ? const Text('Save Changes')
                          : null,
                    ),
                ],
              ),
            ),
          ),
        ));
  }
}
