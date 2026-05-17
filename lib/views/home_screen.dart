import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import '../models/expense.dart';

class HomeScreen extends StatelessWidget {
  final List<String> categories = ["Food", "Education", "Transportation", "Entertainment", "Shopping", "Other"];

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF5F5),
      body: Column(
        children: [
          Container(
            height: 280, width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(60), bottomRight: Radius.circular(60)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("TOTAL BALANCE", style: TextStyle(color: Color(0xFFA6867B), letterSpacing: 2)),
                Text("${provider.totalBalance.toStringAsFixed(2)} Birr", 
                  style: const TextStyle(color: Color(0xFF4A2C2C), fontSize: 38, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Expanded(
            child: provider.isLoading 
              ? const Center(child: CircularProgressIndicator(color: Color(0xFFA6867B)))
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: provider.items.length,
                  itemBuilder: (context, index) {
                    final item = provider.items[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 15),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25)),
                      child: ListTile(
                        title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(item.category),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text("${item.amount.toStringAsFixed(2)} Birr", 
                              style: const TextStyle(color: Color(0xFF4A2C2C), fontWeight: FontWeight.bold)),
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, color: Colors.blueAccent, size: 20),
                              onPressed: () => _showForm(context, expense: item),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_sweep_outlined, color: Colors.redAccent, size: 20),
                              onPressed: () => provider.deleteExpense(item.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFA6867B),
        onPressed: () => _showForm(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showForm(BuildContext context, {Expense? expense}) {
    final tController = TextEditingController(text: expense?.title ?? "");
    final aController = TextEditingController(text: expense?.amount.toString() ?? "");
    String selectedCategory = (expense != null && categories.contains(expense.category)) 
        ? expense.category 
        : categories[0];

    showModalBottomSheet(
      context: context, 
      isScrollControlled: true, 
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 20, left: 30, right: 30, top: 30),
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(40))),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(expense == null ? "Add Expense" : "Edit Expense", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              TextField(controller: tController, decoration: const InputDecoration(labelText: "Title")),
              TextField(controller: aController, decoration: const InputDecoration(labelText: "Amount"), keyboardType: TextInputType.number),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (val) => setModalState(() => selectedCategory = val!),
                decoration: const InputDecoration(labelText: "Category"),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity, height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF3EFEF), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                  onPressed: () {
                    final provider = context.read<ExpenseProvider>();
                    if (expense == null) {
                      provider.addExpense(tController.text, double.parse(aController.text), selectedCategory);
                    } else {
                      provider.updateExpense(expense.id, tController.text, double.parse(aController.text), selectedCategory);
                    }
                    Navigator.pop(context);
                  },
                  child: Text(expense == null ? "Save" : "Update", style: const TextStyle(color: Color(0xFF7B5B9E))),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}