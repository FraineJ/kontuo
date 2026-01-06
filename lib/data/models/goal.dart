enum GoalTimeframe { short, medium, long }

class Goal {
  final String id;
  final String name;
  final String description;
  final double targetAmount;
  final double currentAmount;
  final GoalTimeframe timeframe;
  final DateTime? targetDate;
  final DateTime createdAt;

  Goal({
    required this.id,
    required this.name,
    required this.description,
    required this.targetAmount,
    this.currentAmount = 0,
    required this.timeframe,
    this.targetDate,
    required this.createdAt,
  });

  double get progress => targetAmount > 0 ? currentAmount / targetAmount : 0;
  bool get isCompleted => currentAmount >= targetAmount;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'target_amount': targetAmount,
      'current_amount': currentAmount,
      'timeframe': timeframe.toString().split('.').last,
      'target_date': targetDate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Goal.fromJson(Map<String, dynamic> json) {
    GoalTimeframe timeframe;
    switch (json['timeframe']) {
      case 'short':
        timeframe = GoalTimeframe.short;
        break;
      case 'medium':
        timeframe = GoalTimeframe.medium;
        break;
      case 'long':
        timeframe = GoalTimeframe.long;
        break;
      default:
        timeframe = GoalTimeframe.medium;
    }

    return Goal(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      targetAmount: (json['target_amount'] ?? 0).toDouble(),
      currentAmount: (json['current_amount'] ?? 0).toDouble(),
      timeframe: timeframe,
      targetDate: json['target_date'] != null
          ? DateTime.parse(json['target_date'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Goal copyWith({
    String? id,
    String? name,
    String? description,
    double? targetAmount,
    double? currentAmount,
    GoalTimeframe? timeframe,
    DateTime? targetDate,
    DateTime? createdAt,
  }) {
    return Goal(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      timeframe: timeframe ?? this.timeframe,
      targetDate: targetDate ?? this.targetDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}


