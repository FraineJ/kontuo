class UserProfile {
  final String name;
  final String currency;
  final String financialGoal;
  final String knowledgeLevel;
  final double monthlyBudget;
  final String incomeFrequency;
  final bool onboardingCompleted;

  UserProfile({
    required this.name,
    required this.currency,
    required this.financialGoal,
    required this.knowledgeLevel,
    required this.monthlyBudget,
    required this.incomeFrequency,
    this.onboardingCompleted = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'currency': currency,
      'financial_goal': financialGoal,
      'knowledge_level': knowledgeLevel,
      'monthly_budget': monthlyBudget,
      'income_frequency': incomeFrequency,
      'onboarding_completed': onboardingCompleted,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] ?? '',
      currency: json['currency'] ?? 'USD',
      financialGoal: json['financial_goal'] ?? 'saving',
      knowledgeLevel: json['knowledge_level'] ?? 'basic',
      monthlyBudget: (json['monthly_budget'] ?? 0).toDouble(),
      incomeFrequency: json['income_frequency'] ?? 'monthly',
      onboardingCompleted: json['onboarding_completed'] ?? false,
    );
  }

  UserProfile copyWith({
    String? name,
    String? currency,
    String? financialGoal,
    String? knowledgeLevel,
    double? monthlyBudget,
    String? incomeFrequency,
    bool? onboardingCompleted,
  }) {
    return UserProfile(
      name: name ?? this.name,
      currency: currency ?? this.currency,
      financialGoal: financialGoal ?? this.financialGoal,
      knowledgeLevel: knowledgeLevel ?? this.knowledgeLevel,
      monthlyBudget: monthlyBudget ?? this.monthlyBudget,
      incomeFrequency: incomeFrequency ?? this.incomeFrequency,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
    );
  }
}


