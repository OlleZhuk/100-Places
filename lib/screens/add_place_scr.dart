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
import '/widgets/route_transition.dart';
import 'map_scr.dart';

class AddPlaceScreen extends ConsumerWidget {
  const AddPlaceScreen({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final titleController = TextEditingController();

    final Orientation orientation = MediaQuery.orientationOf(context);
    final double toolbarH = MediaQuery.sizeOf(context).height * .1;
    final ColorScheme cScheme = Theme.of(context).colorScheme;
    final TextTheme tTheme = Theme.of(context).textTheme;

    final String enteredTitle = ref.watch(titleProvider);
    final File? imageFile = ref.watch(imageFileProvider);

    const double iconSize = 35;
    const double gapV = 20;

    //* Метод сохранения Места (кн. 'Сохранить')
    Future<void> savePlace() async {
      final PlaceLocation pickedLocation = ref.watch(pickedLocationProvider);
      final String pickedAddress = pickedLocation.address;

      if (enteredTitle.isEmpty || imageFile == null || pickedAddress.isEmpty) {
        await showDialog(
            context: context,
            builder: (context) => WarningAlert(
                warningText: enteredTitle.isEmpty
                    ? 'Пожалуйста, добавьте название!'
                    : imageFile == null
                        ? 'Пожалуйста, добавьте изображение!'
                        : pickedAddress.isEmpty
                            ? 'Пожалуйста, выберите местоположение!'
                            : '',
                actionOK: () => Navigator.of(context).pop()));
        return;
      }

      await ref.read(userPlacesProvider.notifier).addPlace(
            enteredTitle,
            imageFile,
            pickedLocation,
          );

      ///
      ref.read(titleProvider.notifier).state = '';
      ref.read(imageFileProvider.notifier).state = null;
      ref.read(isCreatingLocationProvider.notifier).state = false;

      ref.read(selectedSourseProvider.notifier).state = '';
      ref.read(manualAddressProvider.notifier).state = '';
      ref.invalidate(pickedLocationProvider);
      ref.invalidate(pickedLocationStreamAddressProvider);
      ref.invalidate(locationProvider);
      ref.invalidate(addressProvider);

      if (context.mounted) Navigator.of(context).pop();
    }

    //* Метод добавления названия
    Future<void> enterTitle() async {
      await showDialog(
        context: context,
        builder: (context) => SingleChildScrollView(
          child: AlertDialog(
            backgroundColor: cScheme.background.withOpacity(.4),
            actionsAlignment: MainAxisAlignment.center,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            content: Padding(
                padding: const EdgeInsets.only(top: 5),
                //
                child: TextField(
                    controller: titleController,
                    autofocus: true,
                    maxLength: 35,
                    keyboardType: TextInputType.text,
                    textCapitalization: TextCapitalization.sentences,
                    onSubmitted: (value) {
                      if (value.isEmpty) return;
                      ref.read(titleProvider.notifier).state = value;
                      Navigator.of(context).pop();
                    },
                    style: tTheme.headlineSmall!.copyWith(
                      color: cScheme.primary,
                    ),
                    decoration: InputDecoration(
                        labelText: 'Название Места:',
                        labelStyle: TextStyle(color: cScheme.tertiary),
                        hintStyle: TextStyle(
                          color: cScheme.onSecondaryContainer.withOpacity(.3),
                        ),
                        suffixIcon: IconButton(
                          onPressed: () => titleController.clear(),
                          icon: const Icon(Icons.clear),
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
                        ))))),
            actions: [
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: cScheme.onPrimary),
                onPressed: () {
                  final enteredTitle = titleController.text;
                  if (enteredTitle.isEmpty) return;
                  ref.read(titleProvider.notifier).state = enteredTitle;
                  Navigator.of(context).pop();
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48.0),
                  child: Text(
                    "ДА",
                    style: TextStyle(color: cScheme.primary),
                  ),
                ),
              )
            ],
          ).animate(delay: 500.ms).fadeIn(duration: 800.ms).scale(
                curve: Curves.easeOutBack,
              ),
        ),
      );
    }

    //* Метод обнуления поставщиков кнопкой/жестом "Назад"
    Future<bool> backGesture() async {
      ref.read(titleProvider.notifier).state = '';
      ref.read(imageFileProvider.notifier).state = null;
      ref.read(isCreatingLocationProvider.notifier).state = false;
      ref.read(selectedSourseProvider.notifier).state = '';
      ref.read(manualAddressProvider.notifier).state = '';
      ref.invalidate(pickedLocationProvider);
      ref.invalidate(pickedLocationStreamAddressProvider);
      ref.invalidate(locationProvider);
      ref.invalidate(addressProvider);
      return true;
    }

    // print('===> МСБ ЭДМ!!! ===');

    /// Экран Добавления Места
    return WillPopScope(
      /*
      Возвраты к предыдущему экрану, требующие 
      инициализации провайдеров:
        - кнопка СОХРАНИТЬ (метод _savePlace_)
        - кнопка _BackButton_ панели приложений
        - жест экрана (кн. НАЗАД) устройства
      */
      onWillPop: backGesture,
      child: Scaffold(
        appBar: AppBar(
            toolbarHeight: toolbarH,
            title: Text(
              'Новое Место:',
              style: TextStyle(
                fontSize: orientation == Orientation.portrait ? toolbarH * .4 : toolbarH * .7,
              ),
            ),
            leading: BackButton(
              onPressed: () {
                ref.read(titleProvider.notifier).state = '';
                ref.read(imageFileProvider.notifier).state = null;
                ref.read(isCreatingLocationProvider.notifier).state = false;
                ref.read(selectedSourseProvider.notifier).state = '';
                ref.read(manualAddressProvider.notifier).state = '';
                ref.invalidate(pickedLocationProvider);
                ref.invalidate(pickedLocationStreamAddressProvider);
                ref.invalidate(locationProvider);
                ref.invalidate(addressProvider);

                Navigator.of(context).pop();
              },
            )),
        body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: SingleChildScrollView(
                child: Column(
              children: [
                //` Фоновая картинка
                Image.asset('assets/images/landscape.webp'),
                //
                //` Название Места
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      border: Border.all(
                        color: cScheme.primary.withOpacity(.2),
                        width: 1.6,
                      )),
                  child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                      child: InkWell(
                          onTap: enterTitle,
                          child: enteredTitle.isEmpty
                              ? Text(
                                  'Добавьте название.',
                                  style: tTheme.bodySmall,
                                )
                              : Text(
                                  enteredTitle,
                                  style: tTheme.titleMedium,
                                ))),
                ),
                const Gap(gapV),
                //
                //` Изображение Места
                const ImageInput(iconSz: iconSize),
                const Gap(gapV),
                //
                //` Местоположение
                const LocationInput(iconSz: iconSize),
                const Gap(gapV * 10),
              ],
            ))),

        //^ КНОПКА "СОХРАНИТЬ"
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: CustomFAB(
          labelText: 'Сохранить',
          buttonIcon: Icons.save_alt,
          action: savePlace,
        ),
      ),
    );
  }
}

