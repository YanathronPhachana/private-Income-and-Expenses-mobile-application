import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/tag_model.dart';
import '../models/transaction_model.dart';

class LocalController {
  static final LocalController _instance = LocalController._internal();
  factory LocalController() => _instance;

  final ValueNotifier<List<TransactionModel>> transactionsNotifier = ValueNotifier([]);
  final ValueNotifier<List<TagModel>> tagsNotifier = ValueNotifier([]);
  final ValueNotifier<String?> errorNotifier = ValueNotifier(null);

  LocalController._internal() {
    _loadData();
  }

  // Load from SharedPreferences
  Future<void> _loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load Tags
      final String? tagsJson = prefs.getString('tags');
      if (tagsJson != null) {
        final List<dynamic> decoded = jsonDecode(tagsJson);
        tagsNotifier.value = decoded.map((item) => TagModel.fromJson(item)).toList();
      } else {
        // Seed default tags
        final defaultTags = [
          TagModel(id: 'tag_salary', label: 'เงินเดือน', type: 'INCOME'),
          TagModel(id: 'tag_other_income', label: 'รายรับอื่น ๆ', type: 'INCOME'),
          TagModel(id: 'tag_food', label: 'อาหาร', type: 'EXPENSE'),
          TagModel(id: 'tag_travel', label: 'เดินทาง', type: 'EXPENSE'),
          TagModel(id: 'tag_shopping', label: 'ช้อปปิ้ง', type: 'EXPENSE'),
          TagModel(id: 'tag_other_expense', label: 'ค่าใช้จ่ายอื่น ๆ', type: 'EXPENSE'),
        ];
        tagsNotifier.value = defaultTags;
        await _saveTags();
      }

      // Load Transactions
      final String? transactionsJson = prefs.getString('transactions');
      if (transactionsJson != null) {
        final List<dynamic> decoded = jsonDecode(transactionsJson);
        transactionsNotifier.value = decoded.map((item) => TransactionModel.fromJson(item)).toList();
      } else {
        transactionsNotifier.value = [];
      }
      
      errorNotifier.value = null;
    } catch (e) {
      errorNotifier.value = 'ไม่สามารถโหลดข้อมูลได้: $e';
    }
  }

  Future<void> _saveTags() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String tagsJson = jsonEncode(tagsNotifier.value.map((t) => t.toJson()).toList());
      await prefs.setString('tags', tagsJson);
    } catch (e) {
      errorNotifier.value = 'ไม่สามารถบันทึกแท็กได้: $e';
    }
  }

  Future<void> _saveTransactions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String txJson = jsonEncode(transactionsNotifier.value.map((t) => t.toJson()).toList());
      await prefs.setString('transactions', txJson);
    } catch (e) {
      errorNotifier.value = 'ไม่สามารถบันทึกรายการได้: $e';
    }
  }

  TagModel? getTagByPath(String path) {
    final tagId = path.split('/').last;
    try {
      return tagsNotifier.value.firstWhere(
        (tag) => tag.id == tagId || tag.id == path,
        orElse: () => throw Exception(),
      );
    } catch (_) {
      return null;
    }
  }

  double balanceForMonth(DateTime month) {
    double total = 0.0;
    for (var tx in transactionsNotifier.value) {
      if (tx.timestamp.year == month.year && tx.timestamp.month == month.month) {
        if (tx.type == 'INCOME') {
          total += tx.amount;
        } else {
          total -= tx.amount;
        }
      }
    }
    return total;
  }

  double totalIncomeForMonth(DateTime month) {
    double total = 0.0;
    for (var tx in transactionsNotifier.value) {
      if (tx.timestamp.year == month.year && tx.timestamp.month == month.month && tx.type == 'INCOME') {
        total += tx.amount;
      }
    }
    return total;
  }

  double totalExpenseForMonth(DateTime month) {
    double total = 0.0;
    for (var tx in transactionsNotifier.value) {
      if (tx.timestamp.year == month.year && tx.timestamp.month == month.month && tx.type == 'EXPENSE') {
        total += tx.amount;
      }
    }
    return total;
  }

  Future<void> deleteTransaction(String id) async {
    transactionsNotifier.value = transactionsNotifier.value.where((tx) => tx.id != id).toList();
    await _saveTransactions();
  }

  Future<void> addTransaction({
    required double amount,
    required String note,
    required String tagId,
    required DateTime timestamp,
    required String type,
  }) async {
    final newTx = TransactionModel(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      type: type,
      amount: amount,
      timestamp: timestamp,
      note: note,
      tagPath: 'tags/$tagId',
    );
    
    final list = List<TransactionModel>.from(transactionsNotifier.value);
    list.add(newTx);
    list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    transactionsNotifier.value = list;
    await _saveTransactions();
  }

  Future<void> addTag(String label, String type) async {
    final exists = tagsNotifier.value.any(
      (tag) => tag.label.toLowerCase() == label.toLowerCase() && tag.type == type
    );
    if (exists) {
      throw Exception('มีแท็กนี้อยู่ในระบบแล้ว');
    }
    
    final newTag = TagModel(
      id: 'tag_${DateTime.now().microsecondsSinceEpoch}',
      label: label,
      type: type,
    );
    
    final list = List<TagModel>.from(tagsNotifier.value);
    list.add(newTag);
    tagsNotifier.value = list;
    await _saveTags();
  }

  Future<void> deleteTag(String id) async {
    tagsNotifier.value = tagsNotifier.value.where((tag) => tag.id != id).toList();
    await _saveTags();
  }
}
