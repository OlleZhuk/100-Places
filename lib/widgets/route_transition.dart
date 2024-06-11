/// Конструктор Перехода, КП
library;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class MyRouteTransition extends PageRouteBuilder {
  final Widget widget;

  MyRouteTransition(this.widget)
      : super(
          transitionDuration: 1.seconds,
          reverseTransitionDuration: 400.ms,
          pageBuilder: (ctx, animation_, sdAnimation_) => widget,
          transitionsBuilder: (
            ctx,
            animation,
            sdAnimation_,
            Widget child,
          ) {
            animation = CurvedAnimation(
              curve: Curves.easeInOut,
              parent: animation,
            );
            Animation<Offset> offset = Tween<Offset>(
              begin: const Offset(.6, 0),
              end: Offset.zero,
            ).animate(animation);

            return SlideTransition(
              position: offset,
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
        );
}
