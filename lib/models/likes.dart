class Likes {
  late int user;
  late int book;

  Likes({
    required this.user,
    required this.book,
  });

  Likes.fromJson(Map<String, dynamic> json) {
    user = json['user'];
    book = json['book'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'user': user,
      'book': book,
    };
    return data;
  }
}
