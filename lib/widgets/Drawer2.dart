import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:readify_app/screens/HomePage.dart';
import 'package:readify_app/screens/likes_page2.dart';
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
               color: Colors.amberAccent,
            ),
            child: Column(
              children: [
                Text(
                  'Readify',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Padding(padding: EdgeInsets.all(10)),
                Text(
                  "Review Buku!",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black87, fontSize: 15),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.account_circle_outlined),
            title: const Text('Profile'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
            },
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
            leading: const Icon(Icons.favorite_border_sharp),
            title: const Text('Disukai'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LikesPage(), // Ganti 'jeje' dengan username yang sesuai
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () async {
              /*
              * Entah kenapa kadang ngebug bisa return ke homePage abis logout
              */
              Navigator.of(context).popUntil((route) => route.isFirst); 
              // Ganti URL dan jangan lupa tambahkan trailing slash (/) di akhir URL!
              final response = await request
                  .logout("https://readify-d02-tk.pbp.cs.ui.ac.id/api/logout/");

              String message = response["message"];
              if (response['status']) {
                String uname = response["username"];
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text("$message Sampai jumpa, $uname."),
                  ));
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                }
              } else {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(message),
                  ));
                }
              }
              
            },
          )
        ],
      ),
    );
  }
}