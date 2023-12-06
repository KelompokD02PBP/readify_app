import 'package:flutter/material.dart';
import 'package:readify_app/models/profile_user.dart';
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
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _emailController;

  String userName = "";
  String userAddress = "";
  String userEmail = "";
  String userProfileImage = "";

  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: userName);
    _emailController = TextEditingController(text: userEmail);
    _addressController = TextEditingController(text: userAddress);
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
      print(response["profile"]["profile_picture"]);
      setState(() {
        userName = request.jsonData["username"];
        userAddress = response["profile"]["address"];
        userEmail = response["profile"]["email"];
        
       userProfileImage = 'http://127.0.0.1:8000/${response["profile"]["profile_picture"]}';

        _nameController.text = userName;
      _emailController.text = userEmail;
      _addressController.text = userAddress;


      });
    } catch (error) {
      print('Error fetching profile: $error');
      // Handle error appropriately, e.g., show an error message
    }
  }

  void updateProfile(
    String newName,
    String newAddress,
    String newEmail,
    String newImage,
  ) {
    setState(() {
      userName = newName;
      userEmail = newEmail;
      userAddress = newAddress;
      userProfileImage = newImage;
      isEditing = false;
    });
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
                      ? Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
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
                              ),
                            ],
                          ),
                        )
                      : Column(
                          children: [
                            Text(
                              request.jsonData['username'],
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
                  const SizedBox(height: 20),
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
                      : const SizedBox(),
                  if (isEditing)
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                          Colors.white,
                        ),
                        foregroundColor: MaterialStateProperty.all<Color>(
                          Colors.black,
                        ),
                      ),
                      onPressed: () {
                        updateProfile(
                          _nameController.text,
                          _emailController.text,
                          _addressController.text,
                          userProfileImage,
                        );
                      },
                      child: Text(isEditing ? 'Save Changes' : ''),
                    ),
                ],
              ),
            ),
          ),
        ));
  }
}
