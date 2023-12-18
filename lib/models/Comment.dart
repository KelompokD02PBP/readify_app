import 'dart:convert';

List<Comment> commentFromJson(String str) => List<Comment>.from(json.decode(str).map((x) => Comment.fromJson(x)));

String commentToJson(List<Comment> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Comment {
    String model;
    int pk;
    Fields fields;

    Comment({
        required this.model,
        required this.pk,
        required this.fields,
    });

    factory Comment.fromJson(Map<String, dynamic> json) => Comment(
        model: json["model"],
        pk: json["pk"],
        fields: Fields.fromJson(json["fields"]),
    );

    Map<String, dynamic> toJson() => {
        "model": model,
        "pk": pk,
        "fields": fields.toJson(),
    };
}

class Fields {
    int book;
    int user;
    String comment;
    DateTime createdOn;
    String? name;

    Fields({
        required this.book,
        required this.user,
        required this.comment,
        required this.createdOn,
    });

    factory Fields.fromJson(Map<String, dynamic> json) => Fields(
        book: json["book"],
        user: json["user"],
        comment: json["comment"],
        createdOn: DateTime.parse(json["created_on"]),
    );

    Map<String, dynamic> toJson() => {
        "book": book,
        "user": user,
        "comment": comment,
        "created_on": createdOn.toIso8601String(),
    };
}
