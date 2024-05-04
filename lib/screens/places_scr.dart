/// Экран Списка Мест, ЭСМ
library;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '/models/place.dart';
import '../providers/user_places.dart';
import '/widgets/custom_fab.dart';
import '../widgets/alert_dialogs.dart';
import '/widgets/gradient_appbar.dart';
import '/widgets/route_transition.dart';
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
  String _sortCase = '';

  List<Place> get userPlaces => ref.watch(userPlacesProvider);
  ColorScheme get cScheme => Theme.of(context).colorScheme;
  TextTheme get tTheme => Theme.of(context).textTheme;
  double get deviceHeigh => MediaQuery.sizeOf(context).height;

  //* Виджет выпадающего основного меню
  Widget get popUpMainMenu => PopupMenuButton(
      offset: const Offset(0, -10),
      icon: Icon(
        Icons.menu,
        size: 30,
        color: cScheme.inversePrimary,
      ),
      itemBuilder: (ctx) => [
            PopupMenuItem(
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
          _sortCase = value;
        });
      });

  //* Виджет заголовка панели приложений
  Widget get titleWidget {
    final q = userPlaces.length;

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Icon(
          Icons.local_see_rounded,
          color: cScheme.primary,
          size: 35,
        ),
        const Gap(12),
        const Text('100'),
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
                  color: cScheme.primary,
                  fontWeight: FontWeight.w600,
                )))
      ],
    );
  }

  @override
  void initState() {
    _placesFuture = ref.read(userPlacesProvider.notifier).loadPlaces();
    super.initState();
  }

  @override
  Widget build(context) {
    print('=== МСБ ЭСМ!!! ===');

    return Scaffold(
        appBar: userPlaces.isNotEmpty
            ? AppBar(
                flexibleSpace: const GradientAppBar(),
                leading: popUpMainMenu,
                title: titleWidget,
                actions: [popUpSortMenu],
              )
            : null,
        body: userPlaces.isEmpty
            ? Center(
                child: Image.asset(
                'assets/camera-overlay.webp',
              )
                    .animate()
                    .scaleY(
                      duration: 1.seconds,
                      curve: Curves.easeOutBack,
                    )
                    .scaleX(
                      delay: 1.seconds,
                      duration: 2.seconds,
                      curve: Curves.easeOutBack,
                    ))
            : FutureBuilder(
                future: _placesFuture,
                builder: (
                  context,
                  snapshot,
                ) =>
                    snapshot.connectionState == ConnectionState.waiting
                        ? CircularProgressIndicator(color: cScheme.primary)
                        : SafeArea(
                            child: ShaderMaskDecoration(
                                child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 7),
                              child: MainContent(sortCase: _sortCase),
                            )),
                          )),
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
/// -------------------------------------
class MainContent extends ConsumerWidget {
  const MainContent({
    super.key,
    required this.sortCase,
  });

  final String sortCase;

  @override
  Widget build(context, ref) {
    print('=== МСБ MainContent ЭСМ!!! ===');

    final userPlaces = ref.watch(userPlacesProvider);
    final scrollController = ScrollController();
    final deviceWidth = MediaQuery.of(context).size.width;
    final imageWidth = deviceWidth * .42;
    final cScheme = Theme.of(context).colorScheme;
    final tTheme = Theme.of(context).textTheme;

    //^ варианты сортировки
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

    /// Сетка картинок и скролл-бар
    return Scrollbar(
        controller: scrollController,
        child: GridView.builder(
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              childAspectRatio: 1 / 1,
              maxCrossAxisExtent: deviceWidth * .51,
            ),
            controller: scrollController,
            physics: const BouncingScrollPhysics(),
            itemCount: userPlaces.length,
            itemBuilder: (ctx, index) => GestureDetector(
                //
                //^ Переход на экран детализации
                onTap: () => Navigator.of(context).push(MyRouteTransition(
                      PlaceDetailScreen(place: userPlaces[index]),
                    )),

                //^ Основной контент:
                //^ картинка с бейджиком-названием
                child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    //
                    child: Badge(
                        backgroundColor: cScheme.background.withOpacity(.6),
                        offset: Offset(-imageWidth * .92, imageWidth * .8),
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

/// ------------------------------------------------
/// Верхнее и нижнее затемнения

class ShaderMaskDecoration extends StatelessWidget {
  const ShaderMaskDecoration({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final cScheme = Theme.of(context).colorScheme;

    return ShaderMask(
      shaderCallback: (Rect rect) => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          cScheme.background,
          Colors.transparent,
          Colors.transparent,
          cScheme.background,
        ],
        stops: const [0.0, 0.03, 0.85, 1.0], //^ 5% цвет, 79% transparent, 15% цвет
      ).createShader(rect),
      blendMode: BlendMode.dstOut,
      child: child,
    );
  }
}
