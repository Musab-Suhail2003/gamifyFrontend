class Milestone {
  dynamic milestone_id;
  final dynamic questId;
  final String title;
  final String description;
  final int days;
  final int completionPercent;


  Milestone({
    this.milestone_id,
    required this.questId,
    required this.title,
    required this.description,
    required this.days,
    required this.completionPercent,

  });

  factory Milestone.fromJson(Map<String, dynamic> json) {
    return Milestone(
      milestone_id: json['_id'],
      questId: json['questId'],
      title: json['title'],
      description: json['description'],
      days: json['days'],
      completionPercent: (json['completionPercent'] is double)
          ? json['completionPercent'].toInt() // Convert float to int
          : json['completionPercent'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'questId': questId,
      'title': title,
      'description': description,
      'days': days,
      'completionPercent': completionPercent
    };
  }
}