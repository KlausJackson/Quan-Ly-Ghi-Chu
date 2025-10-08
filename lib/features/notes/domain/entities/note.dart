class Note {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final bool isDeleted;
  final DateTime updatedAt;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required  this.isDeleted,
    required this.updatedAt,
  });
}