import 'package:flutter/material.dart';
import '../models/employee.dart';
import '../services/api_service.dart';

enum LoadStatus { initial, loading, success, error }

/// Holds employee data and application state (loading/success/error),
/// and exposes search/filter functionality to the UI.
class EmployeeProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Employee> _allEmployees = [];
  List<Employee> _filteredEmployees = [];
  LoadStatus _status = LoadStatus.initial;
  String _errorMessage = '';
  String _searchQuery = '';
  String _selectedDepartment = 'All';

  List<Employee> get employees => _filteredEmployees;
  LoadStatus get status => _status;
  String get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String get selectedDepartment => _selectedDepartment;

  List<String> get departments {
    final set = _allEmployees.map((e) => e.department).toSet().toList();
    set.sort();
    return ['All', ...set];
  }

  Future<void> fetchEmployees() async {
    _status = LoadStatus.loading;
    notifyListeners();

    try {
      final result = await _apiService.fetchEmployees();
      _allEmployees = result;
      _applyFilters();
      _status = LoadStatus.success;
    } catch (e) {
      _errorMessage = e.toString();
      _status = LoadStatus.error;
    }
    notifyListeners();
  }

  void search(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void filterByDepartment(String department) {
    _selectedDepartment = department;
    _applyFilters();
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedDepartment = 'All';
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    _filteredEmployees = _allEmployees.where((emp) {
      final matchesSearch =
          emp.name.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesDept = _selectedDepartment == 'All' ||
          emp.department == _selectedDepartment;
      return matchesSearch && matchesDept;
    }).toList();
  }
}
