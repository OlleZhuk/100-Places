/// Экран Списка Мест, ЭСМ
library;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '/models/place.dart';
import '/providers/user_places.dart';
import '/widgets/custom_fab.dart';
import '/widgets/alert_dialogs.dart';
import '/widgets/route_transition.dart';
import '/widgets/shader_mask_decoration.dart';
import 'add_place_scr.dart';
import 'info_scr.dart';
import 'place_detail_scr.dart';

class PlacesScreen extends ConsumerStatefulWidget {
  const PlacesScreen({super.key});

  @override
  ConsumerState<PlacesScreen> createState() => _PlacesScreenState();
}

class _PlacesScreenState extends ConsumerState<PlacesScreen> {
  late Future<void> _placesFuture;
  String sortCase = '';
  ColorScheme get cScheme => Theme.of(context).colorScheme;

  //* Виджет выпадающего меню сортировки
  Widget get popUpSortMenu => PopupMenuButton(
      offset: const Offset(0, -10),
      icon: Icon(
        Icons.sort,
        size: 30,
        color: cScheme.inversePrimary,
      ),
      itemBuilder: (ctx) => [
            PopupMenuItem(
                value: 'AZ',
                child: const Text('Названия А-Я').animate().flipH(
                      duration: 300.ms,
                    )),
            PopupMenuItem(
                value: 'ZA',
                child: const Text('Названия Я-А').animate().flipH(
                      duration: 400.ms,
                    )),
            PopupMenuItem(
                value: 'new',
                child: const Text('Сначала новые').animate().flipH(
                      duration: 500.ms,
                    )),
            PopupMenuItem(
                value: 'old',
                child: const Text('Сначала старые').animate().flipH(
                      duration: 600.ms,
                    )),
          ],
      onSelected: (String value) {
        setState(() {
          sortCase = value;
        });
      });

  @override
  void initState() {
    _placesFuture = ref.read(userPlacesProvider.notifier).loadPlaces();
    super.initState();
  }

  @override
  Widget build(context) {
    List<Place> userPlaces = ref.watch(userPlacesProvider);
    final deviceHeight = MediaQuery.sizeOf(context).height;
    final toolbarH = deviceHeight * .09;
    final tTheme = Theme.of(context).textTheme;
    final q = userPlaces.length;
    const double horPadds = 30;

    //* Виджет выпадающего основного меню
    final popUpMainMenu = PopupMenuButton(
        offset: const Offset(0, -10),
        icon: Icon(
          Icons.menu,
          size: 30,
          color: cScheme.inversePrimary,
        ),
        itemBuilder: (ctx) => [
              PopupMenuItem(
                enabled: userPlaces.isNotEmpty ? true : false,
                child: const Row(
                  children: [
                    Icon(Icons.phonelink_erase),
                    Gap(10),
                    Flexible(child: Text('Очистить коллекцию')),
                  ],
                ).animate().flipH(duration: 300.ms),
                onTap: () => showDialog(
                    context: context,
                    builder: (context) => ConfirmAlert(
                        question: 'Удалить сразу все Места?',
                        event: () async {
                          Navigator.of(context).pop();
                          await ref.read(userPlacesProvider.notifier).clearDB();
                        })),
              ),
              PopupMenuItem(
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline),
                      Gap(10),
                      Flexible(child: Text('О приложении')),
                    ],
                  ).animate().flipH(duration: 500.ms),
                  onTap: () => Navigator.of(context).push(MyRouteTransition(
                        const AppInfo(),
                      ))),
            ]);

    //* Виджет заголовка панели приложений
    final titleWidget = Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Icon(
          Icons.local_see_rounded,
          color: cScheme.primary,
          size: 30,
        ),
        const Gap(12),
        Text(
          '100',
          style: tTheme.titleLarge!.copyWith(
            fontSize: 30,
          ),
        ),
        const Gap(10),
        Badge.count(
            largeSize: 18,
            smallSize: 8,
            backgroundColor: cScheme.primaryContainer,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            offset: const Offset(20, 0),
            count: q,
            textStyle: tTheme.labelMedium,
            //
            child: Text('Мест',
                style: tTheme.titleLarge!.copyWith(
                  fontSize: 30,
                  fontWeight: FontWeight.w600,
                )))
      ],
    );

    print('=== МСБ ЭСМ!!! ===');
    // print('=== $horPadds ===');

    return Scaffold(
        appBar: AppBar(
          toolbarHeight: toolbarH,
          leading: popUpMainMenu,
          title: titleWidget,
          actions: [popUpSortMenu],
        ),
        body: userPlaces.isEmpty
            ? Center(
                heightFactor: 1.72,
                child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: horPadds),
                    child: Image.asset(
                      'assets/camera-overlay.webp',
                    ).animate().fadeIn(duration: 1.seconds)))
            : FutureBuilder(
                future: _placesFuture,
                builder: (
                  context,
                  snapshot,
                ) =>
                    snapshot.connectionState == ConnectionState.waiting
                        ? CircularProgressIndicator(color: cScheme.primary)
                        : ShaderMaskDecoration(
                            child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 7),
                            child: MainContent(sortCase: sortCase),
                          ))),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: CustomFAB(
                labelText: 'Добавить Место',
                buttonIcon: Icons.add,
                action: () => Navigator.of(context).push(MyRouteTransition(
                      const AddPlaceScreen(),
                    )))
            .animate(
              delay: 2.seconds,
            )
            .fadeIn(
              duration: 2.seconds,
            )
            .slideY(
              begin: .5,
            ));
  }
}

