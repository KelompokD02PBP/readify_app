import 'package:flutter/material.dart';
import 'package:readify_app/models/Book.dart';

class BookCard extends StatelessWidget {
  final Book item;

  const BookCard({super.key, required this.item}); // Constructor

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Card(
        child: Center(child:
          Column(
            children: [
              Image.network(item.fields.imageUrlS),
              Text(item.fields.title),
              Text(item.fields.author),
              ElevatedButton(onPressed: (){
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(SnackBar(
                    content: Text("Kamu telah menekan tombol ${item.fields.title}!")));
              }, child: Text("See More"))
            ],
          ),
        )
      )
    );
    
    
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