//| ВИДЖЕТЫ:                             >

//| _ImageInput_ -------------------------
class ImageInput extends ConsumerWidget {
  const ImageInput({
    super.key,
    required this.iconSz,
  });

  final double iconSz;

  @override
  Widget build(BuildContext context, ref) {
    File? selectedImage;
    bool isCamera = true;

    final ColorScheme cScheme = Theme.of(context).colorScheme;
    final TextTheme tTheme = Theme.of(context).textTheme;
    final double deviceWidth = MediaQuery.sizeOf(context).width;
    final File? receivedImage = ref.watch(imageFileProvider);
    const double gap = 14;

    //* Метод получения изображения
    Future<void> takePicture() async {
      final imagePicker = ImagePicker();
      final pickedImage = await imagePicker.pickImage(
        source: isCamera ? ImageSource.camera : ImageSource.gallery,
      );
      if (pickedImage == null) return;
      selectedImage = File(pickedImage.path);
      ref.read(imageFileProvider.notifier).state = selectedImage;
    }

    // print('=== МСБ ImageInput!!! ===');

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        //
        //< Бокс для изображения >
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
            //
            //` Картинка здесь:                   >
            image: receivedImage != null
                ? DecorationImage(
                    image: FileImage(receivedImage),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          //`
          child: receivedImage == null
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    'Справа нажмите "Сделать снимок" или "Взять из галереи", чтобы добавить изображение.',
                    textAlign: TextAlign.center,
                    style: tTheme.bodySmall,
                  ))
              : null,
        ),
        const Gap(gap * 2.1),

        //< Выбор источника >
        Column(
          children: [
            //| Снимок
            InkWell(
              onTap: () {
                isCamera = true;
                takePicture();
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.camera, size: iconSz),
                  const Gap(gap),
                  const Text('Сделать\n' 'снимок'),
                ],
              ),
            ),
            const Gap(gap * 2.5),
            //| Галерея
            InkWell(
                onTap: () {
                  isCamera = false;
                  takePicture();
                },
                child: Row(
                  children: [
                    Icon(Icons.wallpaper, size: iconSz),
                    const Gap(gap),
                    const Text('Взять из\n' 'галереи'),
                  ],
                )),
          ],
        ),
      ],
    );
  }
}

