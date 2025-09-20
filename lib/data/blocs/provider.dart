import 'package:flutter/material.dart';

import 'bloc.dart';

class BlocProvider extends InheritedWidget {
  final DayfiAppBloc bloc;

  BlocProvider({required this.bloc, required super.child});

  @override
  bool updateShouldNotify(BlocProvider oldWidget) {
    return oldWidget.bloc != bloc;
  }

  static DayfiAppBloc provideBloc(BuildContext ctx) =>
      ctx.dependOnInheritedWidgetOfExactType<BlocProvider>()!.bloc;
}
