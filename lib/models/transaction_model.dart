class TransactionModel {
  final String id;
  final String type; // 'EXPENSE' or 'INCOME'
  final double amount;
  final DateTime timestamp;
  final String note;
  final String tagPath; // e.g. 'tags/tagId' or 'tagId'

  TransactionModel({
    required this.id,
    required this.type,
    required this.amount,
    required this.timestamp,
    required this.note,
    required this.tagPath,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      type: json['type'] as String,
      amount: (json['amount'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      note: json['note'] as String,
      tagPath: json['tagPath'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'amount': amount,
      'timestamp': timestamp.toIso8601String(),
      'note': note,
      'tagPath': tagPath,
    };
  }
}
