class Expense {
  final String id;
  final String title;
  final double amount;
  final String category;
  final DateTime date;

  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    final dataMap = json['data'] as Map<String, dynamic>? ?? {};
    return Expense(
      id: json['id'].toString(),
      title: json['name'] ?? 'Untitled', 
      amount: double.tryParse(dataMap['amount'].toString()) ?? 0.0,
      category: dataMap['category'] ?? 'Other',
      date: DateTime.parse(dataMap['date'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() => {
        "name": title,
        "data": {
          "amount": amount,
          "category": category,
          "date": date.toIso8601String(),
        }
      };
}