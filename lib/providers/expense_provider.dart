import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../services/api_service.dart';

class ExpenseProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Expense> _items = [];
  bool _isLoading = false;

  List<Expense> get items => _items;
  bool get isLoading => _isLoading;
  double get totalBalance => _items.fold(0.0, (sum, item) => sum + item.amount);

  Future<void> loadExpenses() async {
    _isLoading = true;
    notifyListeners();
    try {
      _items = await _apiService.fetchExpenses();
    } catch (e) {
      debugPrint("Load error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addExpense(String title, double amount, String category) async {
    final newExp = Expense(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title, 
      amount: amount, 
      category: category, 
      date: DateTime.now(),
    );
    
    // Update local UI immediately
    _items.insert(0, newExp);
    notifyListeners();
    
    try {
      await _apiService.addExpense(newExp);
    } catch (e) {
      debugPrint("Server add failed, but keeping local data: $e");
    }
  }

  Future<void> updateExpense(String id, String title, double amount, String category) async {
    final index = _items.indexWhere((item) => item.id == id);
    if (index == -1) return;
    
    // Update local UI immediately
    _items[index] = Expense(
      id: id, 
      title: title, 
      amount: amount, 
      category: category, 
      date: _items[index].date
    );
    notifyListeners();

    try {
      // We still try to tell the server, but we REMOVED the rollback logic
      await _apiService.updateExpense(_items[index]);
    } catch (e) {
      debugPrint("Server update failed (common in sandbox), keeping UI as is: $e");
    }
  }

  Future<void> deleteExpense(String id) async {
    final index = _items.indexWhere((item) => item.id == id);
    if (index == -1) return;
    
    _items.removeAt(index);
    notifyListeners();
    
    try {
      await _apiService.deleteExpense(id);
    } catch (e) {
      debugPrint("Server delete failed: $e");
    }
  }
}