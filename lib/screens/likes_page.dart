import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LikesPage extends StatefulWidget {
  final String username;

  const LikesPage({Key? key, required this.username}) : super(key: key);

  @override
  _LikesPageState createState() => _LikesPageState();
}

class _LikesPageState extends State<LikesPage> {
  List<dynamic> likedBooks = [];

  @override
  void initState() {
    super.initState();
    _fetchLikedBooks();
  }

  Future<void> _fetchLikedBooks() async {
    final apiUrl = Uri.parse('https://readify-d02-tk.pbp.cs.ui.ac.id/likes/');
    final likesResponse = await http.get(apiUrl);

    if (likesResponse.statusCode == 200) {
      print(likesResponse.body);
      setState(() {
        likedBooks = json.decode(likesResponse.body);
      });
    } else {
      print(
          'Failed to fetch liked books. Status code: ${likesResponse.statusCode}');
      print('Response body: ${likesResponse.body}');
    }
  }

  Future<Map<String, dynamic>> _fetchBookDetails(int bookId) async {
    final bookDetailsUrl =
        Uri.parse('https://readify-d02-tk.pbp.cs.ui.ac.id/katalog/get-books-json-by-pk/$bookId');
    final bookDetailsResponse = await http.get(bookDetailsUrl);

    if (bookDetailsResponse.statusCode == 200) {
      final List<dynamic> responseData = json.decode(bookDetailsResponse.body);
      if (responseData.isNotEmpty) {
        return responseData.first;
      }
    }

    print(
        'Failed to fetch book details. Status code: ${bookDetailsResponse.statusCode}');
    print('Response body: ${bookDetailsResponse.body}');
    return {};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Readify - Liked Books',
          style: TextStyle(fontFamily: "GoogleDisplay"),
        ),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.amberAccent,
      ),
      backgroundColor: const Color.fromARGB(255, 43, 39, 49),
      body: ListView.builder(
        itemCount: likedBooks.length,
        itemBuilder: (context, index) {
          final likedBook = likedBooks[index];
          return FutureBuilder<Map<String, dynamic>>(
            future: _fetchBookDetails(likedBook['book']),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                final bookDetails = snapshot.data ?? {};
                return Card(
                  margin: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      ListTile(
                        contentPadding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                        leading:
                            Image.network(bookDetails['fields']['image_url_l']),
                        title: Text("Title: ${bookDetails['fields']['title']}"),
                        subtitle:
                            Text('Author: ${bookDetails['fields']['author']}'),
                      ),
                    ],
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }
}
