class Product {
  final int id;
  final String name;
  final double totalWeight;
  final double manualPrice;
  final double laborCost;
  final int categoryId;
  final String productDescription;
  final String productImage;
   // Optional field

  Product({
    required this.id,
    required this.name,
    required this.totalWeight,
    required this.manualPrice,
    required this.laborCost,
    required this.categoryId,
    required this.productDescription,
    required this.productImage,

  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      name: json['name'] as String,
      totalWeight: (json['totalWeight'] as num).toDouble(),
      manualPrice: (json['manualPrice'] as num).toDouble(),
      laborCost: (json['laborCost'] as num).toDouble(),
      categoryId: json['categoryId'] as int,
      productDescription: json['productDescription'] as String,
      productImage: json['productImage'] as String? ?? '',
       // May be null if not provided
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "totalWeight": totalWeight,
      "manualPrice": manualPrice,
      "laborCost": laborCost,
      "categoryId": categoryId,
      "productDescription": productDescription,
      "productImage": productImage,

    };
  }
}
