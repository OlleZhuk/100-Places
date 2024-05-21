/// Экран "О приложении", ЭОП
library;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:super_bullet_list/bullet_list.dart';
import 'package:super_bullet_list/bullet_style.dart';
import 'package:url_launcher/url_launcher.dart';

import '/widgets/gradient_appbar.dart';

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
    print('=== МСБ ЭОП!!! ===');

    final cScheme = Theme.of(context).colorScheme;
    final tTheme = Theme.of(context).textTheme;
    double fSize = 12;
    double horPadds = 44;

    Widget topicText(String data) => Text(
          data,
          style: TextStyle(fontSize: fSize),
        );

    final List<Widget> topics = [
      topicText('Коллекция "100 Мест", версия 1.1.1'),
      topicText('Это приложение для сбора и временного хранения коллекции тех самых мест, пребывание в которых произвело на вас неизгладимое впечатление.'),
      topicText('Временное хранение означает, что после очистки коллекции или после удаления приложения восстановить коллекцию не получится.'),
      topicText('Тем не менее, у вас есть функция "Поделиться", чтобы не потерять самые важные Места. Яндекс вообще рекомендует хранить адреса не более 30 дней.'),
      Wrap(
        children: [
          topicText('В приложении используется карта Яндекса в соответствии с'),
          InkWell(
            child: Text(
              'условиями.',
              style: TextStyle(
                fontSize: fSize,
                color: cScheme.primaryContainer,
                decoration: TextDecoration.underline,
              ),
            ),
            onTap: () => launchURL(),
          ),
        ],
      ),
      topicText('Если Яндекс не выдаёт вам адрес по запросу, вероятнее всего, он выдаст его завтра. Чтобы не ждать, просто добавьте местоположение вручную.'),
      topicText('Разработчик разделяет удивление и негодование пользователя, получившего перед адресом внутри новых федеральных регионов упоминание о так называемой Украине.'),
    ];

    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'О приложении',
            style: TextStyle(fontSize: 30),
          ),
          toolbarHeight: 70,
          flexibleSpace: const GradientAppBar(),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Positioned(
                      child: Text(
                    '100',
                    style: tTheme.displayLarge!.copyWith(
                      fontSize: 126,
                    ),
                  ).animate().fadeIn(duration: 2.seconds).scale(
                            duration: 2.seconds,
                            curve: Curves.easeOutBack,
                          )),
                  Positioned(
                      bottom: 14,
                      child: Text(
                        'МЕСТ',
                        style: tTheme.titleMedium!.copyWith(
                          fontSize: 86,
                        ),
                      ).animate().fadeIn(duration: 3.seconds))
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: horPadds,
                ),
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
              ),
              const Gap(20),
            ],
          ),
        ));
  }
}
