import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

import '/models/place.dart';

//* Поставщик стартовых координат в режиме редактирования
//* местоположения (вместо Москвы).
final startPointProvider = StateProvider<PlaceLocation>((ref) {
  const startPoint = PlaceLocation(
    address: '',
    latitude: 0,
    longitude: 0,
  );
  return startPoint;
});

//* Поставщик полученной локации.
final pickedLocationProvider = StateProvider<PlaceLocation>((ref) {
  const pickedLocation = PlaceLocation(
    address: '',
    latitude: 0,
    longitude: 0,
  );
  return pickedLocation;
});

//* Поставщик координат
final locationProvider = StateProvider<Point>(
  (ref) => const Point(latitude: 0, longitude: 0),
);
