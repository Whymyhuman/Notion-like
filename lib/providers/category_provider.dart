
import 'package:flutter/material.dart';
import 'package:notion_like_app/models/category.dart';
import 'package:notion_like_app/services/database_service.dart';

class CategoryProvider with ChangeNotifier {
  List<Category> _categories = [];
  final DatabaseService _databaseService = DatabaseService();

  List<Category> get categories => _categories;

  CategoryProvider() {
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    _categories = await _databaseService.getCategories();
    if (_categories.isEmpty) {
      // Add default categories if none exist
      await addCategory(Category(name: 'Work', icon: Icons.work, color: Colors.blue));
      await addCategory(Category(name: 'Personal', icon: Icons.person, color: Colors.green));
      await addCategory(Category(name: 'Shopping', icon: Icons.shopping_cart, color: Colors.orange));
      _categories = await _databaseService.getCategories(); // Reload after adding defaults
    }
    notifyListeners();
  }

  Future<void> addCategory(Category category) async {
    await _databaseService.insertCategory(category);
    await _loadCategories();
  }

  Future<void> updateCategory(Category category) async {
    await _databaseService.updateCategory(category);
    await _loadCategories();
  }

  Future<void> deleteCategory(int id) async {
    await _databaseService.deleteCategory(id);
    await _loadCategories();
  }
}

