import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../controllers/local_controller.dart';
import '../models/tag_model.dart';
import '../models/transaction_model.dart';

class SummaryScreen extends StatefulWidget {
  const SummaryScreen({super.key});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  final LocalController _controller = LocalController();
  final NumberFormat _currencyFormat = NumberFormat.currency(locale: 'th_TH', symbol: '฿', decimalDigits: 2);
  String _selectedType = 'EXPENSE'; // Toggle between EXPENSE and INCOME
  DateTime _currentMonth = DateTime.now();
  final DateFormat _monthFormat = DateFormat('MMMM yyyy', 'th_TH');

  Widget _buildMonthSelector() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? const Color(0xFFF1F5F9) : const Color(0xFF1E293B);
    final buttonColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: buttonColor, size: 16),
            onPressed: () {
              setState(() {
                _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
              });
            },
          ),
          Text(
            _monthFormat.format(_currentMonth),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          IconButton(
            icon: Icon(Icons.arrow_forward_ios_rounded, color: buttonColor, size: 16),
            onPressed: () {
              setState(() {
                _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
              });
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF5EFE6);
    final titleColor = isDark ? const Color(0xFFF1F5F9) : const Color(0xFF1E293B);

    return Scaffold(
      backgroundColor: scaffoldBgColor,
      appBar: AppBar(
        title: Text(
          'สรุปผลการเงิน',
          style: TextStyle(
            color: titleColor,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      body: ValueListenableBuilder(
        valueListenable: _controller.transactionsNotifier,
        builder: (context, List<TransactionModel> transactions, child) {
          return ValueListenableBuilder(
            valueListenable: _controller.tagsNotifier,
            builder: (context, List<TagModel> tags, child) {
              // 1. Calculate category-wise statistics
              final Map<String, double> categoryTotals = {};
              double totalAmountForSelectedType = 0.0;

              // Filter transactions matching the selected type and selected month
              final filteredTxs = transactions.where((tx) => 
                tx.type == _selectedType &&
                tx.timestamp.year == _currentMonth.year &&
                tx.timestamp.month == _currentMonth.month
              ).toList();

              for (var tx in filteredTxs) {
                final tag = _controller.getTagByPath(tx.tagPath);
                final label = tag?.label ?? 'อื่น ๆ';
                categoryTotals[label] = (categoryTotals[label] ?? 0.0) + tx.amount;
                totalAmountForSelectedType += tx.amount;
              }

              // Sort categories by amount descending
              final sortedCategories = categoryTotals.entries.toList()
                ..sort((a, b) => b.value.compareTo(a.value));

              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- Month Selector ---
                    _buildMonthSelector(),
                    const SizedBox(height: 8),

                    // --- Type Toggle Switch (Expense vs Income) ---
                    _buildTypeToggle(),
                    const SizedBox(height: 24),

                    // --- Total Card ---
                    _buildTotalCard(totalAmountForSelectedType),
                    const SizedBox(height: 24),

                    // --- Breakdown Header ---
                    Text(
                      'สัดส่วนการใช้จ่ายรายหมวดหมู่',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: titleColor,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // --- Category breakdown list ---
                    totalAmountForSelectedType == 0
                        ? _buildEmptyState()
                        : Column(
                            children: sortedCategories.map((entry) {
                              final percentage = totalAmountForSelectedType > 0
                                  ? (entry.value / totalAmountForSelectedType)
                                  : 0.0;
                              return _buildCategoryBarItem(entry.key, entry.value, percentage);
                            }).toList(),
                          ),
                    const SizedBox(height: 32),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Segmented control to toggle between Expense and Income
  Widget _buildTypeToggle() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final containerBg = isDark ? const Color(0xFF1E293B) : const Color(0xFFEEF2F6);
    final textUnselected = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Container(
      decoration: BoxDecoration(
        color: containerBg,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedType = 'EXPENSE';
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _selectedType == 'EXPENSE' ? const Color(0xFFEF4444) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  'สรุปรายจ่าย',
                  style: TextStyle(
                    color: _selectedType == 'EXPENSE' ? Colors.white : textUnselected,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedType = 'INCOME';
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _selectedType == 'INCOME' ? const Color(0xFF10B981) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  'สรุปรายรับ',
                  style: TextStyle(
                    color: _selectedType == 'INCOME' ? Colors.white : textUnselected,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Total summary card for the selected type
  Widget _buildTotalCard(double total) {
    final isExpense = _selectedType == 'EXPENSE';
    final cardBgColors = isExpense
        ? [const Color(0xFFFCA5A5), const Color(0xFFEF4444)] // red gradient
        : [const Color(0xFF6EE7B7), const Color(0xFF10B981)]; // green gradient
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: cardBgColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (_selectedType == 'EXPENSE' ? const Color(0xFFEF4444) : const Color(0xFF10B981)).withValues(alpha: 0.25),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isExpense ? 'ยอดรายจ่ายรวมทั้งหมด' : 'ยอดรายรับรวมทั้งหมด',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _currencyFormat.format(total),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // A category progress bar item
  Widget _buildCategoryBarItem(String categoryName, double amount, double percentage) {
    final isExpense = _selectedType == 'EXPENSE';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final titleColor = isDark ? const Color(0xFFF1F5F9) : const Color(0xFF1E293B);
    final subtitleColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final progressTrackBg = isDark ? const Color(0xFF0F172A) : const Color(0xFFEEF2F6);
    
    // Theme colors based on category types
    Color barColor;
    if (isExpense) {
      if (categoryName.contains('อาหาร')) {
        barColor = const Color(0xFFF59E0B); // Amber
      } else if (categoryName.contains('เดินทาง')) {
        barColor = const Color(0xFF3B82F6); // Blue
      } else if (categoryName.contains('ช้อป')) {
        barColor = const Color(0xFFEC4899); // Pink
      } else {
        barColor = const Color(0xFF8B5CF6); // Purple
      }
    } else {
      barColor = const Color(0xFF10B981); // Emerald Green
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.01),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                categoryName,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: titleColor,
                ),
              ),
              Text(
                _currencyFormat.format(amount),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: titleColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: percentage,
                    backgroundColor: progressTrackBg,
                    valueColor: AlwaysStoppedAnimation<Color>(barColor),
                    minHeight: 10,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${(percentage * 100).toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: subtitleColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Placeholder when no transactions exist for the selected type
  Widget _buildEmptyState() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subtitleColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.pie_chart_outline_rounded,
            size: 56,
            color: subtitleColor.withValues(alpha: 0.7),
          ),
          const SizedBox(height: 12),
          Text(
            'ไม่มีข้อมูลสำหรับการสรุปผล',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: subtitleColor,
            ),
          ),
        ],
      ),
    );
  }
}
