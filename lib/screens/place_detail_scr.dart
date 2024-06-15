/// Экран Детальной Информации, ЭДИ
library;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:photo_view/photo_view.dart';
import 'package:share_plus/share_plus.dart';

import '/models/place.dart';
import '/providers/any_locations.dart';
import '/providers/any_states.dart';
import '/providers/geocoder.dart';
import '/providers/user_places.dart';
import '/widgets/alert_dialogs.dart';
import '/widgets/route_transition.dart';
import 'map_scr.dart';

class PlaceDetailScreen extends ConsumerWidget {
  const PlaceDetailScreen({
    super.key,
    required this.place,
  });

  final Place place;

  @override
  Widget build(context, ref) {
    final ColorScheme cScheme = Theme.of(context).colorScheme;
    final TextTheme tTheme = Theme.of(context).textTheme;
    final double toolbarH = MediaQuery.sizeOf(context).height * .1;
    final String currentDate = place.date;
    final PlaceLocation currentLocation = place.location;

    //* Метод редакции названия
    Future<void> editTitle() async {
      final titleController = TextEditingController();

      await showDialog(
          context: context,
          builder: (context) => SingleChildScrollView(
                reverse: true,
                child: AlertDialog(
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  backgroundColor: cScheme.background.withOpacity(.4),
                  content: Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: TextField(
                          controller: titleController,
                          autofocus: true,
                          maxLength: 35,
                          keyboardType: TextInputType.text,
                          textCapitalization: TextCapitalization.sentences,
                          onSubmitted: (value) async {
                            ref.read(isEditTitleProvider.notifier).state = true;
                            if (value.isEmpty) return;
                            ref.read(titleProvider.notifier).state = value;

                            await ref.read(userPlacesProvider.notifier).updateTitle(
                                  value, // title
                                  place.date, // date
                                );
                            if (context.mounted) Navigator.of(context).pop();
                          },
                          style: tTheme.headlineSmall!.copyWith(
                            color: cScheme.primary,
                          ),
                          decoration: InputDecoration(
                              labelText: 'Новое название:',
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
                  actionsPadding: const EdgeInsets.only(right: 24),
                  //
                  actions: [
                    ElevatedButton(
                      child: const Text("Подтвердить"),
                      onPressed: () async {
                        ref.read(isEditTitleProvider.notifier).state = true;
                        final enteredTitle = titleController.text;
                        if (enteredTitle.isEmpty) return;
                        ref.read(titleProvider.notifier).state = enteredTitle;

                        await ref.read(userPlacesProvider.notifier).updateTitle(
                              enteredTitle, // title
                              place.date, // date
                            );

                        // ref.read(isEditTitleProvider.notifier).state = false;
                        if (context.mounted) Navigator.of(context).pop();
                      },
                    ),
                  ],
                ).animate(delay: 500.ms).fadeIn(duration: 800.ms).scale(
                      curve: Curves.easeOutBack,
                    ),
              ));
    }

    //* Метод редакции местоположения
    Future<void> editLocation() async {
      ref.read(isEditLocationProvider.notifier).state = true;
      ref.read(startPointProvider.notifier).state = currentLocation;
      ref.read(dateProvider.notifier).state = currentDate;

      await Navigator.of(context).push(
        MyRouteTransition(const MapScreen()),
      );
    }

    //* Метод "Поделиться"
    Future<void> shareContent() async {
      final lat = place.location.latitude >= 0 ? '| СШ' : '| ЮШ';
      final lng = place.location.longitude >= 0 ? '| ВД' : '| ЗД';

      await Share.shareXFiles(
        [XFile(place.image.path)],
        text: 'НАЗВАНИЕ:\n'
            '${place.title}\n'
            '\n'
            'АДРЕС:\n'
            '${place.location.address.toString()}\n'
            '\n'
            'КООРДИНАТЫ:\n'
            '${place.location.latitude.toString()} $lat\n'
            '${place.location.longitude.toString()} $lng\n'
            '\n'
            'ДАТА:\n'
            '${place.date.replaceRange(16, null, '')}\n',
      );
    }

    //* Метод удаления Места (диалог)
    Future<void> removePlace() async {
      await showDialog(
          context: context,
          builder: (context) => ConfirmAlert(
              question: 'На самом деле удалить?',
              event: () {
                ref.read(userPlacesProvider.notifier).removePlace(
                      place.date,
                    );
                Navigator.of(context)
                  ..pop()
                  ..pop();
              }));
    }

    //* Список пунктов меню
    final List<PopupMenuEntry> getMenuItems = <PopupMenuEntry<dynamic>>[
      PopupMenuItem(
          onTap: editTitle,
          child: const Row(
            children: [
              Icon(Icons.edit_note),
              Text(' Изменить название'),
            ],
          ).animate().flipH(duration: 300.ms)),
      PopupMenuItem(
          onTap: editLocation,
          child: const Row(
            children: [
              Icon(Icons.edit_location_alt_outlined),
              Text(' Изменить местоположение'),
            ],
          ).animate().flipH(duration: 400.ms)),
      PopupMenuItem(
          onTap: shareContent,
          child: const Row(
            children: [
              Icon(Icons.share),
              Text(' Поделиться'),
            ],
          ).animate().flipH(duration: 500.ms)),
      PopupMenuItem(
          onTap: removePlace,
          child: const Row(
            children: [
              Icon(Icons.delete_forever_outlined),
              Text(' Удалить это Место'),
            ],
          ).animate().flipH(duration: 600.ms)),
    ];

    //* Виджет выпадающего меню действий
    final Widget popUpMenu = PopupMenuButton(
      offset: const Offset(-12, -6),
      icon: Icon(
        Icons.menu,
        size: 30,
        color: cScheme.primaryContainer,
      ),
      itemBuilder: (BuildContext ctx) => getMenuItems,
    );

    //* Метод обнуления поставщиков кнопкой/жестом "Назад"
    Future<bool> backGesture() async {
      ref.read(titleProvider.notifier).state = '';
      ref.read(isEditTitleProvider.notifier).state = false;
      ref.invalidate(addressProvider);

      return true;
    }

    // print('=== МСБ ЭИМ!!! ===');

    /// Экран Детальной Информации
    return WillPopScope(
      /*
      Возвраты к предыдущему экрану, требующие 
      инициализации провайдеров:
        - кнопка _BackButton_ панели приложения
        - жест экрана (кн. НАЗАД) устройства
      */
      onWillPop: backGesture,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: TitleView(currentPlace: place),
          toolbarHeight: toolbarH,
          leading: BackButton(
            onPressed: () {
              ref.read(titleProvider.notifier).state = '';
              ref.read(isEditTitleProvider.notifier).state = false;
              ref.invalidate(addressProvider);
              Navigator.of(context).pop();
            },
          ),
          actions: [popUpMenu],
        ),
        //
        body: SafeArea(
          child: PhotoView(
            backgroundDecoration: BoxDecoration(
              color: cScheme.background,
            ),
            imageProvider: Image.file(
              place.image,
              filterQuality: FilterQuality.medium,
            ).image,
          )
              .animate()
              .scale(
                duration: 800.ms,
                curve: Curves.easeOut,
              )
              .fadeIn(
                duration: 2.seconds,
              ),
        ),
        //
        bottomNavigationBar: OnDetailsAddressView(
          currentPlace: place,
        ),
      ),
    );
  }
}

