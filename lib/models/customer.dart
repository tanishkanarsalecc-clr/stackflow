class Customer {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String address;
  final double outstanding;

  Customer({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.address,
    required this.outstanding,
  });

  factory Customer.fromMap(
      String id,
      Map<String, dynamic> map,
      ) {
    return Customer(
      id: id,
      name: (map['name'] ?? '').toString(),
      phone: (map['phone'] ?? '').toString(),
      email: (map['email'] ?? '').toString(),
      address: (map['address'] ?? '').toString(),
      outstanding:
      ((map['outstanding'] ?? 0) as num)
          .toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
      'outstanding': outstanding,
    };
  }
}