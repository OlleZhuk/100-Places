/// Экран "О приложении", ЭОП
library;

import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:super_bullet_list/bullet_list.dart';
import 'package:super_bullet_list/bullet_style.dart';
import 'package:url_launcher/url_launcher.dart';

import '/widgets/gradient_appbar.dart';

class AppInfo extends StatelessWidget {
  const AppInfo({super.key});

  launchURL() async {
    // const url = 'geo:55.755848,37.620409';
    Uri url = Uri.parse('geo:');
    // Uri url = Uri.parse('geo:55.755848,37.620409');
    // Uri url = Uri.parse('https://yandex.ru/legal/maps_termsofuse/');
    if (await launchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    print('=== МСБ ЭОП!!! ===');

    final cScheme = Theme.of(context).colorScheme;
    final tTheme = Theme.of(context).textTheme;

    Widget topicText(String data) => Text(
          data,
          style: TextStyle(color: cScheme.tertiary),
        );

    final List<Widget> topics = [
      topicText('Коллекция "100 Мест", версия 0.1.0'),
      topicText('Приложение предназначено для сбора и временного хранения коллекции тех самых мест, пребывание в которых произвело на вас неизгладимое впечатление.'),
      topicText('Временное хранение означает, что после очистки коллекции или после удаления приложения восстановить коллекцию не получится.'),
      topicText('Тем не менее, вы всегда можете воспоьлзоваться функцией "Поделиться". Лучше всего хранить Места не более 30 дней.'),
      Wrap(
        children: [
          topicText('В приложении используется карта Яндекса в строгом соответствии с'),
          topicText('принятыми '),
          InkWell(
            child: Text('условиями.',
                style: TextStyle(
                  color: cScheme.primaryContainer,
                  decoration: TextDecoration.underline,
                )),
            onTap: () async {
              await LaunchApp.openApp(
                androidPackageName: 'ru.nspk.mirpay',
                appStoreLink: 'https://www.rustore.ru/catalog/app/ru.nspk.mirpay',
                openStore: true,
              );
            },
            // onTap: () => launchURL(),
          )
        ],
      ),
    ];

    return Scaffold(
        appBar: AppBar(
          title: const Text('О приложении'),
          flexibleSpace: const GradientAppBar(),
        ),
        body: Center(
            child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                    child: Text(
                  '100',
                  textScaleFactor: 1,
                  style: tTheme.displayLarge!.copyWith(
                    color: cScheme.primaryContainer.withOpacity(.9),
                  ),
                ).animate().fadeIn(duration: 2.seconds).scale(
                          duration: 2.seconds,
                          curve: Curves.easeOutBack,
                        )),
                Positioned(
                    top: 50,
                    child: Padding(
                        padding: const EdgeInsets.only(left: 15.0),
                        child: Text('мест',
                            textScaleFactor: 7.5,
                            style: tTheme.titleMedium!.copyWith(
                              color: cScheme.background,
                              fontWeight: FontWeight.w900,
                            )).animate().fadeIn(duration: 3.seconds)))
              ],
            ),
            Expanded(
                child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 45),
                    child: SizedBox(
                      child: SuperBulletList(
                        isOrdered: false,
                        style: BulletStyle.discFill,
                        iconColor: cScheme.tertiary,
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
                            begin: const Offset(-30, 0),
                            curve: Curves.easeOutQuad,
                          ),
                    )))
          ],
        )));
  }
}
