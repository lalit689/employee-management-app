import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/employee_provider.dart';
import '../widgets/employee_card.dart';
import 'employee_detail_screen.dart';
import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EmployeeProvider>().fetchEmployees();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _logout() {
    context.read<AuthProvider>().logout();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  void _clearSearch() {
    _searchController.clear();
    context.read<EmployeeProvider>().clearFilters();
  }

  @override
  Widget build(BuildContext context) {
    final employeeProvider = context.watch<EmployeeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Directory'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Logout',
            onPressed: _logout,
          ),
        ],
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF4F7FF), Color(0xFFEEF2FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Team overview',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                              letterSpacing: 0.4,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${employeeProvider.employees.length} employees',
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF111827),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 58,
                      height: 58,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFFEEF2FF), Color(0xFFE0E7FF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(18)),
                      ),
                      child: const Icon(
                        Icons.groups_rounded,
                        color: Color(0xFF4F46E5),
                        size: 30,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: TextField(
                controller: _searchController,
                onChanged: (value) =>
                    context.read<EmployeeProvider>().search(value),
                decoration: InputDecoration(
                  hintText: 'Search employee by name...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          onPressed: _clearSearch,
                          icon: const Icon(Icons.clear_rounded),
                        )
                      : null,
                ),
              ),
            ),
            if (employeeProvider.status == LoadStatus.success)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 0),
                          children: employeeProvider.departments.map((dept) {
                            final isSelected =
                                dept == employeeProvider.selectedDepartment;
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: ChoiceChip(
                                label: Text(dept),
                                selected: isSelected,
                                onSelected: (_) => context
                                    .read<EmployeeProvider>()
                                    .filterByDepartment(dept),
                                selectedColor: const Color(0xFFE0E7FF),
                                labelStyle: TextStyle(
                                  color: isSelected
                                      ? const Color(0xFF312E81)
                                      : Colors.grey.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                                side: BorderSide(
                                  color: isSelected
                                      ? Colors.transparent
                                      : Colors.grey.shade300,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    if (employeeProvider.selectedDepartment != 'All' ||
                        _searchController.text.isNotEmpty)
                      TextButton.icon(
                        onPressed: _clearSearch,
                        icon: const Icon(Icons.filter_alt_off_rounded, size: 18),
                        label: const Text('Clear'),
                      ),
                  ],
                ),
              ),
            const SizedBox(height: 6),
            Expanded(child: _buildBody(employeeProvider)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(EmployeeProvider provider) {
    switch (provider.status) {
      case LoadStatus.loading:
      case LoadStatus.initial:
        return const Center(child: CircularProgressIndicator());

      case LoadStatus.error:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline_rounded,
                    size: 48, color: Colors.red.shade400),
                const SizedBox(height: 12),
                Text(
                  provider.errorMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.black87),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => provider.fetchEmployees(),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        );

      case LoadStatus.success:
        if (provider.employees.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.search_off_rounded,
                    size: 48, color: Colors.grey.shade400),
                const SizedBox(height: 12),
                Text(
                  'No employees found',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: () => provider.fetchEmployees(),
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 16),
            itemCount: provider.employees.length,
            itemBuilder: (context, index) {
              final employee = provider.employees[index];
              return EmployeeCard(
                employee: employee,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => EmployeeDetailScreen(employee: employee),
                    ),
                  );
                },
              );
            },
          ),
        );
    }
  }
}
