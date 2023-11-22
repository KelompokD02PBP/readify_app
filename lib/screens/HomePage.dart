import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:readify_app/widgets/BookCard.dart';
import 'package:readify_app/models/Book.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class MyHomePage extends StatelessWidget {
    MyHomePage({Key? key}) : super(key: key);

    Future<List<Book>> fetchProduct() async {
      var url = Uri.parse('http://127.0.0.1:8000/katalog/get-books-json');
      var response = await http.get(url, headers: {"Content-Type": "application/json"});

      // melakukan decode response menjadi bentuk json
      var data = jsonDecode(utf8.decode(response.bodyBytes));

      // melakukan konversi data json menjadi object Product
      List<Book> list_product = [];
      for (var d in data) {
          if (d != null) {
              list_product.add(Book.fromJson(d));
          }
      }
      return list_product;
    }

    @override
    Widget build(BuildContext context)  {
      return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Readify',
              style: TextStyle(fontFamily:"GoogleDisplay"),
            ),
            backgroundColor: Color.fromARGB(255, 56, 30, 103),
            foregroundColor: Colors.white,
        ),
        body:
        Column(
          children : [
            Center(
              widthFactor: 1.5,
              child:
              SizedBox(
                width: 700,
                height: 70,
                child : Row(
                  children:[
                    const SizedBox(
                      width: 500,
                      height: 100,
                      child: 
                      TextField(
                      autocorrect: true,
                      decoration: InputDecoration(
                        hintText: "Lorem Ipsum",
                        labelText: "Search"
                      ),
                    )
                    ),
                    Flexible(
              child: ElevatedButton(onPressed: (){

                    }, child: const Text("Search")) 
              ),
                    
                  ]
              ),
              )
            ),
            Expanded(child: 
              FutureBuilder(
              future: fetchProduct(),
              builder: (context, AsyncSnapshot snapshot){
                      if (snapshot.data == null) {
                          return const Center(child: CircularProgressIndicator());
                      } else {
                          if (!snapshot.hasData) {
                            return const Column(
                              children: [
                              Text(
                                  "Tidak ada data produk.",
                                  style:
                                      TextStyle(color: Color(0xff59A5D8), fontSize: 20),
                              ),
                              SizedBox(height: 8),
                              ],
                          );
                          } else {
                              return GridView.builder(
                                itemCount: snapshot.data.length,
                                shrinkWrap: true,
                                gridDelegate: CustomGridDelegate(dimension: 250.0),
                                itemBuilder: (context, index) {
                                  return BookCard(item: snapshot.data[index]);
                                }
                              );
                            }
                      }
              }
              )
            )
          ]
        )
      );
    }

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".
}

class CustomGridDelegate extends SliverGridDelegate {
  CustomGridDelegate({required this.dimension});

  // This is the desired height of each row (and width of each square).
  // When there is not enough room, we shrink this to the width of the scroll view.
  final double dimension;

  // The layout is two rows of squares, then one very wide cell, repeat.

  @override
  SliverGridLayout getLayout(SliverConstraints constraints) {
    // Determine how many squares we can fit per row.
    int count = constraints.crossAxisExtent ~/ dimension;
    if (count < 1) {
      count = 1; // Always fit at least one regardless.
    }
    final double squareDimension = constraints.crossAxisExtent / count;
    return CustomGridLayout(
      crossAxisCount: count,
      fullRowPeriod:
          4, // Number of rows per block (one of which is the full row).
      dimension: squareDimension,
    );
  }

  @override
  bool shouldRelayout(CustomGridDelegate oldDelegate) {
    return dimension != oldDelegate.dimension;
  }
}

class CustomGridLayout extends SliverGridLayout {
  const CustomGridLayout({
    required this.crossAxisCount,
    required this.dimension,
    required this.fullRowPeriod,
  })  : assert(crossAxisCount > 0),
        assert(fullRowPeriod > 1),
        // loopLength = crossAxisCount * (fullRowPeriod - 1) + 1, // INI DIHAPUS
        loopLength = crossAxisCount * (fullRowPeriod) + 1,
        loopHeight = fullRowPeriod * dimension;

