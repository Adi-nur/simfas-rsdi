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
}
