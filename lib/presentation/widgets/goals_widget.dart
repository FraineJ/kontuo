import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/goal.dart';
import '../../data/services/storage_service.dart';
import '../screens/goals/goals_screen.dart';

class GoalsWidget extends StatefulWidget {
  final VoidCallback onRefresh;

  const GoalsWidget({super.key, required this.onRefresh});

  @override
  State<GoalsWidget> createState() => _GoalsWidgetState();
}

class _GoalsWidgetState extends State<GoalsWidget> {
  final StorageService _storageService = StorageService();
  List<Goal> _goals = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGoals();
  }

  Future<void> _loadGoals() async {
    final goals = await _storageService.getGoals();
    setState(() {
      _goals = goals.where((g) => !g.isCompleted).take(3).toList();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Metas Activas',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const GoalsScreen()),
                  ).then((_) {
                    _loadGoals();
                    widget.onRefresh();
                  });
                },
                child: Text(
                  'Ver todas',
                  style: TextStyle(color: AppTheme.positiveGreen),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _isLoading
              ? const Center(child: CircularProgressIndicator(color: AppTheme.positiveGreen))
              : _goals.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.flag,
                              size: 48,
                              color: AppTheme.textTertiary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No hay metas activas',
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Column(
                      children: _goals.map((goal) {
                        return _GoalTile(goal: goal);
                      }).toList(),
                    ),
        ],
      ),
    );
  }
}

class _GoalTile extends StatelessWidget {
  final Goal goal;

  const _GoalTile({required this.goal});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: Stack(
              children: [
                SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(
                    value: goal.progress.clamp(0.0, 1.0),
                    strokeWidth: 4,
                    backgroundColor: AppTheme.borderColor,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accentBlue),
                  ),
                ),
                Center(
                  child: Text(
                    '${(goal.progress * 100).toInt()}%',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  goal.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${goal.currentAmount.toStringAsFixed(0)} / \$${goal.targetAmount.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

