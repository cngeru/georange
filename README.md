# georange

[![Dart](https://github.com/cngeru/georange/actions/workflows/dart.yml/badge.svg)](https://github.com/cngeru/georange/actions/workflows/dart.yml)   [![License: MIT](https://img.shields.io/badge/License-MIT-orange.svg)](https://opensource.org/licenses/MIT) ![Pub Version](https://img.shields.io/pub/v/georange?color=blueviolet&label=Pub)



Georange is a package that helps with encoding geohashes, decoding geohashes,calculating distance between 2 points and generating latitudinal and longitudinal ranges as geohashes to help with the querying of databases (Tested on Firestore Only).

Heavily influenced by [GeoFlutterFire](https://github.com/DarshanGowda0/GeoFlutterFire)

<a href="https://www.buymeacoffee.com/cngeru" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/default-orange.png" alt="Buy Me A Coffee" height="41" width="174"></a>

## Getting Started

You should ensure that you add Georange as a dependency in your flutter project.

```yaml
dependencies:
  georange: <latest-version>
```

You should then run `flutter packages get`

## Example

There is a detailed example project in the `example` folder.

## Initialize

Import `georange` to your dart file and initialize

```dart
import 'package:georange/georange.dart';
GeoRange georange = GeoRange();
```

### Encode LatLng

This method encodes the latitude and longitude
  ```dart
  var encoded = georange.encode(-1.2862368,36.8195783);
  print(encoded);
  ```
  prints `kzf0tvg5n`

### Decode Geohash

Decode a [geohash] into a pair of latitude and longitude.
  ```dart
  Point decoded = georange.decode("kzf0tvg5n");
  print(decoded);
  ```
  prints 
  `-1.2862372398376465`
  `36.819584369659424`

### Generate Range

```dart
  Range range = georange.geohashRange(-1.2921, 36.8219, distance: 10);
  print(range.lower);
  print(range.upper);
```
  prints 
  `kzf05k6hh`
  `kzf30mptu`

### Calculate Distance between 2 Points

```dart 
  Point point1 = Point(latitude: -4.0435, longitude: 39.6682); //Mombasa
  Point point2 = Point(latitude: -1.2921, longitude: 36.8219); // Nairobi

  var distance = georange.distance(point1, point2);
  print(distance);
```
prints 
  `439.716` Distance in Kilometres

## Usage with Firestore
1. Add a document to firestore with a `geohash` field  or a different name

``` dart
  final FirebaseFirestore _db;
  ...
  String myhash = georange.encode(-1.2862368,36.8195783);
  await _db.collection("locations").add({
    "geohash":myhash,
  })
  ...
```

2. Query Firestore (Runs like a normal firestore query)
 ```dart
 final FirebaseFirestore _db;

 GeoRange georange = GeoRange();

 Range range = georange.geohashRange(currentLocation.latitude, currentLocation.longitude, distance:10);

 QuerySnapshot snapshot = await _db
  .collection("locations")
  .where("geohash", isGreaterThanOrEqualTo: range.lower)
  .where("geohash", isLessThanOrEqualTo: range.upper)
  .limit(10)
  .get();

 ```