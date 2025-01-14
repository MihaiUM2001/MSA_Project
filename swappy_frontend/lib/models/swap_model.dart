class Swap {
  final int id;
  final String? title;
  final String? description;
  final String? imageUrl;
  final double? estimatedRetailPrice;
  final String? status;
  final String? creationDate;

  Swap({
    required this.id,
    this.title,
    this.description,
    this.imageUrl,
    this.estimatedRetailPrice,
    this.status,
    this.creationDate,
  });

  factory Swap.fromJson(Map<String, dynamic> json) {
    return Swap(
      id: json['id'],
      title: json['swapProductTitle'],
      description: json['swapProductDescription'],
      imageUrl: json['swapProductImage'],
      estimatedRetailPrice: json['estimatedRetailPrice']?.toDouble(),
      status: json['swapStatus'],
      creationDate: json['creationDate'],
    );
  }
}
