import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
class UserModel {
  @HiveField(0)
  final String username;

  @HiveField(1)
  String? lastSynced;

  UserModel({required this.username, this.lastSynced});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      username: json['username'],
      lastSynced: json['lastSynced'],
    );
  }

  Map<String, dynamic> toJson() {
    return {"username": username, "lastSynced": lastSynced};
  }
}