//| _LocationInput_ ----------------------
class LocationInput extends ConsumerWidget {
  const LocationInput({
    super.key,
    required this.iconSz,
  });

  final double iconSz;

  @override
  Widget build(BuildContext context, ref) {
    PlaceLocation? pickedLocation;
    String? selectedSourse;
    final TextTheme tTheme = Theme.of(context).textTheme;
    final ColorScheme cScheme = Theme.of(context).colorScheme;
    final bool isCreatingLocation = ref.watch(isCreatingLocationProvider);
    final String pickedLocationAddress = ref.watch(pickedLocationProvider).address;
    final AsyncValue<String> pickedLocationStreamAddress = ref.watch(pickedLocationStreamAddressProvider);

    final double lat = ref.watch(pickedLocationProvider).latitude;
    final double lng = ref.watch(pickedLocationProvider).longitude;

    const double gap = 34;

    //* Метод компоновки и сохранения полученной локации
    Future<void> getLocation() async {
      //
      /// 1. Полуаем КООРДИНАТЫ
      //
      final lat = ref.watch(locationProvider).latitude;
      final lng = ref.watch(locationProvider).longitude;

      /// 2. Получаем АДРЕС
      // геокодер или ручной ввод
      //
      final String selectedSourse = ref.watch(selectedSourseProvider);
      String? sourceAddress;
      final String address = ref.watch(addressProvider);
      final String manAddress = ref.watch(manualAddressProvider);

      switch (selectedSourse) {
        case 'geo':
          sourceAddress = address;
          break;
        case 'man':
          sourceAddress = manAddress;
          break;
        default:
          sourceAddress = address;
          break;
      }
      // print('===> getLocation ВЫДАЕТ: $sourceAddress');

      /// 3. Представление полученных данных в модели локации
      pickedLocation = PlaceLocation(
        latitude: lat,
        longitude: lng,
        address: sourceAddress,
      );

      /// 4. Запись модели локации в поставщик локации
      if (pickedLocation != null) {
        ref.read(pickedLocationProvider.notifier).state = pickedLocation!;
        ref.read(selectedSourseProvider.notifier).state = 'geo'; //!
      }

      // print('=== ФЛАГ СОЗДАНИЯ ЛОКАЦИИ: ${ref.watch(isCreatingLocationProvider).toString()}');
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
      // Включить флаг создания локации
      ref.read(isCreatingLocationProvider.notifier).state = true;
      // Отдать в геокодер для получения адреса
      await ref.read(addressProvider.notifier).getAddress(lat, lng);
      // Отдать поставщику координат для вызова при компоновке
      final point = Point(latitude: lat, longitude: lng);
      ref.read(locationProvider.notifier).state = point;
      // Отдать на компоновку и показ полученной локации
      getLocation();
    }

    //* Метод выбора локации на карте
    Future<void> getOnMapLocation() async {
      // Включить флаг создания локации
      ref.read(isCreatingLocationProvider.notifier).state = true;
      // Перейти на экран карты для выбора локации
      await Navigator.of(context).push(MyRouteTransition(
        const MapScreen(),
      ));
      // После сохранения локации на ЭК вызвать компоновку и показ
      getLocation();
    }

    //* Метод ручного ввода
    Future<void> manuallyAddressInput(BuildContext context) async {
      ref.read(selectedSourseProvider.notifier).state = 'man';
      final inputController = TextEditingController();

      await showModalBottomSheet(
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        context: context,
        builder: (BuildContext context) {
          return ClipPath(
              clipper: CustomClipPath(),
              child: Container(
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [cScheme.onPrimary, cScheme.background],
                  )),
                  child: Padding(
                      padding: EdgeInsets.only(
                        top: 35,
                        left: 15,
                        right: 15,
                        bottom: MediaQuery.viewInsetsOf(context).bottom * 1.1,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: inputController,
                            keyboardType: TextInputType.multiline,
                            textCapitalization: TextCapitalization.sentences,
                            maxLength: 170,
                            maxLines: null,
                            style: tTheme.headlineSmall!.copyWith(
                              color: cScheme.primary,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Введите адрес Места:',
                              labelStyle: tTheme.bodySmall,
                              counterStyle: TextStyle(color: cScheme.primary),
                            ),
                          ),
                          const Gap(20),
                          CustomFAB(
                              labelText: 'Подтвердить',
                              buttonIcon: Icons.save_alt,
                              action: () async {
                                final manAddress = inputController.text;
                                if (manAddress.isEmpty) return;

                                ref.read(manualAddressProvider.notifier).state = manAddress;
                                getLocation();

                                Navigator.of(context).pop();

                                // print('===> manuallyAddressInput ВЫДАЕТ: $manAddress');
                              }),
                        ],
                      ))));
        },
      );
    }

    // print('===> ФЛАГ_isCreatingLocation: $isCreatingLocation');
    // print('===> МСБ_LocationInput');
    // print('=== Location $lat и $lng ===');

    return Column(
      children: [
        //
        //< Бокс с адресом местоположения >
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              border: Border.all(
                color: cScheme.primary.withOpacity(.2),
                width: 1.6,
              )),
          child: !isCreatingLocation
              ? Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 10,
                  ),
                  child: Text(
                    'Добавьте своё текущее местоположение\n'
                    'или выберите на карте.',
                    style: tTheme.bodySmall,
                  ))
              : pickedLocationStreamAddress.when(
                  data: (pickedLocationAddress) => Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                      child: Text(
                        pickedLocationAddress,
                        textAlign: TextAlign.start,
                        softWrap: true,
                        style: tTheme.titleMedium,
                      )),
                  loading: () => const Center(
                      child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: CircularProgressIndicator(),
                  )),
                  error: (e, st) => Text(pickedLocationAddress),
                ),
        ),
        const Gap(gap / 2),

        //< Кнопки выбора местоположения >
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //
            //| Текущее
            InkWell(
                onTap: () {
                  if (selectedSourse == 'man') {
                    ref.read(selectedSourseProvider.notifier).state = 'geo'; //!
                  }
                  getUserLocation();
                },
                child: Column(
                  children: [
                    Icon(Icons.location_on, size: iconSz),
                    const Text('Текущее'),
                  ],
                )),
            const Gap(gap),

            //| На карте
            InkWell(
                onTap: () {
                  // ref.invalidate(pickedLocationStreamAddressProvider);
                  if (selectedSourse == 'man') {
                    ref.read(selectedSourseProvider.notifier).state = 'geo'; //!
                  }
                  getOnMapLocation();
                },
                child: Column(
                  children: [
                    Icon(Icons.map, size: iconSz),
                    const Text('На карте'),
                  ],
                )),

            //| Вручную
            Visibility(
              visible: isCreatingLocation && lat != 0 && lng != 0,
              child: const Gap(gap),
            ),
            Visibility(
              visible: isCreatingLocation && lat != 0 && lng != 0,
              child: InkWell(
                      onTap: () {
                        manuallyAddressInput(context);
                      },
                      child: Column(
                        children: [
                          Icon(Icons.edit_note, size: iconSz),
                          const Text('Вручную'),
                        ],
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

//| _CustomClipPath_ ---------------------
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
