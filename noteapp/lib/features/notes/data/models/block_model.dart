import 'package:noteapp/features/notes/domain/entities/block.dart';

class BlockModel extends Block {
  BlockModel({
    required super.type,
    required super.text,
    required super.checked,
  });

  factory BlockModel.fromJson(Map<String, dynamic> json) {
    return BlockModel(
      type: json['type'],
      text: json['data']['text'] ?? '', // Default to empty string if not present
      checked: json['data']['checked'] ?? false, // Default to false if not present
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'data': {'text': text, 'checked': checked},
    };
  }
}
