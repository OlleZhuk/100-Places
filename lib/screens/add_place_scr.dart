/// Экран Добавления Мест, ЭДМ
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';

import '../widgets/alert_dialogs.dart';
import '/providers/any_states.dart';
import '/models/place.dart';
import '/providers/geocoder.dart';
import '../providers/user_places.dart';
import '/widgets/route_transition.dart';
import '/widgets/custom_fab.dart';
import '/widgets/gradient_appbar.dart';
import 'map_scr.dart';

class AddPlaceScreen extends ConsumerWidget {
  const AddPlaceScreen({super.key});

  @override
  Widget build(BuildContext context, ref) {
    print('=== МСБ ЭДМ!!! ===');

    final cScheme = Theme.of(context).colorScheme;
    final tTheme = Theme.of(context).textTheme;
    final titleController = TextEditingController();

    PlaceLocation? selectedLocation;
    File? selectedImage;

    //* Метод сохранения Места (кн. 'Сохранить')
    Future<void> savePlace() async {
      final String enteredTitle = titleController.text;

      if (enteredTitle.isEmpty || selectedImage == null || selectedLocation == null) {
        showDialog(
            context: context,
            builder: (context) => WarningAlert(
                warningText: enteredTitle.isEmpty
                    ? 'Пожалуйста, добавьте название!'
                    : selectedImage == null
                        ? 'Пожалуйста, добавьте изображение!'
                        : selectedLocation == null
                            ? 'Пожалуйста, выберите местоположение!'
                            : '',
                actionOK: () {
                  Navigator.of(context).pop();
                }));
        return;
      }
      if (enteredTitle.isNotEmpty && selectedImage != null && selectedLocation != null) {
        Navigator.of(context).pop();
        await ref.read(userPlacesProvider.notifier).addPlace(
              enteredTitle,
              selectedImage!,
              selectedLocation!,
            );
        ref.invalidate(addressProvider);
        ref.read(isCreatingLocationProvider.notifier).state = false;
      }

// print('=== АДРЕС НА ЭДМ: ${selectedLocation!.address}');
    }

    return Scaffold(
      appBar: AppBar(
          flexibleSpace: const GradientAppBar(),
          title: Text(
            'Новое Место:',
            style: tTheme.titleLarge!.copyWith(color: cScheme.primary),
          ),
          leading: BackButton(
            onPressed: () {
              ref.read(isCreatingLocationProvider.notifier).state = false;
              ref.invalidate(addressProvider);
              Navigator.of(context).pop();
            },
          )),
      body: SafeArea(
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: SingleChildScrollView(
                child: Column(
              children: [
                /// Заставка
                Image.asset('assets/landscape.webp'),

                /// НАЗВАНИЕ
                Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: TextField(
                        controller: titleController,
                        maxLength: 30,
                        style: tTheme.headlineSmall!.copyWith(
                          color: cScheme.primary,
                        ),
                        decoration: InputDecoration(
                            labelText: 'Название:',
                            labelStyle: tTheme.titleSmall,
                            counterStyle: TextStyle(color: cScheme.primary),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(10),
                                ),
                                borderSide: BorderSide(
                                  width: 1.5,
                                  color: cScheme.primary.withOpacity(0.2),
                                )),
                            border: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                              Radius.circular(10),
                            ))))),

                /// ИЗОБРАЖЕНИЕ
                ImageInput(onPickImage: (File image) {
                  selectedImage = image;
                }),
                const Gap(18),

                /// МЕСТОПОЛОЖЕНИЕ
                LocationInput(onSelectLocation: (PlaceLocation userLocation) {
                  selectedLocation = userLocation;
                }),
              ],
            ))),
      ),

      /// КНОПКА "СОХРАНИТЬ"
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: CustomFAB(
        labelText: 'Сохранить',
        buttonIcon: Icons.save_alt,
        action: savePlace,
      ),
    );
  }
}

/// ВИДЖЕТЫ:

/// _ImageInput_ ------------------------
class ImageInput extends StatefulWidget {
  const ImageInput({
    super.key,
    required this.onPickImage,
  });

  final void Function(File image) onPickImage;

  @override
  State<ImageInput> createState() => _ImageInputState();
}

class _ImageInputState extends State<ImageInput> {
  File? _selectedImage;
  bool isCamera = true;

  ColorScheme get cScheme => Theme.of(context).colorScheme;
  TextTheme get tTheme => Theme.of(context).textTheme;
  double get deviceWidth => MediaQuery.of(context).size.width;

  Future<void> _takePicture() async {
    final imagePicker = ImagePicker();
    final pickedImage = await imagePicker.pickImage(
      source: isCamera ? ImageSource.camera : ImageSource.gallery,
    );
    if (pickedImage == null) {
      return;
    }
    setState(() => _selectedImage = File(pickedImage.path));

    widget.onPickImage(_selectedImage!);
  }

