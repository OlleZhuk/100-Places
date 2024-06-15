/// Модель Места, ММ
library;

import 'dart:io';

//^ Модель Места
//
class Place {
  Place({
    required this.title,
    required this.date,
    required this.image,
    required this.location,
  });

  final String date, title;
  final File image;
  final PlaceLocation location;
}

//^ Модель локации Места
//
class PlaceLocation {
  const PlaceLocation({
    required this.latitude,
    required this.longitude,
    required this.address,
  });

  final double latitude, longitude;
  final String address;
}
