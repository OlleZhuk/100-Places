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

  @override
  void initState() {
    _placesFuture = ref.read(userPlacesProvider.notifier).loadPlaces();
    super.initState();
  }

  @override
  Widget build(context) {
    final List<Place> userPlaces = ref.watch(userPlacesProvider);
    final double toolbarH = MediaQuery.sizeOf(context).height * .1;
    final TextTheme tTheme = Theme.of(context).textTheme;
    final ColorScheme cScheme = Theme.of(context).colorScheme;
    final int q = userPlaces.length;
    const double horPadds = 30;

    //* Виджет выпадающего меню сортировки
    final PopupMenuButton<String> popUpSortMenu = PopupMenuButton(
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

    //* Виджет выпадающего основного меню
    final PopupMenuButton popUpMainMenu = PopupMenuButton(
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
                //
                onTap: () => showDialog(
                    context: context,
                    builder: (context) => ConfirmAlert(
                        question: 'Удалить сразу все Места?',
                        event: () async {
                          await ref.read(userPlacesProvider.notifier).clearDB();
                          if (context.mounted) Navigator.of(context).pop();
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
    final Row titleWidget = Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        //< Иконка >
        Icon(
          Icons.local_see_rounded,
          color: cScheme.primary,
          size: toolbarH * .5,
        ),
        const Gap(12),
        //< 100 >
        Text(
          '100',
          style: tTheme.titleLarge!.copyWith(
            fontSize: toolbarH * .5,
          ),
        ),
        const Gap(4),
        //< Мест >
        Badge.count(
            largeSize: 16,
            smallSize: 10,
            backgroundColor: cScheme.primaryContainer,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            offset: const Offset(16, 0),
            count: q,
            textStyle: tTheme.labelMedium,
            //
            child: Text('Мест',
                style: tTheme.titleLarge!.copyWith(
                  fontSize: toolbarH * .5,
                  fontWeight: FontWeight.w600,
                )))
      ],
    );

    /// Экран Списка Мест
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
                      'assets/images/camera-overlay.webp',
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
            .fadeIn(duration: 2.seconds)
            .slideY(begin: .5));
  }
}

//| ВИДЖЕТЫ:                             >
//
//| _MainContent_
class MainContent extends ConsumerWidget {
  const MainContent({
    super.key,
    required this.sortCase,
  });

  final String sortCase;

  @override
  Widget build(context, ref) {
    final ColorScheme cScheme = Theme.of(context).colorScheme;
    final TextTheme tTheme = Theme.of(context).textTheme;
    final double deviceWidth = MediaQuery.sizeOf(context).width;
    final List<Place> userPlaces = ref.watch(userPlacesProvider);
    final ScrollController scrollController = ScrollController();
    final double imageWidth = deviceWidth * .42;
    final double offsetX = imageWidth * .92;
    final double offsetY = imageWidth * .8;
    final double maxCAE = deviceWidth * .51;

    //^ Варианты сортировки
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

    //^ Сетка картинок и скролл-бар
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
