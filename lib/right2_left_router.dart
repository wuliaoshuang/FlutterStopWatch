import 'package:flutter/cupertino.dart';

class Right2LeftRouter<T> extends PageRouteBuilder<T> {
  final Widget child;
  final int durationMs;
  final Curve curve;

  Right2LeftRouter(
      {required this.child,
        this.durationMs = 200,
        this.curve = Curves.fastOutSlowIn})
      : super(
      transitionDuration: Duration(milliseconds: durationMs),
      pageBuilder: (ctx, a1, a2) => child,
      transitionsBuilder: (ctx, a1, a2, child) =>
          SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: const Offset(0.0, 0.0),
            ).animate(CurvedAnimation(parent: a1, curve: curve)),
            child: child,
          ));
}