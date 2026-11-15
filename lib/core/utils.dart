String money(double value) => '\$${value.toStringAsFixed(2)}';

/// "mens-shirts" -> "Mens Shirts"
String titleCase(String slug) {
  return slug
      .split(RegExp(r'[-_ ]'))
      .where((w) => w.isNotEmpty)
      .map((w) => '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');
}