  @override
  Widget build(BuildContext context) {
    print('=== МСБ ImageInput!!! ===');

    return Row(
      children: [
        Container(
          width: deviceWidth * .5,
          height: deviceWidth * .5,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(
              color: cScheme.primary.withOpacity(0.2),
              width: 1.5,
            ),
            borderRadius: const BorderRadius.all(
              Radius.circular(10),
            ),
            image: _selectedImage != null
                ? DecorationImage(
                    image: FileImage(_selectedImage!),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: _selectedImage == null
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    'Изображение:',
                    textAlign: TextAlign.center,
                    style: tTheme.titleSmall,
                  ))
              : null,
        ),
        const Gap(20),
        Column(
          children: [
            TextButton.icon(
                label: const Text('Снимок'),
                onPressed: () {
                  isCamera = true;
                  _takePicture();
                },
                icon: const Icon(Icons.camera, size: 30)),
            const Gap(18),
            TextButton.icon(
                label: const Text('Галерея'),
                onPressed: () {
                  isCamera = false;
                  _takePicture();
                },
                icon: const Icon(
                  Icons.wallpaper,
                  size: 30,
                )),
          ],
        )
      ],
    );
  }
}

/// _LocationInput_ --------------------------------
class LocationInput extends ConsumerStatefulWidget {
  const LocationInput({super.key, required this.onSelectLocation});

  final void Function(PlaceLocation location) onSelectLocation;

  @override
  ConsumerLocationInputState createState() => ConsumerLocationInputState();
}

class ConsumerLocationInputState extends ConsumerState<LocationInput> {
  PlaceLocation? _pickedLocation;
  bool get isCreatingLocation => ref.watch(isCreatingLocationProvider);
  TextTheme get tTheme => Theme.of(context).textTheme;
  ColorScheme get cScheme => Theme.of(context).colorScheme;

  //* Метод компоновки и сохранения полученной локации
  Future<void> _getLocation(double latitude, double longitude) async {
    /// 1. Получение адреса из Геокодера
    final locationAddress = ref.watch(addressProvider);

    /// 2. Сохранение координат и адреса в модели локации
    setState(() {
      _pickedLocation = PlaceLocation(
        latitude: latitude,
        longitude: longitude,
        address: locationAddress,
      );
    });
    if (_pickedLocation == null) ref.read(isCreatingLocationProvider.notifier).state = false;

    /// 3. Передача модели локации на сохранение
    widget.onSelectLocation(_pickedLocation!);
  }

  //* Метод получения местоположения пользователя
  Future<void> getUserLocation() async {
    final location = Location();
    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData? currentLocation;

    /// 1. Получение разрешений
    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }
    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    /// 2. Получение координат текущей локации
    currentLocation = await location.getLocation();
    final lat = currentLocation.latitude;
    final lng = currentLocation.longitude;

    /// 3. Отправка полученных координат
    if (lat == null || lng == null) {
      return;
    }
    await ref.read(addressProvider.notifier).getAddress(lat, lng);
    _getLocation(lat, lng);
    ref.read(isCreatingLocationProvider.notifier).state = true;
  }

  //* Метод выбора локации на карте
  Future<void> getOnMapLocation() async {
    ref.read(isCreatingLocationProvider.notifier).state = true;
    final onMapLocation = await Navigator.of(context).push(MyRouteTransition(
      const MapScreen(),
    ));
    if (onMapLocation != null) {
      _getLocation(
        onMapLocation.latitude,
        onMapLocation.longitude,
      );
    }
    if (_pickedLocation == null) ref.read(isCreatingLocationProvider.notifier).state = false;
    // setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    print('=== МСБ LocationInput!!! ===');

    return Column(
      children: [
        //
        //^ Адрес
        Card(
            color: cScheme.background,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(
                  width: 1.6,
                  color: cScheme.primary.withOpacity(.2),
                )),
            child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      color: cScheme.tertiary,
                      size: 30,
                    ),
                    const Gap(12),
                    !isCreatingLocation
                        ? Text(
                            'Местоположение:',
                            style: tTheme.titleSmall,
                          )
                        : _pickedLocation == null
                            ? const CircularProgressIndicator()
                            : Expanded(
                                child: Text(
                                _pickedLocation!.address,
                                style: tTheme.titleSmall,
                              ))
                  ],
                ))),
        const Gap(8),

        //^ Кнопки выбора местоположения
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton.icon(
              label: const Text('Текущее'),
              icon: const Icon(
                Icons.location_on,
                size: 30,
              ),
              onPressed: getUserLocation,
            ),
            TextButton.icon(
              label: const Text('На карте'),
              icon: const Icon(
                Icons.map,
                size: 30,
              ),
              onPressed: getOnMapLocation,
            ),
          ],
        )
      ],
    );
  }
}
