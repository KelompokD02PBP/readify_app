import 'package:flutter/material.dart';
import 'package:readify_app/models/Book2.dart';
import 'package:readify_app/models/Comment.dart';
import 'package:readify_app/widgets/Drawer2.dart';
import 'package:readify_app/classes/pbp_django_auth.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class PerBook extends StatefulWidget {
  final Book book;
  const PerBook({super.key, required this.book});

  @override
  State<PerBook> createState() => _PerBookState();
}

class _PerBookState extends State<PerBook> {
  bool isLiked = false;
  bool isLoading = false;
  var _numOfLike = 0;
  List<Comment> _comments = [];
  String? _comment = "";
  final fieldText = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_)async{
      updateNumLike();
      await checkIsLike();
      await getComments();
      setState(() {});
    });
    // setState(() {});
  }

  Future<void> getComments() async {
    isLoading = true;
    print("idBook${widget.book.pk}");
    var response = await http.get(
      Uri.parse(
          "https://readify-d02-tk.pbp.cs.ui.ac.id/get-comment-flutter/${widget.book.pk}"),
    );
    var data = jsonDecode(utf8.decode(response.bodyBytes));
    _comments = [];
    for (var d in data) {
      if (d != null) {
        _comments.add(Comment.fromJson(d));
      }
    }

    for (var c in _comments) {
      final request = context.read<CookieRequest>();
      var response2 = await request.postJson(
        "https://readify-d02-tk.pbp.cs.ui.ac.id/get-username/",
        jsonEncode({
          "idUser": c.fields.user,
        }),
      );
      c.fields.name = response2["username"][0];
    }
    isLoading = false;
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
  }

  Future<void> checkIsLike() async {
    var doesLike = await fetchIsLike();
    if (doesLike == 1) {
      print("prior like");
      isLiked = true;
    } else {
      print("prior dislike");
      isLiked = false;
    }
  }

  Future<int> fetchIsLike() async {
    final request = context.read<CookieRequest>();
    print("idBook ${widget.book.pk}");
    final response = await request.postJson(
      "https://readify-d02-tk.pbp.cs.ui.ac.id/like-dislike-flutter/",
      jsonEncode({
        "idBook": widget.book.pk,
        "idUser": request.jsonData["id"],
      }),
    );
    print("islike ${response["like"]}");
    return response["like"];
  }

  Future<void> addLike() async {
    final request = context.read<CookieRequest>();
    final response = await request.postJson(
      "https://readify-d02-tk.pbp.cs.ui.ac.id/add-like-flutter/",
      jsonEncode({
        "idBook": widget.book.pk,
        "idUser": request.jsonData["id"],
      }),
    );
    print("addlike ${response["message"]}");
  }

  Future<void> addComment() async {
    final request = context.read<CookieRequest>();
    print("idUser${request.jsonData["id"]}");
    final response = await request.postJson(
      "https://readify-d02-tk.pbp.cs.ui.ac.id/add-comment-flutter/",
      jsonEncode({
        "idBook": widget.book.pk,
        "idUser": request.jsonData["id"],
        "comment": _comment,
      }),
    );
    print("status add com" + response["status"]);
    _comment = "";
  }

  Future<int> updateNumLike() async {
    final request = context.read<CookieRequest>();
    final response = await request.postJson(
      "https://readify-d02-tk.pbp.cs.ui.ac.id/see-like-flutter/",
      jsonEncode({
        "idBook": widget.book.pk,
      }),
    );
    print("updatelike ${response["like"]}");
    _numOfLike = response["like"];
    return response["like"];
  }

  @override
  Widget build(BuildContext context) {
    String imageUrl = widget.book.fields.imageUrlM;
    imageUrl = imageUrl
        .replaceAll("http://", "https://")
        .replaceAll("images.amazon", "m.media-amazon");

    return Scaffold(
      drawer: const EndDrawer(),
      appBar: AppBar(
        title: const Text(
          'Readify',
          style: TextStyle(fontFamily: "GoogleDisplay"),
        ),
        backgroundColor: const Color.fromARGB(255, 43, 39, 49),
        foregroundColor: Colors.amberAccent,
      ),
      backgroundColor: const Color.fromARGB(255, 43, 39, 49),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.network(
                    imageUrl,
                    width: 120,
                    height: 180,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.book.fields.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.amberAccent,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Publisher: ${widget.book.fields.publisher}',
                          style: const TextStyle(color: Colors.white),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'ISBN: ${widget.book.fields.isbn}',
                          style: const TextStyle(color: Colors.white),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            IconButton(
                              onPressed: () async {
                                await addLike();
                                await updateNumLike();
                                setState(() {
                                  isLiked = !isLiked;
                                });
                              },
                              icon: Icon(
                                isLiked
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                              ),
                              color: isLiked ? Colors.red : null,
                            ),
                            const SizedBox(width: 8),
                            isLoading
                                ? const SizedBox(
                                    width: 20, 
                                    height: 20, 
                                    child: CircularProgressIndicator(
                                      strokeWidth:
                                          2, 
                                    ),
                                  )
                                : Text(
                                    "$_numOfLike",
                                    style: const TextStyle(
                                      color: Color.fromARGB(179, 255, 255, 255),
                                    ),
                                  ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          autocorrect: true,
                          style: const TextStyle(
                            color: Color.fromARGB(179, 164, 164, 164),
                          ),
                          decoration: const InputDecoration(
                            hintStyle: TextStyle(
                              color: Color.fromARGB(97, 255, 255, 255),
                            ),
                            hintText: "Lorem Ipsum",
                            labelText: "Comment here",
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
                          child: const Text("Comment"),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const ScrollPhysics(),
                      itemCount: _comments.length,
                      itemBuilder: (context, index) {
                        String formattedDate =
                            "${_comments[index].fields.createdOn.year}/${_comments[index].fields.createdOn.month.toString().padLeft(2, '0')}/${_comments[index].fields.createdOn.day.toString().padLeft(2, '0')}";

                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Card(
                            color: Colors.grey[900],
                            elevation: 3,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
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
                                      Text(
                                        formattedDate,
                                        style: const TextStyle(
                                          color: Colors.grey,
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
      ),
    );
  }
}