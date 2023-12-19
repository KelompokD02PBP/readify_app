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
  var _numOfLike=0;
  List<Comment> _comments = [];
  String? _comment="";
  final fieldText = TextEditingController();

  @override
  void initState() {
    print("initState");
    super.initState();
    updateNumLike();
    checkIsLike();
    getComments();
    // setState(() {});
  }

  Future<void> getComments() async{
    print("idBook${widget.book.pk}");
    var response = await http.get(Uri.parse("https://readify-d02-tk.pbp.cs.ui.ac.id/get-comment-flutter/${widget.book.pk}"),);
    var data = jsonDecode(utf8.decode(response.bodyBytes));
    print("comment$data");
    _comments=[];
    for (var d in data) {
      if (d != null) {
          _comments.add(Comment.fromJson(d));
      }
    }

    for(var c in _comments){
      final request = context.read<CookieRequest>();
      var response2 = await request.postJson(
        "https://readify-d02-tk.pbp.cs.ui.ac.id/get-username/",
        jsonEncode({
          "idUser": c.fields.user,
        }),
      );
      c.fields.name=response2["username"][0];
      print(c.fields.name);
    }
    
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
  }

  void checkIsLike() async{
    var doesLike = await fetchIsLike();
    if(doesLike==1){
      print("prior like");
      isLiked=true;
    }else{
      print("prior dislike");
      isLiked=false;
    }
  }

  Future<int> fetchIsLike() async{
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

  Future<void> addLike() async{
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

  Future<void> addComment() async{
    final request = context.read<CookieRequest>();
    print("idUser${request.jsonData["id"]}");
    final response = await request.postJson(
      "https://readify-d02-tk.pbp.cs.ui.ac.id/add-comment-flutter/",
      jsonEncode({
        "idBook": widget.book.pk,
        "idUser": request.jsonData["id"],
        "comment":_comment,
      }),
    );
    print("status add com"+response["status"]);
    _comment="";
  }
  
  Future<int> updateNumLike() async{
    final request = context.read<CookieRequest>();
    final response = await request.postJson(
      "https://readify-d02-tk.pbp.cs.ui.ac.id/see-like-flutter/",
      jsonEncode({
        "idBook": widget.book.pk,
      }),
    );
    print("updatelike ${response["like"]}");
    _numOfLike=response["like"];
    return response["like"];
  }

  @override
  Widget build(BuildContext context) {

    String imageUrl = widget.book.fields.imageUrlM;
    imageUrl = imageUrl.replaceAll("http://", "https://").replaceAll("images.amazon", "m.media-amazon");
    return Scaffold(
      drawer: EndDrawer(),
      appBar: AppBar(
        title: const Text(
          'Readify',
          style: TextStyle(fontFamily:"GoogleDisplay"),
        ),
        backgroundColor: const Color.fromARGB(255, 43, 39, 49),
        foregroundColor: Colors.amberAccent,
      ),
      backgroundColor: const Color.fromARGB(255, 43, 39, 49),
      body: Column(
        children:[
          Image.network(imageUrl),
          Text(widget.book.fields.isbn),
          Text(widget.book.fields.title),
          Text(widget.book.fields.publisher),
          Row(
              children: [
                IconButton(
                  onPressed: () async{
                    await addLike();
                    await updateNumLike();
                    setState(()  {
                      isLiked = !isLiked;
                    });
                  },
                  icon: Icon(isLiked ? Icons.favorite : Icons.favorite_border),
                  color: isLiked ? Colors.red : null,
                ),
                Text("$_numOfLike",style: TextStyle(color: Color.fromARGB(179, 255, 255, 255),)),
              ],
            ),
            TextField(
              autocorrect: true,
              style: const TextStyle(color: Color.fromARGB(179, 164, 164, 164),),
              decoration:  const InputDecoration(
                hintStyle: TextStyle(color: Color.fromARGB(97, 255, 255, 255),),
                hintText: "Lorem Ipsum",
                labelText: "Comment here",
                labelStyle: TextStyle(color: Colors.amberAccent),
              ),
              onChanged: (String? values){
                  setState(() {
                  _comment = values!;
                });
                getComments();
              },
              controller: fieldText,
            ),
            ElevatedButton(
                onPressed: () async{
                  await addComment();
                  fieldText.clear();
                  await getComments();
                  setState(() {_comment="";});
                },
                child: const Text("Comment")
            ),
            Expanded(child: 
              ListView.builder(
                itemCount: _comments.length,
                itemBuilder: (context, index) {
                  return
                  Column(
                    children:[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text("${_comments[index].fields.name}", style: TextStyle(color: Color.fromARGB(179, 255, 255, 255), fontWeight: FontWeight.bold),),
                              Text("${_comments[index].fields.createdOn}", style: TextStyle(color: Color.fromARGB(179, 255, 255, 255),fontSize: 10),),
                            ],
                          ),
                          Text(_comments[index].fields.comment, style: TextStyle(color: Color.fromARGB(179, 255, 255, 255),),),
                        ],
                      ),
                      SizedBox(height: 12,)
                    ],
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}