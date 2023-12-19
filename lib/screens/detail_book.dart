import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:readify_app/models/Book2.dart';
import 'package:readify_app/models/user.dart';
import 'package:readify_app/models/Comment.dart';
import 'package:readify_app/classes/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class BookDetail extends StatefulWidget {
  final Book book;

  final String uname;
  const BookDetail({Key? key, required this.book, required this.uname})
      : super(key: key);

  @override
  _BookDetailState createState() => _BookDetailState();
}

class _BookDetailState extends State<BookDetail> {
  late User user;
  bool isLiked = false;
  List<Comment> _comments = [];
  String? _comment="";
  final fieldText = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_)async{
      _loadUserData();
      await checkIsLike();
      await getComments();
      setState(() {});
    });
  }

  Future<void> _loadUserData() async {
    try {
      final request = context.read<CookieRequest>();
      final username = request.jsonData["username"];
      final loadedUser = await UserService.fetchUser(username);

      setState(() {
        user = loadedUser;
        checkIsLike();
        // Set nilai awal isLiked saat user data sudah dimuat
      });
    } catch (error) {
      print('Error fetching user data: $error');
    }
  }

  // Fungsi untuk mengecek apakah buku dan pengguna sudah disukai
  Future<void> checkIsLike() async{
    var doesLike = await fetchIsLike();
    if(doesLike==1){
      isLiked=true;
    }else{
      isLiked=false;
    }
  }

  Future<int> fetchIsLike() async{
    final request = context.read<CookieRequest>();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Readify - ${widget.book.fields.title}',
          style: TextStyle(fontFamily: "GoogleDisplay"),
        ),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.amberAccent,
      ),
      backgroundColor: const Color.fromARGB(255, 43, 39, 49),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kolom pertama (gambar cover)
            Expanded(
              child: Image.network(
                widget.book.fields.imageUrlL.replaceAll("http://", "https://").replaceAll("images.amazon", "m.media-amazon"),
                fit: BoxFit.contain,
              ),
            ),
            // Kolom kedua (detail buku)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min, // Sesuaikan ukuran konten
                  children: [
                    Text(
                      'Judul: ${widget.book.fields.title}',
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8), // Jarak antara judul dan penulis
                    Text(
                      'Penulis: ${widget.book.fields.author}',
                      style: TextStyle(fontSize: 14, color: Colors.white),
                    ),
                    Text(
                      'ISBN: ${widget.book.fields.isbn}',
                      style: TextStyle(fontSize: 14, color: Colors.white),
                    ),
                    Text(
                      'Publisher: ${widget.book.fields.publisher}',
                      style: TextStyle(fontSize: 14, color: Colors.white),
                    ),
                    Text(
                      'Tahun Terbit: ${widget.book.fields.yearOfPublish}',
                      style: TextStyle(fontSize: 14, color: Colors.white),
                    ),
                    SizedBox(height: 12), // Jarak

                    // Tombol sukai buku
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: isLiked
                            ? MaterialStateProperty.all(
                                Colors.amberAccent) // Gaya fill jika disukai
                            : MaterialStateProperty.all(Colors
                                .transparent), // Gaya outlined jika tidak disukai
                        side: MaterialStateProperty.all(
                          BorderSide(
                            color: Colors.amberAccent,
                            width: 2.0,
                          ),
                        ),
                      ),
                      onPressed: () async{
                            if (user != null) {
                              await addLike();
                              setState(() {
                                isLiked = !isLiked;
                              });
                            } else {
                              print('User data is not initialized yet.');
                            }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isLiked
                                ? Icons.thumb_up
                                : Icons.thumb_up_alt_outlined,
                            color: isLiked ? Colors.white : Colors.amberAccent,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Like',
                            style: TextStyle(
                              color:
                                  isLiked ? Colors.white : Colors.amberAccent,
                            ),
                          ),
                        ],
                      ),
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
                                  Align(
                                    alignment: Alignment.topLeft,
                                    child:
                                    Wrap(
                                      children: [
                                        Text("${_comments[index].fields.name}", style: TextStyle(color: Color.fromARGB(179, 255, 255, 255), fontWeight: FontWeight.bold),),
                                        Text("${_comments[index].fields.createdOn.toString().substring(0,10)}", style: TextStyle(color: Color.fromARGB(179, 255, 255, 255),fontSize: 10),),
                                      ],
                                    ),
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
              ),
            ),
          ],
        ),
      ),
    );
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
    }
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
  // void _toggleLike(int id, int iduser) async {
  //   final apiUrl = Uri.parse('https://readify-d02-tk.pbp.cs.ui.ac.id/likes/');
  //   var isnot =
  //       true; // Kita set ke true dulu, karena belum menemukan like yang sesuai

  //   // Mencetak semua data like sebelum toggle
  //   final initialLikesResponse = await http.get(apiUrl);
  //   final List<dynamic> initialLikes = json.decode(initialLikesResponse.body);

  //   // Melakukan pengecekan dan permintaan DELETE jika ditemukan like dengan user dan book yang sesuai
  //   for (Map<String, dynamic> like in initialLikes) {
  //     final int likeId = like['id'];
  //     final int likeUserId = like['user'];
  //     final int likeBookId = like['book'];

  //     if (likeUserId == iduser && likeBookId == id) {
  //       isnot = false; // Kita temukan like yang sesuai, set isnot ke false
  //       final deleteUrl = Uri.parse('https://readify-d02-tk.pbp.cs.ui.ac.id/likes/$likeId/');

  //       final deleteResponse = await http.delete(
  //         deleteUrl,
  //         headers: {'Content-Type': 'application/json'},
  //       );

  //       if (deleteResponse.statusCode == 204) {
  //         setState(() {
  //           isLiked = false;
  //         });
  //         ScaffoldMessenger.of(context)
  //           ..hideCurrentSnackBar()
  //           ..showSnackBar(SnackBar(content: Text("Batal Menyukai Buku Ini")));
  //         break; // Kita sudah menemukan dan menghapus like, tidak perlu melanjutkan loop
  //       } else {
  //         print(
  //             'Failed to delete like. Status code: ${deleteResponse.statusCode}');
  //         print('Response body: ${deleteResponse.body}');
  //       }
  //     }
  //   }

  //   // Jika setelah loop selesai dan tidak ada like yang sesuai, tambahkan like baru
  //   if (isnot) {
  //     final requestBody = {
  //       'user': iduser,
  //       'book': id,
  //     };

  //     final response = await http.post(
  //       apiUrl,
  //       body: json.encode(requestBody),
  //       headers: {'Content-Type': 'application/json'},
  //     );

  //     if (response.statusCode == 201) {
  //       // Berhasil menambahkan like
  //       setState(() {
  //         isLiked = true;
  //       });
  //       ScaffoldMessenger.of(context)
  //         ..hideCurrentSnackBar()
  //         ..showSnackBar(
  //             SnackBar(content: Text("Berhasil Menyukai Buku Ini.")));
  //     } else {
  //       // Gagal menambahkan like
  //       print('Failed to add like. Status code: ${response.statusCode}');
  //       print('Response body: ${response.body}');
  //     }
  //   }

  //   // Mencetak semua data like setelah toggle
  //   final updatedLikesResponse = await http.get(apiUrl);
  //   final List<dynamic> updatedLikes = json.decode(updatedLikesResponse.body);
  // }
}
