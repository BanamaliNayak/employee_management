class Employee {
  final String id;
  final String name;
  final String designation;
  final String department;
  final String email;
  final String phone;

  Employee({
    required this.id,
    required this.name,
    required this.designation,
    required this.department,
    required this.email,
    required this.phone,
  });

  factory Employee.fromMap(Map<String, dynamic> data, String id) {
    return Employee(
      id: id,
      name: data['name'],
      designation: data['designation'],
      department: data['department'],
      email: data['email'],
      phone: data['phone'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'designation': designation,
      'department': department,
      'email': email,
      'phone': phone,
    };
  }
}
