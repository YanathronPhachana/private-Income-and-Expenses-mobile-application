import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../controllers/local_controller.dart';
import '../models/transaction_model.dart';
import '../models/tag_model.dart';
import '../main.dart';
import 'add_transaction_screen.dart';
import 'manage_tags_screen.dart';

class DashboardScreen extends StatefulWidget {
  final bool showFAB;
  final VoidCallback? onAddTransactionPressed;

  const DashboardScreen({
    super.key,
    this.showFAB = true,
    this.onAddTransactionPressed,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final LocalController _controller = LocalController();
  final NumberFormat _currencyFormat = NumberFormat.currency(locale: 'th_TH', symbol: '฿', decimalDigits: 2);
  final DateFormat _dateFormat = DateFormat('dd MMM yyyy, HH:mm น.', 'th_TH');
  DateTime _currentMonth = DateTime.now();
  final DateFormat _monthFormat = DateFormat('MMMM yyyy', 'th_TH');
  final DateFormat _rangeFormat = DateFormat('d MMM yy', 'th_TH');
  DateTimeRange? _selectedDateRange;

  Widget _buildMonthSelector() {
    if (_selectedDateRange != null) {
      return const SizedBox.shrink(); // Hide month selector when custom range is active
    }
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? const Color(0xFFF1F5F9) : const Color(0xFF1E293B);
    final buttonColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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

  Future<void> _selectCustomDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: _selectedDateRange ?? DateTimeRange(
        start: DateTime.now().subtract(const Duration(days: 7)),
        end: DateTime.now(),
      ),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Colors.white,
              surface: isDark ? const Color(0xFF1E293B) : Colors.white,
              onSurface: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF1E293B),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }

  Widget _buildBudgetAlertBanner(double balance, double totalIncome, double totalExpense) {
    // Only display alert banner if there is some activity (either income or expense)
    if (totalIncome == 0 && totalExpense == 0) {
      return const SizedBox.shrink();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isOverspent = balance < 0;
    final alertColor = isOverspent 
        ? (isDark ? const Color(0xFF7F1D1D).withValues(alpha: 0.2) : const Color(0xFFFEF2F2)) 
        : (isDark ? const Color(0xFF064E3B).withValues(alpha: 0.2) : const Color(0xFFECFDF5));
    final borderColor = isOverspent 
        ? (isDark ? const Color(0xFFEF4444) : const Color(0xFFFCA5A5)) 
        : (isDark ? const Color(0xFF10B981) : const Color(0xFF6EE7B7));
    final textColor = isOverspent 
        ? (isDark ? const Color(0xFFFCA5A5) : const Color(0xFF991B1B)) 
        : (isDark ? const Color(0xFFA7F3D0) : const Color(0xFF065F46));
    final icon = isOverspent ? Icons.warning_amber_rounded : Icons.check_circle_outline_rounded;
    
    final String timeWord = _selectedDateRange != null ? 'ช่วงนี้' : 'เดือนนี้';

    final message = isOverspent
        ? '$timeWordใช้เงินเกินตัวไป ${_currencyFormat.format(balance.abs())}'
        : '$timeWordมีเงินเหลือเก็บ ${_currencyFormat.format(balance)}';

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: alertColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Icon(icon, color: textColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: textColor,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner() {
    return ValueListenableBuilder<String?>(
      valueListenable: _controller.errorNotifier,
      builder: (context, error, _) {
        if (error == null) return const SizedBox.shrink();
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final bannerColor = isDark ? const Color(0xFF7F1D1D).withValues(alpha: 0.2) : const Color(0xFFFEF2F2);
        final borderColor = isDark ? const Color(0xFFEF4444) : const Color(0xFFFCA5A5);
        final textColor = isDark ? const Color(0xFFFCA5A5) : const Color(0xFF991B1B);
        return Container(
          margin: const EdgeInsets.fromLTRB(20, 8, 20, 4),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: bannerColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              Icon(Icons.error_outline_rounded, color: textColor, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  error,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF5EFE6);
    final cardBgColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final titleColor = isDark ? const Color(0xFFF1F5F9) : const Color(0xFF1E293B);
    final shadowColor = isDark ? Colors.black.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.05);

    return Scaffold(
      backgroundColor: scaffoldBgColor,
      appBar: AppBar(
        title: Text(
          'กระเป๋าเงินของฉัน',
          style: TextStyle(
            color: titleColor,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        actions: [
          // Theme Toggle Button
          ValueListenableBuilder<ThemeMode>(
            valueListenable: themeNotifier,
            builder: (context, currentMode, _) {
              final isDarkTheme = currentMode == ThemeMode.dark;
              final buttonBg = isDarkTheme ? const Color(0xFF1E293B) : Colors.white;
              final shadow = isDarkTheme ? Colors.black.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.05);
              return IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: buttonBg,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: shadow,
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) {
                      return ScaleTransition(scale: animation, child: child);
                    },
                    child: Icon(
                      isDarkTheme ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                      key: ValueKey<bool>(isDarkTheme),
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                tooltip: isDarkTheme ? 'โหมดสว่าง' : 'โหมดมืด',
                onPressed: () {
                  themeNotifier.value = isDarkTheme ? ThemeMode.light : ThemeMode.dark;
                },
              );
            },
          ),
          const SizedBox(width: 8),
          
          // Manage Tags Button
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: cardBgColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: shadowColor,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(Icons.tag_rounded, color: Theme.of(context).colorScheme.primary),
            ),
            tooltip: 'จัดการแท็ก',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ManageTagsScreen()),
              );
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: _controller.transactionsNotifier,
        builder: (context, List<TransactionModel> transactions, child) {
          List<TransactionModel> filteredTransactions;
          if (_selectedDateRange != null) {
            final startOfDay = DateTime(_selectedDateRange!.start.year, _selectedDateRange!.start.month, _selectedDateRange!.start.day);
            final endOfDay = DateTime(_selectedDateRange!.end.year, _selectedDateRange!.end.month, _selectedDateRange!.end.day, 23, 59, 59, 999);
            filteredTransactions = transactions.where((tx) =>
              tx.timestamp.isAfter(startOfDay.subtract(const Duration(microseconds: 1))) &&
              tx.timestamp.isBefore(endOfDay.add(const Duration(microseconds: 1)))
            ).toList();
          } else {
            filteredTransactions = transactions.where((tx) =>
              tx.timestamp.year == _currentMonth.year &&
              tx.timestamp.month == _currentMonth.month
            ).toList();
          }

          // Calculate summary values for the selected range
          double balance = 0.0;
          double totalIncome = 0.0;
          double totalExpense = 0.0;
          for (var tx in filteredTransactions) {
            if (tx.type == 'INCOME') {
              totalIncome += tx.amount;
              balance += tx.amount;
            } else {
              totalExpense += tx.amount;
              balance -= tx.amount;
            }
          }

          final isDark = Theme.of(context).brightness == Brightness.dark;

          return ValueListenableBuilder(
            valueListenable: _controller.tagsNotifier,
            builder: (context, List<TagModel> tags, child) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Error Banner ---
                  _buildErrorBanner(),

                  // --- Month Selector ---
                  _buildMonthSelector(),
                  
                  // --- Dashboard Card ---
                  _buildBalanceCard(balance, totalIncome, totalExpense),

                  // --- Alert Banner ---
                  _buildBudgetAlertBanner(balance, totalIncome, totalExpense),
                  
                  // --- Section Header ---
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            _selectedDateRange != null
                                ? 'รายการธุรกรรม (${_rangeFormat.format(_selectedDateRange!.start)} - ${_rangeFormat.format(_selectedDateRange!.end)})'
                                : 'รายการธุรกรรมในเดือนนี้',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF1E293B),
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            if (_selectedDateRange != null)
                              IconButton(
                                icon: const Icon(Icons.clear_rounded, color: Color(0xFFEF4444)),
                                tooltip: 'ล้างตัวกรองช่วงเวลา',
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () {
                                  setState(() {
                                    _selectedDateRange = null;
                                  });
                                },
                              ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: Icon(
                                Icons.calendar_month_rounded,
                                color: _selectedDateRange != null
                                    ? Theme.of(context).colorScheme.primary
                                    : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                              ),
                              tooltip: 'เลือกช่วงเวลา',
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: _selectCustomDateRange,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // --- Transactions List ---
                  Expanded(
                    child: filteredTransactions.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: filteredTransactions.length,
                            itemBuilder: (context, index) {
                              final tx = filteredTransactions[index];
                              final tag = _controller.getTagByPath(tx.tagPath);
                              return _buildTransactionItem(tx, tag);
                            },
                          ),
                  ),
                ],
              );
            },
          );
        },
      ),
      floatingActionButton: widget.showFAB
          ? FloatingActionButton.extended(
              onPressed: () {
                if (widget.onAddTransactionPressed != null) {
                  widget.onAddTransactionPressed!();
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AddTransactionScreen()),
                  );
                }
              },
              backgroundColor: Theme.of(context).colorScheme.primary,
              elevation: 4,
              icon: const Icon(Icons.add_rounded, color: Colors.white, size: 24),
              label: const Text(
                'เพิ่มธุรกรรม',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            )
          : null,
    );
  }

  // Balance & Income/Expense Card Widget
  Widget _buildBalanceCard(double balance, double totalIncome, double totalExpense) {

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFDDC484), Color(0xFFC4AB6C), Color(0xFF976623)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF976623).withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ยอดเงินคงเหลือทั้งหมด',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _currencyFormat.format(balance),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              // Income Column
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_downward_rounded,
                        color: Color(0xFF34D399), // Mint Green
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'รายรับ',
                            style: TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _currencyFormat.format(totalIncome),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Divider Line
              Container(
                height: 36,
                width: 1,
                color: Colors.white24,
                margin: const EdgeInsets.symmetric(horizontal: 8),
              ),

              // Expense Column
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_upward_rounded,
                        color: Color(0xFFF87171), // Soft Red
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'รายจ่าย',
                            style: TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _currencyFormat.format(totalExpense),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Single Transaction Item UI
  Widget _buildTransactionItem(TransactionModel tx, TagModel? tag) {
    final isExpense = tx.type == 'EXPENSE';
    final amountColor = isExpense ? const Color(0xFFEF4444) : const Color(0xFF10B981);
    final amountSign = isExpense ? '-' : '+';
    
    // Choose beautiful background color and icon based on tag
    IconData itemIcon;
    Color iconColor;
    Color iconBg;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final titleTextColor = isDark ? const Color(0xFFF1F5F9) : const Color(0xFF1E293B);
    final tagBgColor = isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9);
    final tagTextColor = isDark ? const Color(0xFFCBD5E1) : const Color(0xFF64748B);

    if (tag != null) {
      if (tag.type == 'INCOME') {
        itemIcon = Icons.account_balance_wallet_rounded;
        iconColor = const Color(0xFF10B981);
        iconBg = isDark ? const Color(0xFF064E3B) : const Color(0xFFD1FAE5);
      } else {
        // Expense types matching label roughly
        if (tag.label.contains('อาหาร')) {
          itemIcon = Icons.restaurant_rounded;
          iconColor = const Color(0xFFF59E0B);
          iconBg = isDark ? const Color(0xFF78350F) : const Color(0xFFFEF3C7);
        } else if (tag.label.contains('เดินทาง')) {
          itemIcon = Icons.directions_car_rounded;
          iconColor = const Color(0xFF3B82F6);
          iconBg = isDark ? const Color(0xFF1E3A8A) : const Color(0xFFDBEAFE);
        } else if (tag.label.contains('ช้อป')) {
          itemIcon = Icons.shopping_bag_rounded;
          iconColor = const Color(0xFFEC4899);
          iconBg = isDark ? const Color(0xFF831843) : const Color(0xFFFCE7F3);
        } else {
          itemIcon = Icons.receipt_long_rounded;
          iconColor = const Color(0xFF8B5CF6);
          iconBg = isDark ? const Color(0xFF4C1D95) : const Color(0xFFEDE9FE);
        }
      }
    } else {
      itemIcon = isExpense ? Icons.output_rounded : Icons.login_rounded;
      iconColor = isExpense ? const Color(0xFF6B7280) : const Color(0xFF10B981);
      iconBg = isExpense 
          ? (isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6)) 
          : (isDark ? const Color(0xFF064E3B) : const Color(0xFFD1FAE5));
    }

    return Dismissible(
      key: Key(tx.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFFEE2E2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444), size: 28),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (context) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            final dialogBg = isDark ? const Color(0xFF1E293B) : Colors.white;
            final titleColor = isDark ? const Color(0xFFF1F5F9) : const Color(0xFF1E293B);
            final contentColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
            
            return AlertDialog(
              backgroundColor: dialogBg,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Text(
                'ยืนยันการลบรายการ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: titleColor,
                ),
              ),
              content: Text(
                'คุณแน่ใจหรือไม่ว่าต้องการลบรายการ "${tx.note.isNotEmpty ? tx.note : (tag?.label ?? 'ธุรกรรม')}" นี้?',
                style: TextStyle(
                  color: contentColor,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(
                    'ยกเลิก',
                    style: TextStyle(
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF4444),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'ลบรายการ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
      onDismissed: (direction) {
        _controller.deleteTransaction(tx.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ลบรายการ "${tx.note.isNotEmpty ? tx.note : (tag?.label ?? 'ธุรกรรม')}" เรียบร้อยแล้ว'),
            backgroundColor: const Color(0xFF334155),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      },
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddTransactionScreen(
                transactionToEdit: tx,
              ),
            ),
          );
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.black.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Category Icon
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: iconBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(itemIcon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 14),
              
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tx.note.isNotEmpty ? tx.note : (tag?.label ?? 'ไม่มีบันทึก'),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: titleTextColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (tag != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: tagBgColor,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              tag.label,
                              style: TextStyle(
                                color: tagTextColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                        ],
                        Expanded(
                          child: Text(
                            _dateFormat.format(tx.timestamp),
                            style: const TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 11,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
  
              // Amount
              Text(
                '$amountSign${_currencyFormat.format(tx.amount).replaceAll('฿', '')}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: amountColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Empty state when there are no transactions
  Widget _buildEmptyState() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconBgColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFEEF2F6);
    final titleColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final subtitleColor = isDark ? const Color(0xFF475569) : const Color(0xFF94A3B8);

    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.receipt_long_rounded,
                size: 64,
                color: titleColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'ยังไม่มีรายการธุรกรรมใด ๆ',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: titleColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'เริ่มจดบันทึกรายรับ-รายจ่ายของคุณได้ตอนนี้เลย!',
              style: TextStyle(
                fontSize: 13,
                color: subtitleColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
