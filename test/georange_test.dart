import 'package:georange/georange.dart';
import 'package:test/test.dart';

void main() {
  group("Georange Tests", () {
    test('Encodes Geohash', () {
      GeoRange georange = GeoRange();
      var encoded = georange.encode(-1.2862368, 36.8195783);
      expect(encoded, equals("kzf0tvg5n"));
    });

    test('Decodes Geohash', () {
      GeoRange georange = GeoRange();
      Point decoded = georange.decode("kzf0tvg5n");
      expect(decoded.latitude, equals(-1.2862372398376465));
    });

    test('Calculates Distance', () {
      GeoRange georange = GeoRange();
      Point point1 = Point(latitude: -4.0435, longitude: 39.6682);
      Point point2 = Point(latitude: -1.2921, longitude: 36.8219);
      var distance = georange.distance(point1, point2);
      expect(distance, equals(439.716));
    });

    test('Correct Range', () {
      GeoRange georange = GeoRange();
      Range range = georange.geohashRange(-1.2921, 36.8219, distance: 10);
      expect(range.lower, equals('kzf05k6hh'));
    });
  });
}
