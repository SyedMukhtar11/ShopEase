class Product {
  final int id;
  final String title;
  final String description;
  final String category;
  final String brand;
  final String thumbnail;
  final double price;
  final double discountPercentage;
  final double rating;
  final int stock;
  final List<String> images;
  final List<String> tags;

  const Product({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.brand,
    required this.thumbnail,
    required this.price,
    required this.discountPercentage,
    required this.rating,
    required this.stock,
    required this.images,
    required this.tags,
  });

  double get discountedPrice => price * (1 - discountPercentage / 100);

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? '',
      brand: json['brand'] as String? ?? 'Generic',
      thumbnail: json['thumbnail'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      discountPercentage: (json['discountPercentage'] as num?)?.toDouble() ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      images: (json['images'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      tags: (json['tags'] as List?)?.map((e) => e.toString()).toList() ?? const [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'category': category,
        'brand': brand,
        'thumbnail': thumbnail,
        'price': price,
        'discountPercentage': discountPercentage,
        'rating': rating,
        'stock': stock,
        'images': images,
        'tags': tags,
      };
}
