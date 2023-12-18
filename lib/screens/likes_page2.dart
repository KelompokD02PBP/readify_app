import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:readify_app/models/Book2.dart';
import 'package:readify_app/classes/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class LikesPage extends StatefulWidget {
  const LikesPage({super.key});

  @override
  State<LikesPage> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<LikesPage> {
  List<Book> likedBooks = [];

  Future<List<Book>> _fetchBookDetails() async {
    final request = context.read<CookieRequest>();
    final response = await request.postJson(
        "https://readify-d02-tk.pbp.cs.ui.ac.id/get-liked-books/",
        jsonEncode({
          "username": request.jsonData["username"],
          "id": request.jsonData["id"],
        }),
      );
    setState(() {
        likedBooks = List<Book>.from(
            response.map((bookJson) => Book.fromJson(bookJson)));
      });

    return likedBooks;
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
      body: 
          FutureBuilder(
            future: _fetchBookDetails(),
            builder: (context, snapshot) {
              if (snapshot.data == null) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder:(context, index) => Card(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      ListTile(
                        contentPadding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                        leading:
                            Image.network(snapshot.data![index].fields.imageUrlL),
                        title: Text("Title: ${snapshot.data![index].fields.title}"),
                        subtitle:
                            Text('Author: ${snapshot.data![index].fields.author}'),
                      ),
                    ],
                  ),
                )
                );
              }
            },
          ),
    );
  }
}
