import 'package:notes/features/notes/domain/entities/note.dart';

class NoteModel extends Note{
  NoteModel({
    required super.id,
    required super.title,
    required super.content,
    required super.isDeleted,
    required super.createdAt,
    required super.updatedAt,
  });
  factory NoteModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return NoteModel(
        id: '',
        title: '',
        content: '',
        isDeleted: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }

    // Safe ID extraction
    final dynamic idValue = json['uuid'] ?? json['_id'];
    final String parsedId = idValue?.toString() ?? '';

    // Safe title extraction
    final String parsedTitle = json['title']?.toString() ?? '';

    // Safe content extraction
    String parsedContent = '';
    try {
      final dynamic body = json['body'];
      if (body is List) {
        final List<String> texts = [];
        for (final item in body) {
          if (item is Map<String, dynamic>) {
            final dynamic data = item['data'];
            if (data is Map<String, dynamic>) {
              final String? text = data['text']?.toString();
              if (text != null && text.isNotEmpty) {
                texts.add(text);
              }
            }
          }
        }
        parsedContent = texts.join('\n');
      }
      
      // Fallback to direct content field
      if (parsedContent.isEmpty) {
        parsedContent = json['content']?.toString() ?? '';
      }
    } catch (e) {
      parsedContent = json['content']?.toString() ?? '';
    }

    // Safe boolean extraction
    final bool parsedIsDeleted = json['isDeleted'] == true;

    // Safe date extraction
    final DateTime now = DateTime.now();
    final DateTime parsedCreatedAt = _safeParseDateTime(json['createdAt']) ?? now;
    final DateTime parsedUpdatedAt = _safeParseDateTime(json['updatedAt']) ?? parsedCreatedAt;

    return NoteModel(
      id: parsedId,
      title: parsedTitle,
      content: parsedContent,
      isDeleted: parsedIsDeleted,
      createdAt: parsedCreatedAt,
      updatedAt: parsedUpdatedAt,
    );
  }

  static DateTime? _safeParseDateTime(dynamic dateValue) {
    if (dateValue == null) return null;
    try {
      final String dateStr = dateValue.toString();
      if (dateStr.isEmpty) return null;
      return DateTime.tryParse(dateStr);
    } catch (e) {
      return null;
    }
  }
  Map<String, dynamic> toJson() {
    return {
      'uuid': id,
      'title': title,
      'content': content,
      'isDeleted': isDeleted,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}