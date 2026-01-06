import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';
import '../models/transaction.dart';
import '../models/goal.dart';
import '../models/debt.dart';

class StorageService {
  static const String _keyUserProfile = 'user_profile';
  static const String _keyTransactions = 'transactions';
  static const String _keyGoals = 'goals';
  static const String _keyDebts = 'debts';

  // User Profile
  Future<void> saveUserProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserProfile, jsonEncode(profile.toJson()));
  }

  Future<UserProfile?> getUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final profileJson = prefs.getString(_keyUserProfile);
    if (profileJson == null) return null;
    return UserProfile.fromJson(jsonDecode(profileJson));
  }

  // Transactions
  Future<void> saveTransactions(List<Transaction> transactions) async {
    final prefs = await SharedPreferences.getInstance();
    final transactionsJson = transactions.map((t) => t.toJson()).toList();
    await prefs.setString(_keyTransactions, jsonEncode(transactionsJson));
  }

  Future<List<Transaction>> getTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final transactionsJson = prefs.getString(_keyTransactions);
    if (transactionsJson == null) return [];
    final List<dynamic> decoded = jsonDecode(transactionsJson);
    return decoded.map((json) => Transaction.fromJson(json)).toList();
  }

  Future<void> addTransaction(Transaction transaction) async {
    final transactions = await getTransactions();
    transactions.add(transaction);
    await saveTransactions(transactions);
  }

  Future<void> updateTransaction(Transaction transaction) async {
    final transactions = await getTransactions();
    final index = transactions.indexWhere((t) => t.id == transaction.id);
    if (index != -1) {
      transactions[index] = transaction;
      await saveTransactions(transactions);
    }
  }

  Future<void> deleteTransaction(String id) async {
    final transactions = await getTransactions();
    transactions.removeWhere((t) => t.id == id);
    await saveTransactions(transactions);
  }

  // Goals
  Future<void> saveGoals(List<Goal> goals) async {
    final prefs = await SharedPreferences.getInstance();
    final goalsJson = goals.map((g) => g.toJson()).toList();
    await prefs.setString(_keyGoals, jsonEncode(goalsJson));
  }

  Future<List<Goal>> getGoals() async {
    final prefs = await SharedPreferences.getInstance();
    final goalsJson = prefs.getString(_keyGoals);
    if (goalsJson == null) return [];
    final List<dynamic> decoded = jsonDecode(goalsJson);
    return decoded.map((json) => Goal.fromJson(json)).toList();
  }

  Future<void> addGoal(Goal goal) async {
    final goals = await getGoals();
    goals.add(goal);
    await saveGoals(goals);
  }

  Future<void> updateGoal(Goal goal) async {
    final goals = await getGoals();
    final index = goals.indexWhere((g) => g.id == goal.id);
    if (index != -1) {
      goals[index] = goal;
      await saveGoals(goals);
    }
  }

  Future<void> deleteGoal(String id) async {
    final goals = await getGoals();
    goals.removeWhere((g) => g.id == id);
    await saveGoals(goals);
  }

  // Debts
  Future<void> saveDebts(List<Debt> debts) async {
    final prefs = await SharedPreferences.getInstance();
    final debtsJson = debts.map((d) => d.toJson()).toList();
    await prefs.setString(_keyDebts, jsonEncode(debtsJson));
  }

  Future<List<Debt>> getDebts() async {
    final prefs = await SharedPreferences.getInstance();
    final debtsJson = prefs.getString(_keyDebts);
    if (debtsJson == null) return [];
    final List<dynamic> decoded = jsonDecode(debtsJson);
    return decoded.map((json) => Debt.fromJson(json)).toList();
  }

  Future<void> addDebt(Debt debt) async {
    final debts = await getDebts();
    debts.add(debt);
    await saveDebts(debts);
  }

  Future<void> updateDebt(Debt debt) async {
    final debts = await getDebts();
    final index = debts.indexWhere((d) => d.id == debt.id);
    if (index != -1) {
      debts[index] = debt;
      await saveDebts(debts);
    }
  }

  Future<void> deleteDebt(String id) async {
    final debts = await getDebts();
    debts.removeWhere((d) => d.id == id);
    await saveDebts(debts);
  }

  // Clear all data
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserProfile);
    await prefs.remove(_keyTransactions);
    await prefs.remove(_keyGoals);
    await prefs.remove(_keyDebts);
  }
}


