import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:readify_app/models/book.dart';
import 'package:readify_app/models/user.dart';
import 'package:readify_app/classes/pbp_django_auth.dart';
import 'dart:convert';
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
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final request = context.read<CookieRequest>();
      final username = request.jsonData["username"];
      final loadedUser = await UserService.fetchUser(username);
      setState(() {
        user = loadedUser;
        // Set nilai awal isLiked saat user data sudah dimuat
        _checkIfLiked(widget.book.pk, user.id);
      });
    } catch (error) {
      print('Error fetching user data: $error');
    }
  }

  // Fungsi untuk mengecek apakah buku dan pengguna sudah disukai
  Future<void> _checkIfLiked(int bookId, int userId) async {
    final apiUrl = Uri.parse('https://readify-d02-tk.pbp.cs.ui.ac.id/likes/');
    final initialLikesResponse = await http.get(apiUrl);
    final List<dynamic> initialLikes = json.decode(initialLikesResponse.body);

    for (Map<String, dynamic> like in initialLikes) {
      final int likeUserId = like['user'];
      final int likeBookId = like['book'];
      if (likeUserId == userId && likeBookId == bookId) {
        setState(() {
          isLiked = true;
        });
        return;
      }
    }

    setState(() {
      isLiked = false;
    });
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
                widget.book.fields.imageUrlL,
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
                      onPressed: () {
                            if (user != null) {
                              _toggleLike(widget.book.pk, user.id);
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
                            'Sukai buku ini',
                            style: TextStyle(
                              color:
                                  isLiked ? Colors.white : Colors.amberAccent,
                            ),
                          ),
                        ],
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

  void _toggleLike(int id, int iduser) async {
    final apiUrl = Uri.parse('https://readify-d02-tk.pbp.cs.ui.ac.id/likes/');
    var isnot =
        true; // Kita set ke true dulu, karena belum menemukan like yang sesuai

    // Mencetak semua data like sebelum toggle
    final initialLikesResponse = await http.get(apiUrl);
    final List<dynamic> initialLikes = json.decode(initialLikesResponse.body);

    // Melakukan pengecekan dan permintaan DELETE jika ditemukan like dengan user dan book yang sesuai
    for (Map<String, dynamic> like in initialLikes) {
      final int likeId = like['id'];
      final int likeUserId = like['user'];
      final int likeBookId = like['book'];

      if (likeUserId == iduser && likeBookId == id) {
        isnot = false; // Kita temukan like yang sesuai, set isnot ke false
        final deleteUrl = Uri.parse('https://readify-d02-tk.pbp.cs.ui.ac.id/likes/$likeId/');

        final deleteResponse = await http.delete(
          deleteUrl,
          headers: {'Content-Type': 'application/json'},
        );

        if (deleteResponse.statusCode == 204) {
          setState(() {
            isLiked = false;
          });
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text("Batal Menyukai Buku Ini")));
          break; // Kita sudah menemukan dan menghapus like, tidak perlu melanjutkan loop
        } else {
          print(
              'Failed to delete like. Status code: ${deleteResponse.statusCode}');
          print('Response body: ${deleteResponse.body}');
        }
      }
    }

    // Jika setelah loop selesai dan tidak ada like yang sesuai, tambahkan like baru
    if (isnot) {
      final requestBody = {
        'user': iduser,
        'book': id,
      };

      final response = await http.post(
        apiUrl,
        body: json.encode(requestBody),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 201) {
        // Berhasil menambahkan like
        setState(() {
          isLiked = true;
        });
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
              SnackBar(content: Text("Berhasil Menyukai Buku Ini.")));
      } else {
        // Gagal menambahkan like
        print('Failed to add like. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    }

    // Mencetak semua data like setelah toggle
    final updatedLikesResponse = await http.get(apiUrl);
    final List<dynamic> updatedLikes = json.decode(updatedLikesResponse.body);
  }
}
