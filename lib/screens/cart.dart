import '../screens/cart_item.dart';

class Cart {
  final int id;
  List<CartItem> items;
  final String userId;
  double tax;

  Cart({
    required this.id,
    required this.items,
    required this.userId,
    required this.tax,
  });

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      id: json['id'] as int,
      items: (json['items'] as List<dynamic>)
          .map((item) => CartItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      userId: json['userId'] as String,
      tax: (json['tax'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "items": items.map((item) => item.toJson()).toList(),
      "userId": userId,
      "tax": tax,
    };
  }
}
