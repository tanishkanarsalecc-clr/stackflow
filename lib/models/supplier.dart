class Supplier {
  final String id;
  final String name;
  final String phone;
  final double totalDue;

  Supplier({
    required this.id,
    required this.name,
    required this.phone,
    this.totalDue = 0,
  });

  factory Supplier.fromMap(
      String id,
      Map<String, dynamic> map,
      ) {
    return Supplier(
      id: id,
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      totalDue: (map['totalDue'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'totalDue': totalDue,
    };
  }
}