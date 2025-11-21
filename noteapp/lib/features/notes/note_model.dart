import 'package:hive/hive.dart';
import 'package:noteapp/features/notes/block_model.dart';

part 'note_model.g.dart';

@HiveType(typeId: 3)
class NoteModel {
  @HiveField(0)
  final String id; // UUID

  @HiveField(1)
  final String title;

  @HiveField(2)
  final List<BlockModel> body;

  @HiveField(3)
  final List<String> tagIds; // Only store IDs locally

  @HiveField(4)
  final bool isPinned;

  @HiveField(5)
  final bool isDeleted;

  @HiveField(6)
  final DateTime updatedAt;

  @HiveField(7)
  final DateTime createdAt;

  NoteModel({
    required this.id,
    required this.title,
    required this.body,
    required this.tagIds,
    this.isPinned = false,
    this.isDeleted = false,
    required this.updatedAt,
    required this.createdAt,
  });

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    // --- TAG HANDLING LOGIC ---
    // The API might return ["uuid1", "uuid2"] OR [{uuid: "...", name: "..."}]
    var rawTags = json['tagUUIDs'];
    List<String> parsedTags = [];

    if (rawTags != null) {
      if (rawTags is List) {
        for (var item in rawTags) {
          if (item is String) {
            parsedTags.add(item);
          } else if (item is Map) {
            // If backend populated the tag, extract the UUID
            if (item['uuid'] != null) parsedTags.add(item['uuid']);
          }
        }
      }
    }

    // --- BODY HANDLING ---
    var rawBody = json['body'] as List? ?? [];
    List<BlockModel> parsedBody = rawBody
        .map((b) => BlockModel.fromJson(b))
        .toList();

    return NoteModel(
      id: json['uuid'],
      title: json['title'] ?? '',
      body: parsedBody,
      tagIds: parsedTags,
      isPinned: json['isPinned'] ?? false,
      isDeleted: json['isDeleted'] ?? false,
      updatedAt: DateTime.parse(
        json['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid': id,
      'title': title,
      'body': body.map((b) => b.toJson()).toList(),
      'tagUUIDs': tagIds, 
      'isPinned': isPinned,
      'isDeleted': isDeleted,
    };
  }

    NoteModel copyWith({
    String? id,
    String? title,
    List<BlockModel>? body,
    List<String>? tagIds,
    bool? isPinned,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NoteModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      tagIds: tagIds ?? this.tagIds,
      isPinned: isPinned ?? this.isPinned,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
