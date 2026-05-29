class Customer {
  String id;
  String name;
  String phone;
  String location;

  Customer({
    required this.id,
    required this.name,
    required this.phone,
    required this.location,
  });

  factory Customer.fromJson(Map<String, dynamic> json, String docId) {
    return Customer(
      id: docId,
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      location: json['location'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'location': location,
    };
  }
}