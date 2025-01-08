class Task {
  dynamic task_id;
  final dynamic milestone_id;
  final String title;
  final String description;
  bool completed;
  final String level;
  static Map<String, int> levelXpMap = {
    'EASY': 100,
    'MEDIUM': 200,
    'HARD': 300,
  };

  Task({this.completed = false, this.task_id, required this.milestone_id, required this.title, required this.description, required this.level});

  factory Task.fromJson(Map<String, dynamic> json){
       return Task(
         task_id: json['_id'],
         milestone_id: json['milestone_id'],
         title: json['title'],
         description: json['description'],
         level: json['level'],
         completed: json['isCompleted']
       );
  }

  Map<String, dynamic> toJson(){
      return {
        'milestone_id': milestone_id,
        'title': title,
        'completed': completed,
        'description': description,
        'level': level,
      };
  }

  setComplete() {
    completed = true;
    final xp_gain = levelXpMap[level];
    final coin_gain = xp_gain! * 0.1;

    
  }

  
}
enum TaskLevel {EASY, MEDIUM, HARD}