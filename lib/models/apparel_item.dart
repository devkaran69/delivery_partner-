class ApparelItem {
  final String id;
  final String name;
  final String brand;
  final String size;
  final String color;
  final int quantity;
  final double price;
  final String category;
  final String? imageUrl;
  final String? sku;

  ApparelItem({
    required this.id,
    required this.name,
    required this.brand,
    required this.size,
    required this.color,
    this.quantity = 1,
    required this.price,
    this.category = 'Apparel',
    this.imageUrl,
    this.sku,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
      'size': size,
      'color': color,
      'quantity': quantity,
      'price': price,
      'category': category,
      'imageUrl': imageUrl,
      'sku': sku,
    };
  }

  factory ApparelItem.fromJson(Map<String, dynamic> json) {
    return ApparelItem(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      brand: json['brand']?.toString() ?? 'Fashion Store',
      size: json['size']?.toString() ?? 'Free Size',
      color: json['color']?.toString() ?? 'Standard',
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      category: json['category']?.toString() ?? 'Apparel',
      imageUrl: json['imageUrl']?.toString() ?? json['image_url']?.toString(),
      sku: json['sku']?.toString(),
    );
  }
}