  final int crossAxisCount;
  final double dimension;
  final int fullRowPeriod;

  // Computed values.
  final int loopLength;
  final double loopHeight;

  @override
  double computeMaxScrollOffset(int childCount) {
    // This returns the scroll offset of the end side of the childCount'th child.
    // In the case of this example, this method is not used, since the grid is
    // infinite. However, if one set an itemCount on the GridView above, this
    // function would be used to determine how far to allow the user to scroll.
    if (childCount == 0 || dimension == 0) {
      return 0;
    }
    return (childCount ~/ loopLength) * loopHeight +
        ((childCount % loopLength) ~/ crossAxisCount) * dimension;
  }

  @override
  SliverGridGeometry getGeometryForChildIndex(int index) {
    // This returns the position of the index'th tile.
    //
    // The SliverGridGeometry object returned from this method has four
    // properties. For a grid that scrolls down, as in this example, the four
    // properties are equivalent to x,y,width,height. However, since the
    // GridView is direction agnostic, the names used for SliverGridGeometry are
    // also direction-agnostic.
    //
    // Try changing the scrollDirection and reverse properties on the GridView
    // to see how this algorithm works in any direction (and why, therefore, the
    // names are direction-agnostic).
    final int loop = index ~/ loopLength;
    final int loopIndex = index % loopLength;
    /*
    * INI DI HAPUS
    */
    // if (loopIndex == loopLength - 1) {
    //   // Full width case.
    //   return SliverGridGeometry(
    //     scrollOffset: (loop + 1) * loopHeight - dimension, // "y"
    //     crossAxisOffset: 0, // "x"
    //     mainAxisExtent: dimension, // "height"
    //     crossAxisExtent: crossAxisCount * dimension, // "width"
    //   );
    // }
    // Square case.
    final int rowIndex = loopIndex ~/ crossAxisCount;
    final int columnIndex = loopIndex % crossAxisCount;
    return SliverGridGeometry(
      scrollOffset: (loop * loopHeight) + (rowIndex * dimension), // "y"
      crossAxisOffset: columnIndex * dimension, // "x"
      mainAxisExtent: dimension, // "height"
      crossAxisExtent: dimension, // "width"
    );
  }

  @override
  int getMinChildIndexForScrollOffset(double scrollOffset) {
    // This returns the first index that is visible for a given scrollOffset.
    //
    // The GridView only asks for the geometry of children that are visible
    // between the scroll offset passed to getMinChildIndexForScrollOffset and
    // the scroll offset passed to getMaxChildIndexForScrollOffset.
    //
    // It is the responsibility of the SliverGridLayout to ensure that
    // getGeometryForChildIndex is consistent with getMinChildIndexForScrollOffset
    // and getMaxChildIndexForScrollOffset.
    //
    // Not every child between the minimum child index and the maximum child
    // index need be visible (some may have scroll offsets that are outside the
    // view; this happens commonly when the grid view places tiles out of
    // order). However, doing this means the grid view is less efficient, as it
    // will do work for children that are not visible. It is preferred that the
    // children are returned in the order that they are laid out.
    final int rows = scrollOffset ~/ dimension;
    final int loops = rows ~/ fullRowPeriod;
    final int extra = rows % fullRowPeriod;
    return loops * loopLength + extra * crossAxisCount;
  }

  @override
  int getMaxChildIndexForScrollOffset(double scrollOffset) {
    // (See commentary above.)
    final int rows = scrollOffset ~/ dimension;
    final int loops = rows ~/ fullRowPeriod;
    final int extra = rows % fullRowPeriod;
    final int count = loops * loopLength + extra * crossAxisCount;
    if (extra == fullRowPeriod - 1) {
      return count;
    }
    return count + crossAxisCount - 1;
  }
}
