import 'package:hive/hive.dart';

part 'tag_model.g.dart';

@HiveType(typeId: 1)
class TagModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  TagModel({
    required this.id,
    required this.name
  });


  factory TagModel.fromJson(Map<String, dynamic> json) {
    return TagModel(
      id: json['id'].toString(), // Ensure string
      name: json['name']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name
    };
  }
}
