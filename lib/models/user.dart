import 'dart:convert';
import 'package:http/http.dart' as http;

class User {
  late int id;
  late String? username;

  User({required this.id, required this.username});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(id: json['id'], username: json['username']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'id': id,
      'username': username,
    };
    return data;
  }
}

class UserService {
  static Future<User> fetchUser(String username) async {
    final apiUrl = Uri.parse('https://readify-d02-tk.pbp.cs.ui.ac.id/userapi/$username/');

    final response = await http.get(apiUrl);

    if (response.statusCode == 200) {
      final Map<String, dynamic> userData = json.decode(response.body);
      return User.fromJson(userData);
    } else {
      throw Exception('Failed to load user data');
    }
  }
}
