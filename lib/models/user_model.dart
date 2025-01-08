class UserModel {
  dynamic user_id;
  dynamic character_id;
  final String name;
  final String? bio;
  final int XP;
  final int coin;
  final int questsCompleted;
  final String googleId;
  String? profilePicture;

  UserModel({
    this.user_id,
    this.character_id,
    required this.name,
    required this.bio,
    required this.XP,
    required this.coin,
    required this.questsCompleted,
    required this.googleId,
    this.profilePicture
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      user_id: json['_id'],
      character_id: json['Character'],
      name: json['name'],
      bio: json['bio'],
      XP: json['XP'],
      coin: json['coin'],
      questsCompleted: json['questsCompleted'] ?? 0,
      googleId: json['googleId'],
      profilePicture: json['profilePicture']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'bio': bio,
      'XP': XP,
      'coin': coin,
      'questsCompleted': questsCompleted,
      'googleId': googleId,
    };
  }
}