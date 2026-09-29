class Employee {
  final int id;
  final String name;
  final String username;
  final String email;
  final String phone;
  final String website;
  final String department; // mapped from company.name
  final String city; // mapped from address.city

  Employee({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    required this.phone,
    required this.website,
    required this.department,
    required this.city,
  });

  /// Initials used to render a simple local avatar (JSONPlaceholder has no images).
  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0].substring(0, 1).toUpperCase();
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
  }

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      website: json['website'] ?? '',
      department: (json['company'] != null ? json['company']['name'] : null) ??
          'General',
      city: (json['address'] != null ? json['address']['city'] : null) ?? '',
    );
  }
}
