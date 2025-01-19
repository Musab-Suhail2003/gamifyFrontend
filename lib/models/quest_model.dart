
class QuestModel {
  String? quest_id;
  final dynamic user_id;
  final String quest_name;
  final int completion_percent;
  final String quest_description;
  bool paused;

  QuestModel({
    this.quest_id,
    required this.user_id,
    required this.quest_name,
    required this.completion_percent,
    required this.quest_description,
    this.paused = true
  });

  factory QuestModel.fromJson(Map<String, dynamic> json) {
    return QuestModel(
      quest_id: json['_id'],
      user_id: json['user_id'],
      quest_name: json['quest_name'],
      completion_percent: (json['completion_percent'] is double)
          ? json['completion_percent'].toInt() // Convert float to int
          : json['completion_percent'] as int,
      quest_description: json['quest_description'],
      paused: json['paused']
    );
  }

  get quests => null;

  Map<String, dynamic> toJson() {
    return {
      'user_id': user_id,
      'quest_name': quest_name,
      'completion_percent': completion_percent,
      'quest_description': quest_description
    };
  }

  //for testing
  static QuestModel getMockQuestModel() {
    return QuestModel(
      user_id: 1,
      quest_name: 'Sample Quest',
      completion_percent: 50,
      quest_description: 'This is a sample quest description.',
      paused: true
    );
  }
}