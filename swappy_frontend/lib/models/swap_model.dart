import 'package:swappy_frontend/models/product_model.dart';
import 'package:swappy_frontend/models/seller_model.dart';

class Swap {
  final int id;
  final Product product;
  final Seller? seller;
  final Seller? buyer;
  final String swapProductTitle;
  final String swapProductDescription;
  final String swapProductImage;
  final bool viewedBySeller;
  final double estimatedRetailPrice;
  final String swapStatus;
  final String? creationDate;

  Swap({
    required this.id,
    required this.product,
    required this.seller,
    required this.buyer,
    required this.swapProductTitle,
    required this.swapProductDescription,
    required this.swapProductImage,
    required this.viewedBySeller,
    required this.estimatedRetailPrice,
    required this.swapStatus,
    this.creationDate,
  });

  factory Swap.fromJson(Map<String, dynamic> json) {
    return Swap(
      id: json['id'],
      product: Product.fromJson(json['product']),
      seller: Seller.fromJson(json['seller']),
      buyer: Seller.fromJson(json['buyer']),
      swapProductTitle: json['swapProductTitle'],
      swapProductDescription: json['swapProductDescription'],
      swapProductImage: json['swapProductImage'],
      viewedBySeller: json['viewedBySeller'],
      estimatedRetailPrice: (json['estimatedRetailPrice'] as num).toDouble(),
      swapStatus: json['swapStatus'],
      creationDate: json['creationDate'],
    );
  }
}