/// ВИДЖЕТЫ --------------------------------
///
/// Виджет отображения названия
class TitleView extends ConsumerWidget {
  const TitleView({
    super.key,
    required this.currentPlace,
  });

  final Place currentPlace;

  @override
  Widget build(BuildContext context, ref) {
    final double fontSz = MediaQuery.sizeOf(context).height;
    final Orientation orientation = MediaQuery.orientationOf(context);
    final bool isEditTitle = ref.watch(isEditTitleProvider);
    final String currentTitle = currentPlace.title;
    final String newTitle = ref.watch(titleProvider);

    /// Если не редактируем, то текущее название.
    /// Если редактируем и не пустое, - новое название,
    /// если пустое, - остаётся текущее название
    final String title = !isEditTitle
        ? currentTitle
        : newTitle.isNotEmpty
            ? newTitle
            : currentTitle;

    return Card(
      elevation: 0,
      color: Colors.transparent,
      child: AutoSizeText(
        title,
        maxLines: 2,
        style: Theme.of(context).textTheme.titleLarge!.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontSize: orientation == Orientation.portrait ? fontSz * .043 : fontSz * .063,
              height: .9,
            ),
      ).animate(delay: 1.seconds).shakeX(duration: 200.ms),
    );
  }
}

/// Виджет отображения адреса
class OnDetailsAddressView extends ConsumerWidget {
  const OnDetailsAddressView({
    super.key,
    required this.currentPlace,
  });

  final Place currentPlace;

  @override
  Widget build(BuildContext context, ref) {
    final ColorScheme cScheme = Theme.of(context).colorScheme;
    final bool isEditLocation = ref.watch(isEditLocationProvider);
    final String currentAddress = currentPlace.location.address;
    final String newAddress = ref.watch(addressProvider);

    /// Если не редактируем местоположение, то текущий адрес.
    /// Если редактируем и не пустой, - новый адрес,
    /// если пустой, - остаётся текущий адрес.
    final address = !isEditLocation
        ? currentAddress
        : newAddress.isNotEmpty
            ? newAddress
            : currentAddress;

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Card(
              color: Colors.transparent,
              child: Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    color: cScheme.tertiary,
                    size: 30,
                  ),
                  const Gap(12),
                  Expanded(
                    child: Text(address,
                        textAlign: TextAlign.start,
                        softWrap: true,
                        style: TextStyle(
                          color: cScheme.tertiary,
                          fontSize: 14,
                        )),
                  )
                ],
              ))
          .animate()
          .fadeIn(
            duration: 900.ms,
            delay: 300.ms,
          )
          .shimmer(
            duration: 1.seconds,
            blendMode: BlendMode.srcOver,
            color: Colors.white12,
          )
          .move(
            begin: const Offset(-30, 0),
            curve: Curves.easeOutQuad,
          ),
    );
  }
}
