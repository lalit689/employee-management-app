// PASTE THIS ENTIRE FILE INTO https://dartpad.dev (select "Flutter" mode)
// for a quick, no-install online preview of the app's core flow
// (login -> employee list from JSONPlaceholder -> details).
// This is a simplified, single-file version for preview purposes only.
// The full, properly structured project (with Provider, multiple files,
// and everything required for submission) is in the rest of this folder.

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(const PreviewApp());

class PreviewApp extends StatelessWidget {
  const PreviewApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Employee Management (Preview)',
      theme: ThemeData(primarySwatch: Colors.indigo, useMaterial3: true),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailCtrl = TextEditingController(text: 'admin@example.com');
  final passCtrl = TextEditingController();
  String? error;

  void login() {
    if (emailCtrl.text.trim() == 'admin@example.com' &&
        passCtrl.text == 'admin123') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const EmployeeListPage()),
      );
    } else {
      setState(() => error = 'Invalid email or password');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.badge_outlined, size: 64, color: Colors.indigo),
              const SizedBox(height: 16),
              TextField(
                controller: emailCtrl,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: passCtrl,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password'),
              ),
              if (error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(error!, style: const TextStyle(color: Colors.red)),
                ),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: login, child: const Text('Login')),
              const SizedBox(height: 8),
              const Text('Demo: admin@example.com / admin123',
                  style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}

class EmployeeListPage extends StatefulWidget {
  const EmployeeListPage({super.key});
  @override
  State<EmployeeListPage> createState() => _EmployeeListPageState();
}

class _EmployeeListPageState extends State<EmployeeListPage> {
  List<dynamic> employees = [];
  List<dynamic> filtered = [];
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final res = await http
          .get(Uri.parse('https://jsonplaceholder.typicode.com/users'));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as List<dynamic>;
        setState(() {
          employees = data;
          filtered = data;
          loading = false;
        });
      } else {
        throw Exception('Status ${res.statusCode}');
      }
    } catch (e) {
      setState(() {
        error = 'Failed to load employees. Pull to refresh to retry.';
        loading = false;
      });
    }
  }

  void search(String q) {
    setState(() {
      filtered = employees
          .where((e) =>
              e['name'].toString().toLowerCase().contains(q.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Employees')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              onChanged: search,
              decoration: const InputDecoration(
                hintText: 'Search by name',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : error != null
                    ? Center(child: Text(error!))
                    : RefreshIndicator(
                        onRefresh: fetchData,
                        child: ListView.builder(
                          itemCount: filtered.length,
                          itemBuilder: (context, i) {
                            final emp = filtered[i];
                            final initials = emp['name']
                                .toString()
                                .split(' ')
                                .map((w) => w.isNotEmpty ? w[0] : '')
                                .take(2)
                                .join();
                            return ListTile(
                              leading: CircleAvatar(child: Text(initials)),
                              title: Text(emp['name']),
                              subtitle: Text(emp['company']['name']),
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => DetailPage(emp: emp),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class DetailPage extends StatelessWidget {
  final Map emp;
  const DetailPage({super.key, required this.emp});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(emp['name'])),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: ${emp['id']}'),
            Text('Email: ${emp['email']}'),
            Text('Phone: ${emp['phone']}'),
            Text('Company: ${emp['company']['name']}'),
            Text('City: ${emp['address']['city']}'),
          ],
        ),
      ),
    );
  }
}
