/// Экран Добавления Мест, ЭДМ
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

import '/models/place.dart';
import '/providers/any_locations.dart';
import '/providers/any_states.dart';
import '/providers/geocoder.dart';
import '/providers/user_places.dart';
import '/widgets/alert_dialogs.dart';
import '/widgets/custom_fab.dart';
import '/widgets/gradient_appbar.dart';
import '/widgets/route_transition.dart';
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

    final Color labelOpacity = cScheme.tertiary.withOpacity(.5);
    double iconSize = 35;

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
    }

    return Scaffold(
      appBar: AppBar(
          toolbarHeight: 70,
          flexibleSpace: const GradientAppBar(),
          title: const Text(
            'Новое Место:',
            style: TextStyle(fontSize: 30),
          ),
          leading: BackButton(
            onPressed: () {
              ref.read(sourseLocationProvider.notifier).state = 'geo';
              ref.read(isCreatingLocationProvider.notifier).state = false;
              ref.invalidate(addressProvider);
              Navigator.of(context).pop();
            },
          )),
      body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: SingleChildScrollView(
              child: Column(
            children: [
              /// Фоновая картинка
              Image.asset('assets/landscape.webp'),

              /// Название
              TextField(
                  controller: titleController,
                  maxLength: 30,
                  style: tTheme.headlineSmall!.copyWith(
                    color: cScheme.primary,
                  ),
                  decoration: InputDecoration(
                      labelText: 'Название:',
                      labelStyle: tTheme.titleSmall!.copyWith(
                        color: labelOpacity,
                      ),
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
                      )))),

              /// Изображение
              ImageInput(
                onPickImage: (File image) {
                  selectedImage = image;
                },
                labelOpc: labelOpacity,
                iconSz: iconSize,
              ),

              ///
              const Gap(18),

              /// Местоположение
              LocationInput(
                onSelectLocation: (PlaceLocation userLocation) {
                  selectedLocation = userLocation;
                },
                labelOpc: labelOpacity,
                iconSz: iconSize,
              ),

              ///
              const Gap(90),
            ],
          ))),

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

//* _ImageInput_ ------------------------
class ImageInput extends StatefulWidget {
  const ImageInput({
    super.key,
    required this.onPickImage,
    required this.labelOpc,
    required this.iconSz,
  });

  final void Function(File image) onPickImage;
  final Color labelOpc;
  final double iconSz;

  @override
  State<ImageInput> createState() => _ImageInputState();
}

class _ImageInputState extends State<ImageInput> {
  File? _selectedImage;
  final imagePicker = ImagePicker();
  bool isCamera = true;

  ColorScheme get cScheme => Theme.of(context).colorScheme;
  TextTheme get tTheme => Theme.of(context).textTheme;
  double get deviceWidth => MediaQuery.of(context).size.width;

  Future<void> _takePicture() async {
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
                    style: tTheme.titleSmall!.copyWith(
                      color: widget.labelOpc,
                    ),
                  ))
              : null,
        ),
        const Gap(8),
        Expanded(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: Icon(
                Icons.camera,
                size: widget.iconSz,
              ),
              iconColor: cScheme.primary,
              title: const Text('Сделать снимок'),
              titleTextStyle: tTheme.titleMedium!.copyWith(
                fontSize: 16,
              ),
              onTap: () {
                isCamera = true;
                _takePicture();
              },
            ),
            const Gap(16),
            ListTile(
              leading: Icon(
                Icons.wallpaper,
                size: widget.iconSz,
              ),
              iconColor: cScheme.primary,
              title: const Text('Взять из галереи'),
              titleTextStyle: tTheme.titleMedium!.copyWith(
                fontSize: 16,
              ),
              onTap: () {
                isCamera = false;
                _takePicture();
              },
            ),
          ],
        ))
      ],
    );
  }
}

//* _LocationInput_ --------------------------------
class LocationInput extends ConsumerStatefulWidget {
  const LocationInput({
    super.key,
    required this.onSelectLocation,
    required this.labelOpc,
    required this.iconSz,
  });

  final void Function(PlaceLocation location) onSelectLocation;
  final Color labelOpc;
  final double iconSz;

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
    /// 1. Получение адреса (геокодер или ручной ввод)
    String addressSource = ref.watch(sourseLocationProvider);
    String locationAddress;

    switch (addressSource) {
      case 'geo':
        locationAddress = ref.watch(addressProvider);
        break;
      case 'man':
        locationAddress = ref.watch(manualLocationProvider);
        break;
      default:
        locationAddress = ref.watch(addressProvider);
        break;
    }

    /// 2. Сохранение координат и адреса в модели локации
    setState(() {
      _pickedLocation = PlaceLocation(
        latitude: latitude,
        longitude: longitude,
        address: locationAddress,
      );
    });
    // print('=== addressSource: $addressSource');
    // print('=== locationAddress: $locationAddress');

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
    // Point point;

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

