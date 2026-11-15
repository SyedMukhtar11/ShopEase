import 'package:flutter_test/flutter_test.dart';
import 'package:shopease/core/utils.dart';
import 'package:shopease/core/validators.dart';
import 'package:shopease/models/product.dart';

void main() {
  group('Product', () {
    test('fromJson parses fields and computes discounted price', () {
      final p = Product.fromJson({
        'id': 1,
        'title': 'Test',
        'price': 100,
        'discountPercentage': 10,
        'rating': 4.5,
        'stock': 3,
        'category': 'beauty',
        'thumbnail': 'url',
      });
      expect(p.discountedPrice, closeTo(90, 0.001));
      expect(p.brand, 'Generic'); // default when missing
      expect(p.images, isEmpty);
    });
  });

  group('Validators', () {
    test('email', () {
      expect(Validators.email(''), isNotNull);
      expect(Validators.email('abc'), isNotNull);
      expect(Validators.email('a@b.com'), isNull);
    });

    test('password needs 6+ characters', () {
      expect(Validators.password('12345'), isNotNull);
      expect(Validators.password('123456'), isNull);
    });

    test('matches', () {
      final check = Validators.matches(() => 'secret');
      expect(check('secret'), isNull);
      expect(check('other'), isNotNull);
    });
  });

  test('titleCase formats category slugs', () {
    expect(titleCase('mens-shirts'), 'Mens Shirts');
  });
}
