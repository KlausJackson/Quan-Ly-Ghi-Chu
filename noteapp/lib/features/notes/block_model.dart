import 'package:hive/hive.dart';

part 'block_model.g.dart';

@HiveType(typeId: 2)
class BlockModel {
  @HiveField(0)
  final String type; // 'text' or 'checklist'

  @HiveField(1)
  final String text;

  @HiveField(2)
  final bool checked;

  BlockModel({this.type = 'text', this.text = '', this.checked = false});

  factory BlockModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    return BlockModel(
      type: json['type'] ?? 'text',
      text: data['text'] ?? '',
      checked: data['checked'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'data': {'text': text, 'checked': checked},
    };
  }
  
  BlockModel copyWith({String? type, String? text, bool? checked}) {
    return BlockModel(
      type: type ?? this.type,
      text: text ?? this.text,
      checked: checked ?? this.checked,
    );
  }
}
