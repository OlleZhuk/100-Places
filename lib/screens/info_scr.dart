/// Экран информации, ЭИ
library;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:super_bullet_list/bullet_list.dart';
import 'package:super_bullet_list/bullet_style.dart';
import 'package:url_launcher/url_launcher.dart';

import '/widgets/shader_mask_decoration.dart';

class AppInfo extends StatelessWidget {
  const AppInfo({super.key});

  //* Метод обращения к Условиям использования Я.Карт (требование)
  launchURL() async {
    Uri url = Uri.parse('https://yandex.ru/legal/maps_termsofuse/');
    if (await launchUrl(url)) {
      launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme cScheme = Theme.of(context).colorScheme;
    final TextTheme tTheme = Theme.of(context).textTheme;
    final Orientation orientation = MediaQuery.orientationOf(context);
    final double deviceH = MediaQuery.sizeOf(context).height;

    final double fontSz = orientation == Orientation.portrait ? deviceH * .018 : deviceH * .036;
    final TextStyle fontStyle = TextStyle(fontSize: fontSz);

    final List<Widget> topics = [
      Text(
        'Коллекция "100 Мест", версия 1.1.2',
        style: fontStyle,
      ),
      Text(
        'Приложение позволяет собрать и временно хранить коллекцию тех самых мест, пребывание в которых произвело на пользователя неизгладимое впечатление.',
        style: fontStyle,
      ),
      Text(
        'Временное хранение означает, что после полной очистки коллекции или после удаления приложения восстановить коллекцию не получится.',
        style: fontStyle,
      ),
      Text(
        'Однако у пользователя под рукой всегда остаётся функция "Поделиться", чтобы не потерять самые важные Места.',
        style: fontStyle,
      ),
      Text(
        'Любимое Место оформляется как изображение с названием и адресом, который выдаётся автоматически Яндекс.Картами или добавляется вручную.',
        style: fontStyle,
      ),
      RichText(
        text: TextSpan(
          style: TextStyle(color: cScheme.tertiary.withOpacity(.8), fontSize: fontSz * 1.17),
          children: [
            const TextSpan(
              text: 'Сервис "Яндекс.Карты", который используется в соответствии с принятыми ',
            ),
            TextSpan(
              text: 'условиями, ',
              style: TextStyle(
                fontSize: fontSz * 1.17,
                color: cScheme.primaryContainer,
                decoration: TextDecoration.underline,
              ),
              recognizer: TapGestureRecognizer()..onTap = () => launchURL(),
            ),
            const TextSpan(
              text: 'рекомендует пользователю хранить полученный адрес не более 30 дней.',
            ),
          ],
        ),
      ),
      Text(
        'В случае, когда Яндекс.Карты не выдают адрес из-за окончания суточного лимита адресов, можно добавить адрес Места вручную.',
        style: fontStyle,
      ),
      Text(
        'Коллекция "100 Мест" в целях безопасности хранится только на устройстве, поэтому пользователь остаётся единственной персоной, имеющей к ней доступ.',
        style: fontStyle,
      ),
      Text(
        'Разработчик разделяет удивление и негодование пользователя, получившего от Яндекс.Карт адрес с принадлежностью новых федеральных регионов по-прежнему Украине.',
        style: fontStyle,
      ),
    ];

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          //`
          SliverAppBar(
              expandedHeight: 200,
              backgroundColor: cScheme.background,
              floating: true,
              flexibleSpace: FlexibleSpaceBar(
                  expandedTitleScale: 1.8,
                  background: Container(color: cScheme.background),
                  title: ShaderMaskDecoration(
                      child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(), // незыблемый
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
                          style: tTheme.displayMedium!.copyWith(
                            fontSize: 58,
                          ),
                        ).animate().fadeIn(duration: 2.seconds),
                      ),
                    ],
                  )))),
          //`
          const SliverToBoxAdapter(child: Gap(10)),
          //`
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
                  ))),
          //`
          const SliverToBoxAdapter(child: Gap(200)),
        ],
      ),
    );
  }
}
