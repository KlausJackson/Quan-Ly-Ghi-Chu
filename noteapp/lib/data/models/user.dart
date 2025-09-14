import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 0)
class User {
  @HiveField(0)
  final String username;
  @HiveField(1)
  String? lastSynced; // timestamp, nullable

  User({required this.username, this.lastSynced});
}
