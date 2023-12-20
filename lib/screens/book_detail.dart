import 'package:flutter/material.dart';
import 'package:readify_app/models/Book2.dart';
import 'package:readify_app/widgets/book_card.dart';
import 'package:readify_app/widgets/Drawer2.dart';
import 'package:readify_app/models/comment2.dart';
import 'package:http/http.dart' as http;
import 'package:readify_app/classes/pbp_django_auth.dart';
import 'dart:convert';
import 'package:provider/provider.dart';

class BookDetail extends StatefulWidget {
  final Book book;
  const BookDetail({Key? key, required this.book}) : super(key: key);

  @override
  _BookDetailState createState() => _BookDetailState();
}

class _BookDetailState extends State<BookDetail> {
  final _formKey = GlobalKey<FormState>();
  List<Comment> _comments = [];
  String _comment = "";
  bool loading = false;
  final fieldText = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await getComments();
      setState(() {});
    });

  }

  Future<void> getComments() async {
    loading = true;
    var res = await http.get(
      Uri.parse(
          "http://localhost:8000/get-comments-flutter/${widget.book.pk}"),
    );

    var data = jsonDecode(utf8.decode(res.bodyBytes));
    _comments = [];
    for (var d in data) {
      if (d != null) {
        _comments.add(Comment.fromJson(d));
      }
    }

    for (var com in _comments) {
      final request = context.read<CookieRequest>();
      var response = await request.postJson(
        "http://localhost:8000/get-username/",
        jsonEncode({
          "idUser": com.fields.user,
        }),
      );
      com.fields.name = response["username"][0];
    }

    loading = false;
    WidgetsBinding.instance!.addPostFrameCallback((_) => setState(() {}));
  }

  Future<void> addComment() async {
    final request = context.read<CookieRequest>();
    print("idUser${request.jsonData["id"]}");
    final response = await request.postJson(
      "http://localhost:8000/add-comment-flutter/",
      jsonEncode({
        "idBook": widget.book.pk,
        "idUser": request.jsonData["id"],
        "comment": _comment,
      }),
    );
    print("status add com" + response["status"]);
    _comment = "";
  }

  @override
  Widget build(BuildContext context) {
    String imageUrl = widget.book.fields.imageUrlL;
    imageUrl = imageUrl.replaceAll("http://", "https://").replaceAll("images.amazon", "m.media-amazon");

    return Scaffold(
      appBar: AppBar(
          title: const Text(
            'Readify',
            style: TextStyle(fontFamily: "GoogleDisplay"),
          ),
          backgroundColor: Colors.black87,
          foregroundColor: Colors.amberAccent,
        ),
        // backgroundColor: const Color.fromARGB(255, 43, 39, 49),
        drawer: const EndDrawer(),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Book Detail',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Image.network(
                    imageUrl,
                    width: 300,
                    height: 400,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'ISBN: ${widget.book.fields.isbn}',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      widget.book.fields.title,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Published in ${widget.book.fields.yearOfPublish}',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                  TextFormField(
                    autocorrect: true,
                    style: const TextStyle(
                      color: Color.fromARGB(179, 164, 164, 164),
                    ),
                    decoration: const InputDecoration(
                      hintStyle: TextStyle(
                        color: Color.fromARGB(97, 255, 255, 255),
                      ),
                      labelText: "Write a comment",
                      labelStyle: TextStyle(color: Colors.amberAccent),
                    ),
                    onChanged: (String? values) {
                      setState(() {
                        _comment = values!;
                      });
                    },
                    controller: fieldText,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter some text';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      await addComment();
                      fieldText.clear();
                      await getComments();
                      setState(() {
                        _comment = "";
                      });
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.amberAccent),
                    ),
                    child: const Text(
                      "Post Comment",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const ScrollPhysics(),
                    itemCount: _comments.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Card(
                          color: Colors.grey[900],
                          elevation: 3,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "${_comments[index].fields.name}",
                                      style: const TextStyle(
                                        color: Colors.amberAccent,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _comments[index].fields.comment,
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}