    final point = Point(latitude: lat, longitude: lng);
    ref.read(locationProvider.notifier).state = point;

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
  }

  //* Метод ручного ввода
  Future<void> manuallyAddressInput(BuildContext ctx) async {
    final inputController = TextEditingController();

    await showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      // shape: const RoundedRectangleBorder(
      //     borderRadius: BorderRadius.vertical(
      //   top: Radius.circular(20),
      //   bottom: Radius.zero,
      // )),
      context: ctx,
      builder: (BuildContext ctx) {
        return ClipPath(
            clipper: CustomClipPath(),
            child: Container(
                color: cScheme.onPrimary,
                child: Padding(
                    padding: EdgeInsets.only(
                      top: 30,
                      left: 15,
                      right: 15,
                      bottom: MediaQuery.of(ctx).viewInsets.bottom * 1.07,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: inputController,
                          keyboardType: TextInputType.multiline,
                          maxLength: 170,
                          maxLines: null,
                          style: tTheme.headlineSmall!.copyWith(
                            color: cScheme.primary,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Расположение Места:',
                            labelStyle: tTheme.titleSmall!.copyWith(
                              color: cScheme.surfaceTint.withOpacity(.7),
                            ),
                            counterStyle: TextStyle(color: cScheme.primary),
                          ),
                        ),
                        const Gap(20),
                        CustomFAB(
                            labelText: 'Подтвердить',
                            buttonIcon: Icons.save_alt,
                            action: () async {
                              final manuallyLocation = inputController.text;
                              if (manuallyLocation.isEmpty) {
                                return;
                              }
                              ref.read(manualLocationProvider.notifier).state = manuallyLocation;

                              double lat = ref.watch(locationProvider).latitude;
                              double lng = ref.watch(locationProvider).longitude;
                              _getLocation(lat, lng);

                              Navigator.of(context).pop();
                            }),
                      ],
                    ))));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    print('=== МСБ LocationInput! ===');

    return Column(
      children: [
        //
        /// Местоположение
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 22,
                ),
                child: Row(
                  children: [
                    !isCreatingLocation
                        ? Text(
                            'Местоположение:',
                            style: tTheme.titleSmall!.copyWith(
                              color: widget.labelOpc,
                            ),
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
        const Gap(16),

        /// Кнопки выбора местоположения
        //
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //
            /// Текущее
            InkWell(
                onTap: getUserLocation,
                child: TextAndIcon(
                  iconSz: widget.iconSz,
                  text: 'Текущее',
                  icon: Icons.location_on,
                )),
            const Gap(34),

            /// На карте
            InkWell(
                onTap: getOnMapLocation,
                child: TextAndIcon(
                  iconSz: widget.iconSz,
                  text: 'На карте',
                  icon: Icons.map,
                )),

            /// Вручную
            Visibility(
              visible: isCreatingLocation ? true : false,
              child: const Gap(34),
            ),

            Visibility(
              visible: isCreatingLocation ? true : false,
              child: InkWell(
                      onTap: () {
                        ref.read(sourseLocationProvider.notifier).state = 'man';
                        manuallyAddressInput(context);
                      },
                      child: TextAndIcon(
                        iconSz: widget.iconSz,
                        text: 'Вручную',
                        icon: Icons.edit_note,
                      ))
                  .animate()
                  .fadeIn(
                    duration: 900.ms,
                  )
                  .scale(
                    duration: 1.seconds,
                    curve: Curves.easeOutBack,
                  ),
            ),
          ],
        )
      ],
    );
  }
}

//* _CustomClipPath_ ------------------------------
class CustomClipPath extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double w = size.width;
    double h = size.height;

    final path = Path();

    path.lineTo(0, h); // LT --> LB
    path.lineTo(w, h); // LB --> RB
    path.lineTo(w, 0); // RB --> RT
    path.cubicTo(w, 0, w, 26, w - 26, 26);
    path.lineTo(26, 26);
    path.cubicTo(26, 26, 0, 26, 0, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

//* _TextAndIcon_ --------------------------------
class TextAndIcon extends StatelessWidget {
  const TextAndIcon({
    super.key,
    required this.text,
    required this.icon,
    required this.iconSz,
  });

  final String text;
  final IconData icon;
  final double iconSz;

  @override
  Widget build(BuildContext context) {
    final cScheme = Theme.of(context).colorScheme;
    const double gap = 32;

    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Padding(
            padding: const EdgeInsets.only(top: gap),
            child: Text(
              text,
              style: TextStyle(color: cScheme.primary),
            )),
        Icon(
          icon,
          color: cScheme.primary,
          size: iconSz,
        )
      ],
    );
  }
}