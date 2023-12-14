import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:readify_app/screens/HomePage.dart';
import 'package:readify_app/screens/profile.dart';
import '../classes/pbp_django_auth.dart';
import '../screens/login.dart';

class EndDrawer extends StatelessWidget {
  const EndDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
              decoration: BoxDecoration(
              color: Color.fromARGB(255, 56, 30, 103),
            ),
            child: Column(
              children: [
                Text(
                  'Readify',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Padding(padding: EdgeInsets.all(10)),
                Text("Review Buku!",
                    textAlign: TextAlign.center,
                    style: TextStyle(color:Colors.white, fontSize: 15),
                    ),
              ],
            ),
          ),
          
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: const Text('Halaman Utama'),
            // Bagian redirection ke MyHomePage
            onTap: () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MyHomePage(),
                  ));
              },
          ),
          ListTile(
              leading: const Icon(Icons.shopping_basket),
              title: const Text('Profile'),
              onTap: () {
                  Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                  );
              },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () async {
              // Ganti URL dan jangan lupa tambahkan trailing slash (/) di akhir URL!
              final response = await request.logout("https://readify-d02-tk.pbp.cs.ui.ac.id/api/logout/");

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
          ),
        ],
      ),
    );
  }
}