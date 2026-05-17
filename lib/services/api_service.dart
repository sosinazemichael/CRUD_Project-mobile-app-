import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/expense.dart';

class ApiService {
  final String baseUrl = "https://api.restful-api.dev/objects";

  Future<List<Expense>> fetchExpenses() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      return data
          .where((item) => item['data'] != null && item['data']['amount'] != null)
          .map((item) => Expense.fromJson(item))
          .toList();
    } else {
      throw Exception('Failed to load expenses');
    }
  }

  Future<void> addExpense(Expense expense) async {
    await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(expense.toJson()),
    );
  }

  Future<void> updateExpense(Expense expense) async {
    final response = await http.put(
      Uri.parse('$baseUrl/${expense.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(expense.toJson()),
    );
    if (response.statusCode != 200) throw Exception('Update failed');
  }

  Future<void> deleteExpense(String id) async {
    await http.delete(Uri.parse('$baseUrl/$id'));
  }
}