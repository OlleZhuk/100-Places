/// Экран "О приложении", ЭОП
library;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:super_bullet_list/bullet_list.dart';
import 'package:super_bullet_list/bullet_style.dart';
import 'package:url_launcher/url_launcher.dart';

import '/widgets/shader_mask_decoration.dart';

class AppInfo extends StatelessWidget {
  const AppInfo({super.key});

  launchURL() async {
    //<   индикатор бы загрузки, а то просто висим и ждем...
    Uri url = Uri.parse('https://yandex.ru/legal/maps_termsofuse/');
    if (await launchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    final cScheme = Theme.of(context).colorScheme;
    final tTheme = Theme.of(context).textTheme;

    Widget topicText(String data) => Text(
          data,
          textScaleFactor: 1,
        );

    final List<Widget> topics = [
      topicText('Коллекция "100 Мест", версия 1.1.1'),
      topicText('Это приложение для сбора и временного хранения коллекции тех самых мест, пребывание в которых произвело на вас неизгладимое впечатление.'),
      topicText('Временное хранение означает, что после очистки коллекции или после удаления приложения восстановить коллекцию не получится.'),
      topicText('Тем не менее, у вас есть функция "Поделиться", чтобы не потерять самые важные Места.\n' 'Яндекс вообще рекомендует хранить полученный адрес не более 30 дней.'),
      Wrap(
        children: [
          topicText('В приложении используется карта Яндекса в соответствии с принятыми '),
          InkWell(
            child: Text(
              'условиями.',
              textScaleFactor: 1,
              style: TextStyle(
                color: cScheme.primaryContainer,
                decoration: TextDecoration.underline,
              ),
            ),
            onTap: () => launchURL(),
          ),
        ],
      ),
      topicText('Если Яндекс не выдаёт вам адрес по запросу, вероятнее всего, он выдаст его завтра. Чтобы не ждать, просто добавьте местоположение вручную.'),
      topicText('Разработчик разделяет удивление и негодование пользователя, получившего от Яндекс Карт принадлежность новых федеральных регионов по-прежнему Украине.'),
    ];

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            backgroundColor: cScheme.background,
            floating: true,
            flexibleSpace: FlexibleSpaceBar(
              expandedTitleScale: 1.8,
              background: Container(color: cScheme.background),
              title: ShaderMaskDecoration(
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(),
                    Positioned(
                      bottom: -30,
                      right: 0,
                      child: Text(
                        '100',
                        style: tTheme.displayLarge!.copyWith(
                          fontSize: 110,
                        ),
                      ).animate().fadeIn(duration: 1.seconds).scale(
                            duration: 2.seconds,
                            curve: Curves.easeOutBack,
                          ),
                    ),
                    Positioned(
                      bottom: -15,
                      right: 0,
                      child: Text(
                        'МЕСТ',
                        // textAlign: TextAlign.right,
                        style: tTheme.titleMedium!.copyWith(
                          fontSize: 58,
                        ),
                      ).animate().fadeIn(duration: 2.seconds),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: Gap(10),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 40,
              ),
              child: SizedBox(
                child: SuperBulletList(
                  isOrdered: false,
                  style: BulletStyle.discFill,
                  iconColor: cScheme.tertiary.withOpacity(.7),
                  iconSize: 5,
                  // customBullet: const Text('🔥'),
                  gap: 10,
                  items: topics,
                )
                    .animate(delay: 1.seconds)
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
                      begin: const Offset(30, 0),
                      curve: Curves.easeOutQuad,
                    ),
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: Gap(10),
          ),
          const SliverToBoxAdapter(
            child: MediaQueryImplementation(),
          ),
          const SliverToBoxAdapter(
            child: Gap(100),
          ),
        ],
      ),
    );
  }
}

/// MediaQuery implementation
class MediaQueryImplementation extends StatelessWidget {
  const MediaQueryImplementation({super.key});

  @override
  Widget build(BuildContext context) {
    final Size virtualScreenSize = MediaQuery.sizeOf(context);
    final double pixelRatio = MediaQuery.devicePixelRatioOf(context);
    final double currentDPI = 160 * pixelRatio;
    final Size realScreenSize = virtualScreenSize * pixelRatio;
    final double textScaleFactor = MediaQuery.textScaleFactorOf(context);
    final Brightness platformBrightness = MediaQuery.platformBrightnessOf(context);
    final EdgeInsets padding = MediaQuery.paddingOf(context);
    final EdgeInsets viewInsets = MediaQuery.viewInsetsOf(context);
    final EdgeInsets systemGestureInsets = MediaQuery.systemGestureInsetsOf(context);
    final bool alwaysUse24HourFormat = MediaQuery.alwaysUse24HourFormatOf(context);
    final bool accessibleNavigation = MediaQuery.accessibleNavigationOf(context);
    final bool invertColors = MediaQuery.invertColorsOf(context);
    final bool highContrast = MediaQuery.highContrastOf(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50),
      child: SizedBox(
        child: Text('=====================\n'
            'Служебная информация\n'
            '------------------------------------------\n'
            'Real screen size, RSS: $realScreenSize\n'
            'Device pixel ratio, DPR: $pixelRatio\n'
            'Virtual screen size, VSS: $virtualScreenSize\n'
            'CurrentDPI: $currentDPI\n'
            'Text scale factor: $textScaleFactor\n'
            'Platform brightness: $platformBrightness\n'
            'Padding: $padding\n'
            'View insets: $viewInsets\n'
            'System gesture insets: $systemGestureInsets\n'
            'Always use 24-hour format: $alwaysUse24HourFormat\n'
            'Accessible navigation: $accessibleNavigation\n'
            'Invert colors: $invertColors\n'
            'High contrast: $highContrast\n'),
      ),
    );
  }
}
