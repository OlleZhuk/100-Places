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

class MapScreen extends ConsumerWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context, ref) {
    // Point? pickedLocation;
    final toolbarH = MediaQuery.sizeOf(context).height * .1;

    print('=== МСБ ЭК!!! ===');

    return Scaffold(
      appBar: AppBar(
          title: const Text(
            'Выбрать Место',
            style: TextStyle(fontSize: 30),
          ),
          toolbarHeight: toolbarH,
          leading: BackButton(
            onPressed: () {
              ref.invalidate(addressProvider);
              ref.invalidate(startPointProvider);
              ref.invalidate(onMapAddressStreamProvider);
              // ???
              ref.invalidate(locationProvider);
              // ???
              ref.read(onGetAddressProvider.notifier).state = false;
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
            Point? pickedLocation = ref.watch(locationProvider);
            ref.read(onGetAddressProvider.notifier).state = true;
            await ref.read(addressProvider.notifier).getAddress(
                  pickedLocation!.latitude,
                  pickedLocation.longitude,
                );
          }),

      /// Отображение адреса
      bottomNavigationBar: const OnMapAddressView(),
    );
  }
}

/// ВИДЖЕТЫ
///
/// Виджет отображения адреса
class OnMapAddressView extends ConsumerWidget {
  const OnMapAddressView({super.key});

  @override
  Widget build(BuildContext context, ref) {
    // Point? pickedLocation;
    final cScheme = Theme.of(context).colorScheme;
    final String address = ref.watch(addressProvider);
    final AsyncValue<String> addressStream = ref.watch(onMapAddressStreamProvider);
    final String startPointAddress = ref.watch(startPointProvider).address;
    final bool isGettingAddress = ref.watch(onGetAddressProvider);
    final String currentDate = ref.watch(dateProvider);

    print('=== МСБ OnMapAddressView!!! ===');

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

                /// Стрим получения адреса после подтверждения
                child: addressStream.when(
                  data: (address) => Text(
                    isGettingAddress ? address : startPointAddress,
                    // softWrap: true,
                    style: TextStyle(
                      color: cScheme.tertiary,
                      fontSize: 14,
                    ),
                  ),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, st) => Text(address),
                ),
              ),
            ),

            /// Мигающая кнопка сохранения
            Visibility(
                visible: isGettingAddress ? true : false,
                child: IconButton(
                    icon: Icon(
                      Icons.save_alt_rounded,
                      color: cScheme.tertiary,
                      size: 28,
                    )
                        .animate(
                          delay: 2.seconds,
                          onPlay: (controller) => controller.repeat(),
                        )
                        .fadeIn(
                          delay: 700.ms,
                          duration: 1.seconds,
                        )
                        .fadeOut(
                          delay: 1700.ms,
                          duration: 1.seconds,
                        ),
                    onPressed: () async {
                      Point pickedLocation = ref.watch(locationProvider);
                      bool isCreatingLocation = ref.watch(isCreatingLocationProvider);

                      if (isCreatingLocation) {
                        Navigator.of(context).pop(pickedLocation);
                      } else {
                        /// Отправляем новую локацию в БД
                        Navigator.of(context).pop();
                        if (address.isNotEmpty && currentDate.isNotEmpty) {
                          await ref.read(userPlacesProvider.notifier).updateLocation(
                                pickedLocation.latitude.toString(),
                                pickedLocation.longitude.toString(),
                                address,
                                currentDate,
                              );
                        }
                      }
                      ref.invalidate(startPointProvider);
                      ref.read(onGetAddressProvider.notifier).state = false;
                      // ref.invalidate(addressProvider);
                    }))
          ],
        ));
  }
}

/// Виджет Яндекс Карты
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
        image: BitmapDescriptor.fromAssetImage('assets/images/location_icon.webp'),
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
          //
          print('${pickedLoc!.latitude}, ${pickedLoc!.longitude}');
        },
      );
}
