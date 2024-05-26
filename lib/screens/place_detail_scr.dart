/// Экран Информации о Месте, ЭИМ
library;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:photo_view/photo_view.dart';
import 'package:share_plus/share_plus.dart';

import '../providers/any_locations.dart';
import '../providers/any_states.dart';
import '/providers/geocoder.dart';
import '../widgets/alert_dialogs.dart';
import '/widgets/route_transition.dart';
import '../providers/user_places.dart';
import '/models/place.dart';
import 'map_scr.dart';

class PlaceDetailScreen extends ConsumerWidget {
  const PlaceDetailScreen({
    super.key,
    required this.place,
  });

  final Place place;

  @override
  Widget build(context, ref) {
    final cScheme = Theme.of(context).colorScheme;
    final tTheme = Theme.of(context).textTheme;
    final toolbarH = MediaQuery.sizeOf(context).height * .1;
    final String currentDate = place.date;
    final PlaceLocation currentLocation = place.location;

    //* Метод редакции названия
    Future<void> editTitle() async {
      final titleController = TextEditingController();

      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          backgroundColor: cScheme.background,
          content: Padding(
              padding: const EdgeInsets.only(top: 5),
              //
              child: TextField(
                  controller: titleController,
                  autofocus: true,
                  maxLength: 30,
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
                          onPressed: () {
                            titleController.clear();
                          },
                          icon: const Icon(Icons.clear)),
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
          actionsPadding: const EdgeInsets.only(
            right: 24,
            bottom: 16,
          ),
          //
          actions: [
            ElevatedButton(
              child: const Text("Подтвердить"),
              onPressed: () async {
                ref.read(isEditTitleProvider.notifier).state = true;
                final enteredTitle = titleController.text;
                if (enteredTitle.isEmpty) {
                  return;
                }
                Navigator.of(context).pop();
                ref.read(titleProvider.notifier).state = enteredTitle;
                await ref.read(userPlacesProvider.notifier).updateTitle(
                      enteredTitle, // title
                      place.date, // date
                    );
              },
            ),
          ],
        )
            .animate(
              delay: 500.ms,
            )
            .fadeIn(
              duration: 800.ms,
            )
            .scale(
              curve: Curves.easeOutBack,
            ),
      );
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
      await Share.shareXFiles(
        [XFile(place.image.path)],
        text: '''
НАЗВАНИЕ: ${place.title}
АДРЕС: ${place.location.address.toString()}
КООРДИНАТЫ:
${place.location.latitude.toString()} 
${place.location.longitude.toString()}
ДАТА: ${place.date.replaceRange(16, null, '')}
      ''',
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

    print('=== МСБ ЭИМ!!! ===');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: TitleView(currentPlace: place),
        toolbarHeight: toolbarH,
        leading: BackButton(
          onPressed: () {
            ref.read(isEditTitleProvider.notifier).state = false;
            ref.read(isEditLocationProvider.notifier).state = false;
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
    );
  }
}

/// ВИДЖЕТЫ --------------------------------
///
//* Виджет отображения названия
class TitleView extends ConsumerWidget {
  const TitleView({
    super.key,
    required this.currentPlace,
  });

  final Place currentPlace;

  @override
  Widget build(BuildContext context, ref) {
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
              fontSize: 32,
              height: .9,
            ),
      ).animate(delay: 1.seconds).shakeX(duration: 200.ms),
    );
  }
}

//* Виджет отображения адреса
class OnDetailsAddressView extends ConsumerWidget {
  const OnDetailsAddressView({
    super.key,
    required this.currentPlace,
  });

  final Place currentPlace;

  @override
  Widget build(BuildContext context, ref) {
    final cScheme = Theme.of(context).colorScheme;
    final isEditLocation = ref.watch(isEditLocationProvider);
    final currentAddress = currentPlace.location.address;
    final newAddress = ref.watch(addressProvider);

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
                    child: Text(
                      address,
                      textAlign: TextAlign.start,
                      softWrap: true,
                      style: TextStyle(
                        color: cScheme.tertiary,
                        fontSize: 14,
                      ),
                    ),
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
