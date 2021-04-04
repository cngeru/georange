library georange;

import 'dart:math';

class Range {
  String lower;
  String upper;
  Range({
    this.lower = "",
    this.upper = "",
  });
}

class Point {
  double latitude;
  double longitude;
  Point({
    required this.latitude,
    required this.longitude,
  });
}

class GeoRange {
  static const BASE32_CODES = '0123456789bcdefghjkmnpqrstuvwxyz';

  Map<String, int> _base32CodesDic = new Map();

  GeoRange() {
    for (var i = 0; i < BASE32_CODES.length; i++) {
      _base32CodesDic.putIfAbsent(BASE32_CODES[i], () => i);
    }
  }

  /// Will encode the latitude and longitude
  ///```dart
  ///   var encoded = georange.encode(-1.2862368,36.8195783);
  ///   print(encoded);
  /// ```
  ///   prints `"kzf0tvg5n"`
  ///
  String encode(double latitude, double longitude, {int numberOfChars = 9}) {
    var chars = [], bits = 0, bitsTotal = 0, hashValue = 0;
    double maxLat = 90, minLat = -90, maxLon = 180, minLon = -180, mid;

    while (chars.length < numberOfChars) {
      if (bitsTotal % 2 == 0) {
        mid = (maxLon + minLon) / 2;
        if (longitude > mid) {
          hashValue = (hashValue << 1) + 1;
          minLon = mid;
        } else {
          hashValue = (hashValue << 1) + 0;
          maxLon = mid;
        }
      } else {
        mid = (maxLat + minLat) / 2;
        if (latitude > mid) {
          hashValue = (hashValue << 1) + 1;
          minLat = mid;
        } else {
          hashValue = (hashValue << 1) + 0;
          maxLat = mid;
        }
      }

      bits++;
      bitsTotal++;
      if (bits == 5) {
        var code = BASE32_CODES[hashValue];
        chars.add(code);
        bits = 0;
        hashValue = 0;
      }
    }

    return chars.join('');
  }

  /// Decode a hashString into a bound box that matches it.
  /// Data returned in a List [minLat, minLon, maxLat, maxLon]
  List<double> _decodeBbox(String hashString) {
    var isLon = true;
    double maxLat = 90, minLat = -90, maxLon = 180, minLon = -180, mid;

    int? hashValue = 0;
    for (var i = 0, l = hashString.length; i < l; i++) {
      var code = hashString[i].toLowerCase();
      hashValue = _base32CodesDic[code]!;

      for (var bits = 4; bits >= 0; bits--) {
        var bit = (hashValue >> bits) & 1;
        if (isLon) {
          mid = (maxLon + minLon) / 2;
          if (bit == 1) {
            minLon = mid;
          } else {
            maxLon = mid;
          }
        } else {
          mid = (maxLat + minLat) / 2;
          if (bit == 1) {
            minLat = mid;
          } else {
            maxLat = mid;
          }
        }
        isLon = !isLon;
      }
    }
    return [minLat, minLon, maxLat, maxLon];
  }

  /// Decode a [hashString] into a pair of latitude and longitude.
  /// ```dart
  /// Point decoded = georange.decode("kzf0tvg5n");
  /// print(decoded);
  /// ```
  /// prints `-1.2862372398376465`
  /// `36.819584369659424`
  ///
  Point decode(String hashString) {
    List<double> bbox = _decodeBbox(hashString);
    double lat = (bbox[0] + bbox[2]) / 2;
    double lon = (bbox[1] + bbox[3]) / 2;
    return Point(latitude: lat, longitude: lon);
  }

  /// Returns the lowest hash and the highest hash to query with ie:
  ///
  /// Expects `latitude`,`longitude values` and a `distance in Kilometres`
  ///
  /// `Firestore Example`
  ///
  /// ```dart
  /// GeoRange georange = GeoRange();
  /// Range range = georange.geohashRange(currentLocation.latitude, currentLocation.longitude, distance:10);
  /// QuerySnapshot snapshot = await _db
  ///    .collection("locations")
  ///    .where("geohash", isGreaterThanOrEqualTo: range.lower)
  ///    .where("geohash", isLessThanOrEqualTo: range.upper)
  ///    .limit(10)
  ///    .get();
  /// ```
  Range geohashRange(double latitude, double longitude, {int distance = 10}) {
    double lat = 0.009009009; // degrees latitude per km (1/111) per mile  1/69
    double lon = 0.01136363636; // degrees longitude per km (1/88) per mile  1/55
    double lowerLat = latitude - lat * distance;
    double lowerLon = longitude - lon * distance;
    double upperLat = latitude + lat * distance;
    double upperLon = longitude + lon * distance;
    String lowerhash = encode(lowerLat, lowerLon);
    String upperhash = encode(upperLat, upperLon);

    return Range(lower: lowerhash, upper: upperhash);
  }

  /// Returns distance in KM between 2 points
  ///```dart
  ///  Point point1 = Point(latitude:-4.0435, longitude:39.6682);
  ///  Point point2 = Point(latitude:-1.2921, longitude:36.8219);
  ///  var distance = georange.distance(point1,point2);
  ///  print(distance);
  /// ```
  /// will return `439.716` KM
  double distance(Point location1, Point location2) {
    return _calcDistance(location1.latitude, location1.longitude, location2.latitude, location2.longitude);
  }

  static double _calcDistance(double lat1, double long1, double lat2, double long2) {
    final double radius = (6378137 + 6357852.3) / 2;
    double latDelta = _toRadians(lat1 - lat2);
    double lonDelta = _toRadians(long1 - long2);
    double a = (sin(latDelta / 2) * sin(latDelta / 2)) + (cos(_toRadians(lat1)) * cos(_toRadians(lat2)) * sin(lonDelta / 2) * sin(lonDelta / 2));
    double distance = radius * 2 * atan2(sqrt(a), sqrt(1 - a)) / 1000;
    return double.parse(distance.toStringAsFixed(3));
  }

  static double _toRadians(double num) {
    return num * (pi / 180.0);
  }
}
