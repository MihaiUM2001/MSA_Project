import 'seller_model.dart';

class Product {
  final int? id;
  final String? productTitle;
  final String? productDescription;
  final String? productImage;
  final String? swapPreference;
  final double? estimatedRetailPrice;
  final Seller? seller;
  final String? publishDate;
  final int? numberOfViews;
  final bool? isVisible;
  final List<dynamic>? swaps;

  Product({
    this.id,
    this.productTitle,
    this.productDescription,
    this.productImage,
    this.swapPreference,
    this.estimatedRetailPrice,
    this.seller,
    this.publishDate,
    this.numberOfViews,
    this.isVisible,
    this.swaps,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      productTitle: json['productTitle'],
      productDescription: json['productDescription'],
      productImage: json['productImage'],
      swapPreference: json['swapPreference'],
      estimatedRetailPrice: json['estimatedRetailPrice'],
      seller: json['seller'] != null ? Seller.fromJson(json['seller']) : null,
      publishDate: json['publishDate'],
      numberOfViews: json['numberOfViews'],
      isVisible: json['isVisible'],
      swaps: json['swaps'],
    );
  }
}
