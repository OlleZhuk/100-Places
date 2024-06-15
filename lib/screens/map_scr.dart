/// ЭКРАН КАРТЫ
library;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

import '/providers/any_states.dart';
import '/providers/any_locations.dart';
import '/providers/geocoder.dart';
import '/providers/user_places.dart';
import '/widgets/custom_fab.dart';

class MapScreen extends ConsumerWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final toolbarH = MediaQuery.sizeOf(context).height * .1;
    final Orientation orientation = MediaQuery.orientationOf(context);

    //* Метод обнуления поставщиков физической кнопкой/жестом "Назад"
    Future<bool> backGesture() async {
      //` Возврат на ЭДМ без сохранения введённых/полученных данных
      ref.invalidate(addressProvider);
      ref.invalidate(locationProvider);
      ref.read(onGetAddressProvider.notifier).state = false;

      return true;
    }

    // print('=== МСБ ЭК!!! ===');

    return WillPopScope(
      /*
      Возвраты к предыдущему экрану, требующие инициализации 
      провайдеров:
        - мигающая кнопка с иконкой сохранения
        - кнопка _BackButton_ панели приложений
        - жест экрана (кн. НАЗАД) устройства

      При этом возвраты без сохранения (2 и 3) предполагают 
      инициализацию всех задействованных провайдеров (ref.read...), 
      тогда как сохранение с возвратом (1) не сбрасывает 
      провайдеры, данные которых используются на предыдущем
      экране.
      */
      onWillPop: backGesture,
      child: Scaffold(
        appBar: AppBar(
            title: Text(
              'Выбрать Место',
              style: TextStyle(
                fontSize: orientation == Orientation.portrait ? toolbarH * .4 : toolbarH * .7,
              ),
            ),
            toolbarHeight: toolbarH,
            leading: BackButton(
              onPressed: () {
                //` Возврат на ЭДМ без сохранения введённых/полученных данных
                ref.invalidate(addressProvider);
                ref.invalidate(locationProvider);
                ref.read(onGetAddressProvider.notifier).state = false;

                Navigator.of(context).pop();
              },
            )),
        //
        body: const SafeArea(child: YanMapLocation()),

        //^ Кнопка ПОЛУЧИТЬ АДРЕС
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

        //^ Отображение адреса
        bottomNavigationBar: const OnMapAddressView(),
      ),
    );
  }
}

//| ВИДЖЕТЫ:                                   >
//
//| Виджет отображения адреса
class OnMapAddressView extends ConsumerWidget {
  const OnMapAddressView({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final ColorScheme cScheme = Theme.of(context).colorScheme;
    final String address = ref.watch(addressProvider);
    final AsyncValue<String> streamAddress = ref.watch(streamAddressProvider);
    final String startPointAddress = ref.watch(startPointProvider).address;
    final bool isGettingAddress = ref.watch(onGetAddressProvider);
    final String currentDate = ref.watch(dateProvider);

    // print('=== МСБ OnMapAddressView!!! ===');

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

                    //` Стрим получения адреса после подтверждения
                    child: streamAddress.when(
                      data: (address) => Text(
                        isGettingAddress ? address : startPointAddress,
                        style: TextStyle(
                          color: cScheme.tertiary,
                          fontSize: 14,
                        ),
                      ),
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (e, st) => Text(address),
                    ))),

            //` Мигающая кнопка сохранения
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
                        //` Обновляем данные о локации в БД
                        if (address.isNotEmpty && currentDate.isNotEmpty) {
                          await ref.read(userPlacesProvider.notifier).updateLocation(
                                pickedLocation.latitude.toString(),
                                pickedLocation.longitude.toString(),
                                address,
                                currentDate,
                              );
                        }

                        if (context.mounted) Navigator.of(context).pop();
                      }
                      //` Инициализация провайдеров
                      ref.read(onGetAddressProvider.notifier).state = false;
                      /*
                      При сохранении не обнуляются _addressProvider_  
                      и _locationProvider_, т.к. дальше их данные нужны на ЭДМ
                      */
                    }))
          ],
        ));
  }
}

//| Виджет Яндекс.Карт
class YanMapLocation extends ConsumerStatefulWidget {
  const YanMapLocation({super.key});

  @override
  ConsumerState<YanMapLocation> createState() => ConsumerYanMapLocationState();
}

class ConsumerYanMapLocationState extends ConsumerState<YanMapLocation> {
  Point? pickedL;
  Point? pickedLoc;

  bool get isCreatingLocation => ref.watch(isCreatingLocationProvider);
  double get startLat => ref.watch(startPointProvider).latitude;
  double get startLng => ref.watch(startPointProvider).longitude;

  late YandexMapController controller;
  final MapObjectId cameraMapObjectId = const MapObjectId('camera_placemark');
  late final List<MapObject> mapObjects = [
    PlacemarkMapObject(
      mapId: cameraMapObjectId,

      //* Стартовая точка
      /* НЕ редактируем -- Москва,
         редактируем -- текущий адрес Места 
      */
      point: Point(
        latitude: isCreatingLocation ? 55.755848 : startLat,
        longitude: isCreatingLocation ? 37.620409 : startLng,
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
            zoom: isCreatingLocation ? 6 : 16,
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
          // print('${pickedLoc!.latitude}, ${pickedLoc!.longitude}');
        },
      );
}
