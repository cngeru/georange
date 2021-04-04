import 'package:georange/georange.dart';

void main() {
  GeoRange georange = GeoRange();
  var encoded = georange.encode(-1.2862368, 36.8195783);
  print(encoded);

  Point decoded = georange.decode("kzf0tvg5n");
  print(decoded.latitude);
  print(decoded.longitude);

  Point point1 = Point(latitude: -4.0435, longitude: 39.6682);
  Point point2 = Point(latitude: -1.2921, longitude: 36.8219);

  var distance = georange.distance(point1, point2);
  print(distance);

  Range range = georange.geohashRange(-1.2921, 36.8219, distance: 10);
  print(range.lower);
  print(range.upper);
}
