import 'package:flutter/material.dart';
import 'package:readify_app/screens/detail_book.dart';
import 'package:readify_app/screens/per_book.dart';
import 'package:readify_app/models/Book2.dart';

class BookCard extends StatelessWidget {
  final Book item;
  final String uname;

  const BookCard(
      {super.key, required this.item, required this.uname}); // Constructor

  @override
  Widget build(BuildContext context) {
    String title = item.fields.title;
    // print(title);
    if (item.fields.title.length > 40) {
      title = "${item.fields.title.substring(0, 40)}...";
    }
    String imageUrl = item.fields.imageUrlS;
    imageUrl = imageUrl.replaceAll("http://", "https://").replaceAll("images.amazon", "m.media-amazon");
    return Card(
        color: Colors.black38,
        child: Center(
          child: Column(
            children: [
              Expanded(
                child: Image.network(imageUrl),
              ),
              Text(
                title,
                style: const TextStyle(fontSize: 11, color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              Text(
                item.fields.author,
                style: const TextStyle(fontSize: 9, color: Colors.white70),
              ),
              Container(
                constraints: const  BoxConstraints(
                  maxHeight: 20,
                  minHeight: 5,
                  maxWidth: 100,
                  minWidth: 100,
                  ),
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                      (Set<MaterialState> states) {
                        if (states.contains(MaterialState.pressed)) {
                          return Colors.blueGrey;
                        }
                        return Colors.amber; // Use the component's default.
                      },
                    ),
                    minimumSize: MaterialStateProperty.all(Size(100, 5)),
                    // maximumSize: MaterialStateProperty.all(Size(100,40)),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        // builder: (context) => BookDetail(
                        //   book : item,
                        //   uname: uname,
                        // ),
                        builder: (context) => PerBook(book:item)
                      ),
                    );

                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(SnackBar(
                        content: Text("Kamu telah menekan tombol ${item.fields.title}!"),
                      ));
                  },
                  child: const FittedBox(child: const Text("See More")),
                ),
              ),
              // SizedBox(height: 10.0,)
            ],
          ),
        ));

    // Material(
    //   child: InkWell(
    //     // Area responsive terhadap sentuhan
    //     onTap: () async {
    //       // Memunculkan SnackBar ketika diklik
    //       ScaffoldMessenger.of(context)
    //         ..hideCurrentSnackBar()
    //         ..showSnackBar(SnackBar(
    //           content: Text("Kamu telah menekan tombol ${item.fields.title}!")));
    //           Navigator.push(
    //           context,
    //           MaterialPageRoute(
    //           //TODO: page spesifik book
    //             builder: (context) => MyHomePage (),
    //           )
    //           );
    //     },

    //     borderRadius: BorderRadius.circular(12),
    //     child: Container(
    //       // Container untuk menyimpan Icon dan Text
    //       decoration: BoxDecoration(
    //       borderRadius: BorderRadius.circular(10),
    //       boxShadow: [
    //         BoxShadow(spreadRadius: 3),
    //       ],
    //     ),
    //       padding: const EdgeInsets.all(0),
    //       child: Center(
    //         child: Column(
    //           mainAxisAlignment: MainAxisAlignment.center,
    //           children: [
    //             Icon(
    //               color: Colors.white,
    //               size: 50.0,
    //             ),
    //             const Padding(padding: EdgeInsets.all(3)),
    //             Text(
    //               item.name,
    //               textAlign: TextAlign.center,
    //               style: const TextStyle(color: Colors.white),
    //             ),
    //           ],
    //         ),
    //       ),
    //     ),
    //   ),
    // );
  }
}
