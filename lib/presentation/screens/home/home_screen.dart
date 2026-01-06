import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/user_profile.dart';
import '../../../data/models/transaction.dart';
import '../../../data/services/storage_service.dart';
import '../../widgets/financial_summary_card.dart';
import '../../widgets/transaction_chart.dart';
import '../../widgets/recent_transactions_widget.dart';
import '../../widgets/goals_widget.dart';
import '../../widgets/debts_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final StorageService _storageService = StorageService();
  UserProfile? _profile;
  List<Transaction> _transactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    final profile = await _storageService.getUserProfile();
    final transactions = await _storageService.getTransactions();

    setState(() {
      _profile = profile;
      _transactions = transactions;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.darkBackground,
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppTheme.positiveGreen,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text(
                  'K',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.primaryBlack,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Kontuo',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w300,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, size: 22),
            onPressed: () {
              // TODO: Implement filter
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.positiveGreen))
          : RefreshIndicator(
              color: AppTheme.positiveGreen,
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_profile != null)
                      FinancialSummaryCard(
                        profile: _profile!,
                        transactions: _transactions,
                      ),
                    const SizedBox(height: 16),
                    TransactionChart(transactions: _transactions),
                    const SizedBox(height: 24),
                    RecentTransactionsWidget(
                      transactions: _transactions,
                      onRefresh: _loadData,
                    ),
                    const SizedBox(height: 24),
                    GoalsWidget(onRefresh: _loadData),
                    const SizedBox(height: 24),
                    DebtsWidget(onRefresh: _loadData),
                    const SizedBox(height: 80), // Space for FAB
                  ],
                ),
              ),
            ),
    );
  }
}


