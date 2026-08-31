class Supplier {
  final String id;
  final String name;
  final String address;
  final String pic;
  final String phone;
  final String? email;
  final bool isActive;

  const Supplier({
    required this.id,
    required this.name,
    required this.address,
    required this.pic,
    required this.phone,
    this.email,
    this.isActive = true,
  });

  factory Supplier.fromMap(Map<String, dynamic> map) {
    return Supplier(
      id: map['id']?.toString() ?? '',
      name: map['name'] ?? '',
      address: map['address'] ?? '',
      pic: map['pic'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'],
      isActive: map['is_active'] ?? true,
    );
  }
}
