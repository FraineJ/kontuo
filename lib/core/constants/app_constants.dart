class AppConstants {
  // Currencies
  static const List<String> currencies = [
    'USD',
    'EUR',
    'GBP',
    'JPY',
    'CNY',
    'CAD',
    'AUD',
    'MXN',
    'BRL',
    'ARS',
    'CLP',
    'COP',
    'PEN',
  ];

  // Financial goals
  static const List<String> financialGoals = [
    'saving',
    'debt_control',
    'investment',
    'budget_tracking',
    'retirement',
  ];

  static const Map<String, String> financialGoalLabels = {
    'saving': 'Ahorro',
    'debt_control': 'Control de Deudas',
    'investment': 'Inversión',
    'budget_tracking': 'Seguimiento de Presupuesto',
    'retirement': 'Jubilación',
  };

  // Knowledge levels
  static const List<String> knowledgeLevels = [
    'basic',
    'intermediate',
    'advanced',
  ];

  static const Map<String, String> knowledgeLevelLabels = {
    'basic': 'Básico',
    'intermediate': 'Intermedio',
    'advanced': 'Avanzado',
  };

  // Income frequencies
  static const List<String> incomeFrequencies = [
    'weekly',
    'biweekly',
    'monthly',
  ];

  static const Map<String, String> incomeFrequencyLabels = {
    'weekly': 'Semanal',
    'biweekly': 'Quincenal',
    'monthly': 'Mensual',
  };

  // Transaction categories - Expenses
  static const List<String> expenseCategories = [
    'food',
    'transport',
    'entertainment',
    'shopping',
    'bills',
    'health',
    'education',
    'travel',
    'other',
  ];

  static const Map<String, String> expenseCategoryLabels = {
    'food': 'Comida',
    'transport': 'Transporte',
    'entertainment': 'Entretenimiento',
    'shopping': 'Compras',
    'bills': 'Servicios',
    'health': 'Salud',
    'education': 'Educación',
    'travel': 'Viajes',
    'other': 'Otro',
  };

  // Transaction categories - Income
  static const List<String> incomeCategories = [
    'salary',
    'freelance',
    'investment',
    'gift',
    'bonus',
    'other',
  ];

  static const Map<String, String> incomeCategoryLabels = {
    'salary': 'Salario',
    'freelance': 'Freelance',
    'investment': 'Inversión',
    'gift': 'Regalo',
    'bonus': 'Bonus',
    'other': 'Otro',
  };

  // Debt types
  static const Map<String, String> debtTypeLabels = {
    'personalLoan': 'Préstamo Personal',
    'creditCard': 'Tarjeta de Crédito',
    'mortgage': 'Hipoteca',
    'other': 'Otro',
  };

  // Goal timeframes
  static const Map<String, String> goalTimeframeLabels = {
    'short': 'Corto Plazo',
    'medium': 'Mediano Plazo',
    'long': 'Largo Plazo',
  };
}


