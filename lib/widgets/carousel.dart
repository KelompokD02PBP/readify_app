import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:readify_app/classes/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:readify_app/models/book.dart';

class Carousel extends StatefulWidget {
  const Carousel({
    Key? key,
  }) : super(key: key);

  @override
  State<Carousel> createState() => _CarouselState();
}

class _CarouselState extends State<Carousel> {
  late PageController _pageController;
  late List<Book> books = [];
  int activePage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.8, initialPage: 0);
    fetchBooks(); 
  }

  Future<void> fetchBooks() async {
    try {
      final request = context.read<CookieRequest>();
      final response = await request.postJson(
        "http://127.0.0.1:8000/get-liked-books/",
        jsonEncode({
          "username": request.jsonData["username"],
          "id": request.jsonData["id"],
        }),
      );

      setState(() {
        books = List<Book>.from(
            response.map((bookJson) => Book.fromJson(bookJson)));
      });
    } catch (error) {
      print('Error fetching books: $error');
      // Handle error appropriately, e.g., show an error message
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (books.isEmpty)
          const Text("No Books")
        else
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 400,
            child: PageView.builder(
              
              itemCount: books.length,
              pageSnapping: true,
              controller: _pageController,
              onPageChanged: (page) {
                setState(() {
                  activePage = page;
                });
              },
              itemBuilder: (context, pagePosition) {
                bool active = pagePosition == activePage;
                return slider(books[pagePosition].fields.imageUrlL, active);
              },
            ),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: indicators(books.length, activePage),
        ),
      ],
    );
  }

  AnimatedContainer slider(String imageUrl, bool active) {
    double margin = active ? 10 : 20;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutCubic,
      margin: EdgeInsets.all(margin),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover, // Ensure the image covers the entire container
        ),
      ),
    );
  }

  List<Widget> indicators(int imagesLength, int currentIndex) {
    return List<Widget>.generate(imagesLength, (index) {
      return Container(
        margin: const EdgeInsets.all(3),
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: currentIndex == index ? Colors.white : Colors.white24,
          shape: BoxShape.circle,
        ),
      );
    });
  }

  @override
  void dispose() {
    _pageController.dispose(); // Dispose of the PageController when not needed
    super.dispose();
  }
}
