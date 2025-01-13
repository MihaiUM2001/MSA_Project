class Seller {
  final int id;
  final String? fullName;
  final String? email;
  final String? phoneNumber;
  final String? profilePictureUrl;

  Seller({
    required this.id,
    this.fullName,
    this.email,
    this.phoneNumber,
    this.profilePictureUrl,
  });

  factory Seller.fromJson(Map<String, dynamic> json) {
    return Seller(
      id: json['id'] ?? 0,
      fullName: json['fullName'] as String?,
      email: json['email'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      profilePictureUrl: json['profilePictureURL'] as String?,
    );
  }
}
