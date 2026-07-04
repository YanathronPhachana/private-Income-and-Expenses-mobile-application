class TagModel {
  final String id;
  final String label;
  final String type; // 'EXPENSE' or 'INCOME'

  TagModel({
    required this.id,
    required this.label,
    required this.type,
  });

  factory TagModel.fromJson(Map<String, dynamic> json) {
    return TagModel(
      id: json['id'] as String,
      label: json['label'] as String,
      type: json['type'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'type': type,
    };
  }
}
