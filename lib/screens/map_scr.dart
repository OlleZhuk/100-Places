/// ЭКРАН КАРТЫ
library;

import 'package:favorite_places_13/providers/user_places.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

import '/providers/any_states.dart';
import '/providers/any_locations.dart';
import '/providers/geocoder.dart';
import '/widgets/custom_fab.dart';
import '/widgets/gradient_appbar.dart';

class MapScreen extends ConsumerWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context, ref) {
    print('=== МСБ ЭК!!! ===');

    Point? pickedLocation;

    return Scaffold(
      appBar: AppBar(
          title: const Text('Выбрать Место'),
          flexibleSpace: const GradientAppBar(),
          leading: BackButton(
            onPressed: () {
              ref.invalidate(addressProvider);
              ref.invalidate(startPointProvider);
              ref.read(isEditLocationProvider.notifier).state = false;
              Navigator.of(context).pop();
            },
          )),
      //
      body: const SafeArea(child: YanMapLocation()),

      //^ Кнопка
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: CustomFAB(
          labelText: 'Получить адрес',
          buttonIcon: Icons.not_listed_location,
          action: () async {
            ref.read(isConfirmedLocationProvider.notifier).state = true;
            pickedLocation = ref.watch(locationProvider);
            await ref.read(addressProvider.notifier).getAddress(
                  pickedLocation!.latitude,
                  pickedLocation!.longitude,
                );
          }),

      //^ Видимый адрес
      bottomNavigationBar: const OnMapAddressView(),
    );
  }
}

/// ВИДЖЕТЫ
///
//* Виджет отображения адреса
class OnMapAddressView extends ConsumerWidget {
  const OnMapAddressView({super.key});

  @override
  Widget build(BuildContext context, ref) {
    print('=== МСБ OnMapAddressView!!! ===');

    Point? gettingLoc;
    final cScheme = Theme.of(context).colorScheme;
    final bool isConfirmedLocation = ref.watch(isConfirmedLocationProvider); //> флаг выбора локации на карте
    final String address = ref.watch(addressProvider);
    final String startPointAddress = ref.watch(startPointProvider).address;
    final String currentDate = ref.watch(dateProvider);

    return Card(
        color: Colors.transparent,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(
              Icons.location_on_outlined,
              color: cScheme.tertiary,
              size: 30,
            ),
            Flexible(
                child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                //> если подтверждаем местоположение, то будет адрес с геокодера,
                //> если нет, то остается текущий (стартовый) адрес Места
                isConfirmedLocation ? address : startPointAddress,
                textAlign: TextAlign.start,
                softWrap: true,
                style: TextStyle(
                  color: cScheme.tertiary,
                  fontSize: 14,
                ),
              ),
            )),

            //^ Мигающая кнопка сохранения
            Visibility(
                visible: isConfirmedLocation ? true : false,
                child: IconButton(
                    icon: Icon(
                      Icons.save_alt_rounded,
                      color: cScheme.tertiary,
                      size: 28,
                    )
                        .animate(
                          delay: 1.seconds,
                          onPlay: (controller) => controller.repeat(),
                        )
                        .fadeOut(
                          delay: 700.ms,
                          duration: 1.seconds,
                        ),
                    onPressed: () async {
                      gettingLoc = ref.watch(locationProvider);
                      bool isCreatingLocation = ref.watch(isCreatingLocationProvider);
                      if (isCreatingLocation) {
                        Navigator.of(context).pop(gettingLoc);
                      } else {
                        Navigator.of(context).pop();
                        if (address.isNotEmpty && currentDate.isNotEmpty) {
                          /// Отправляем новую локацию в БД
                          await ref.read(userPlacesProvider.notifier).updateLocation(
                                gettingLoc!.latitude.toString(),
                                gettingLoc!.longitude.toString(),
                                address,
                                currentDate,
                              );
                        }
                      }
                      ref.invalidate(startPointProvider);
                      ref.read(isConfirmedLocationProvider.notifier).state = false;
                      // ref.invalidate(addressProvider);
                    }))
          ],
        ));
  }
}

//* Виджет Яндекс-карты
class YanMapLocation extends ConsumerStatefulWidget {
  const YanMapLocation({super.key});

  @override
  ConsumerState<YanMapLocation> createState() => ConsumerYanMapLocationState();
}

class ConsumerYanMapLocationState extends ConsumerState<YanMapLocation> {
  late YandexMapController controller;
  final MapObjectId cameraMapObjectId = const MapObjectId('camera_placemark');
  Point? pickedL;
  Point? pickedLoc;
  bool get isEditLocation => ref.watch(isEditLocationProvider); //> флаг редактирования местоположения
  double get startLat => ref.watch(startPointProvider).latitude;
  double get startLng => ref.watch(startPointProvider).longitude;

  late final List<MapObject> mapObjects = [
    PlacemarkMapObject(
      mapId: cameraMapObjectId,

      //* Стартовая точка
      /* НЕ редактируем -- Москва,
         редактируем -- текущий адрес Места 
      */
      point: Point(
        latitude: !isEditLocation ? 55.755848 : startLat,
        longitude: !isEditLocation ? 37.620409 : startLng,
      ),
      //* ----------------
      //
      icon: PlacemarkIcon.single(PlacemarkIconStyle(
        image: BitmapDescriptor.fromAssetImage('assets/location_icon.webp'),
        scale: 0.6,
      )),
      opacity: 0.6,
    )
  ];

  @override
  Widget build(BuildContext context) => YandexMap(
        mapObjects: mapObjects,
        //
        onMapCreated: (yandexMapController) async {
          final placemarkMapObject = mapObjects.firstWhere(
            (el) => el.mapId == cameraMapObjectId,
          ) as PlacemarkMapObject;
          controller = yandexMapController;
          await controller.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(
            target: placemarkMapObject.point,
            zoom: !isEditLocation ? 6 : 16,
          )));
        },
        //
        onCameraPositionChanged: (
          cameraPosition,
          CameraUpdateReason _,
          bool __,
        ) {
          final placemarkMapObject = mapObjects.firstWhere(
            (el) => el.mapId == cameraMapObjectId,
          ) as PlacemarkMapObject;

          setState(() {
            mapObjects[mapObjects.indexOf(placemarkMapObject)] = placemarkMapObject.copyWith(
              point: cameraPosition.target,
            );
            pickedL = cameraPosition.target;
            pickedLoc = Point(
              latitude: pickedL!.latitude,
              longitude: pickedL!.longitude,
            );
          });
          ref.read(locationProvider.notifier).state = pickedLoc!;
        },
      );
}
