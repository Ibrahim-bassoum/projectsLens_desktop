class GeneratedDocument {
  final String id;
  final String title;
  final String content;

  GeneratedDocument({
    required this.id,
    required this.title,
    required this.content,
  });

  factory GeneratedDocument.fromJson(Map<String, dynamic> json) {
    return GeneratedDocument(
      id: json['id'],
      title: json['title'],
      content: json['content'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'title': title, 'content': content};
  }
}
