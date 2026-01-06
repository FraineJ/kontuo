import 'dart:convert';

import 'package:kontuo/data/models/credit_simulation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreditSimulationService {
  static const _keySimulations = 'credit_simulations';

  Future<List<CreditSimulation>> getSimulations() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_keySimulations);
    if (jsonString == null) return [];

    final List decoded = jsonDecode(jsonString);
    return decoded.map((e) => CreditSimulation.fromJson(e)).toList();
  }

  Future<void> saveSimulations(List<CreditSimulation> simulations) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = simulations.map((e) => e.toJson()).toList();
    await prefs.setString(_keySimulations, jsonEncode(jsonList));
  }

  Future<void> addSimulation(CreditSimulation simulation) async {
    final list = await getSimulations();
    list.add(simulation);
    await saveSimulations(list);
  }

  Future<void> deleteSimulation(String id) async {
    final list = await getSimulations();
    list.removeWhere((s) => s.id == id);
    await saveSimulations(list);
  }
}
