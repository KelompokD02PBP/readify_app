import 'package:flutter/material.dart';
import 'package:readify_app/widgets/carousel.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  static const routeName = '/profile';

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _emailController;

  String userName = 'Venedict Chen';
  String userEmail = 'venedictchen@.com';
  String userAddress = 'Jl. Raya Bogor KM 30, Depok, Jawa Barat';
  String userProfileImage = 'assets/profile_picture.png';

  final List<String> onlineImages = [
    'data:image/jpeg;base64,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',
    'https://cdn.pixabay.com/photo/2015/04/23/22/00/tree-736885_1280.jpg'
        'data:image/jpeg;base64,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',
  ];

  int currentImageIndex = 0;

  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: userName);
    _emailController = TextEditingController(text: userEmail);
    _addressController = TextEditingController(text: userAddress);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Center(
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
                    backgroundImage: AssetImage(userProfileImage),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        isEditing = !isEditing;
                      });
                    },
                    icon: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          isEditing ? Icons.camera_alt_rounded : Icons.edit,
                          color: Colors.indigo,
                        ),
                      ),
                    ),
                    tooltip: isEditing ? 'Save Changes' : 'Edit Profile',
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
                              border: OutlineInputBorder(),
                            ),
                          ),
                          TextFormField(
                            controller: _addressController,
                            decoration: const InputDecoration(
                              labelText: 'Address',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        Text(
                          userName,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          userAddress,
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          userEmail,
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
              const SizedBox(height: 40),
              !isEditing
                  ? const Column(
                      children: [
                        Text(
                          'My Liked Books',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Carousel()
                      ],
                    )
                  : const SizedBox(),
              ElevatedButton(
                onPressed: () {
                  if (isEditing) {
                    updateProfile(
                      _nameController.text,
                      _emailController.text,
                      _addressController.text,
                      userProfileImage,
                    );
                  }
                },
                child: Text(isEditing ? 'Save Changes' : ''),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