/// ВИДЖЕТЫ
///
//* _MainContent_ ------------------------
class MainContent extends ConsumerWidget {
  const MainContent({
    super.key,
    required this.sortCase,
  });

  final String sortCase;

  @override
  Widget build(context, ref) {
    final userPlaces = ref.watch(userPlacesProvider);
    final scrollController = ScrollController();
    final deviceWidth = MediaQuery.of(context).size.width;
    final imageWidth = deviceWidth * .42;
    final offsetX = imageWidth * .92; //0.3864
    final offsetY = imageWidth * .8; //0.336
    final maxCAE = deviceWidth * .51;
    final cScheme = Theme.of(context).colorScheme;
    final tTheme = Theme.of(context).textTheme;

    /// Варианты сортировки
    switch (sortCase) {
      case "AZ":
        userPlaces.sort((a, b) => a.title.compareTo(b.title));
        break;
      case "ZA":
        userPlaces.sort((b, a) => a.title.compareTo(b.title));
        break;
      case "old":
        userPlaces.sort((a, b) => a.date.compareTo(b.date));
        break;
      case "new":
        userPlaces.sort((b, a) => a.date.compareTo(b.date));
        break;
      default:
        userPlaces.sort((b, a) => a.date.compareTo(b.date));
        break;
    }

    print('=== МСБ MainContent ЭСМ!!! ===');

    /// Сетка картинок и скролл-бар
    return Scrollbar(
        controller: scrollController,
        child: GridView.builder(
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              childAspectRatio: 1 / 1,
              maxCrossAxisExtent: maxCAE,
            ),
            controller: scrollController,
            physics: const BouncingScrollPhysics(),
            itemCount: userPlaces.length,
            itemBuilder: (ctx, index) => GestureDetector(
                //
                onTap: () => Navigator.of(context).push(MyRouteTransition(
                      PlaceDetailScreen(place: userPlaces[index]),
                    )),
                //
                child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    //
                    child: Badge(
                        backgroundColor: cScheme.background.withOpacity(.6),
                        offset: Offset(-offsetX, offsetY),
                        largeSize: 30,
                        //
                        label: SizedBox(
                            width: imageWidth * .91,
                            child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text(
                                  userPlaces[index].title,
                                  style: tTheme.titleSmall,
                                  overflow: TextOverflow.ellipsis,
                                ))),
                        //
                        child: ClipRRect(
                            borderRadius: const BorderRadius.all(
                              Radius.circular(20),
                            ),
                            //
                            child: Image(
                              image: FileImage(userPlaces[index].image),
                              fit: BoxFit.cover,
                              height: imageWidth,
                              width: imageWidth,
                            )))))));
  }
}
