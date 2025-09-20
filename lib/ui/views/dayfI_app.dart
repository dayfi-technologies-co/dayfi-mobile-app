// ignore: file_names
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:dayfi/data/blocs/bloc.dart';
import 'package:dayfi/data/blocs/provider.dart';
import 'package:dayfi/ui/views/platform_adapting_home_page.dart';
import 'package:dayfi/utilities.dart';

import 'package:dayfi/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class DayfiApp extends StatefulWidget {
  final String selectedPaymentMethod;

  const DayfiApp({super.key, required this.selectedPaymentMethod});
  @override
  State<DayfiApp> createState() => _DayfiAppState();
}

class _DayfiAppState extends State<DayfiApp> {
  late DayfiAppBloc bloc;

  @override
  void initState() {
    bloc = DayfiAppBloc();
    super.initState();
  }

  @override
  Widget build(context) {
    return BlocProvider(
      bloc: bloc,
      // Either Material or Cupertino widgets work in either Material or Cupertino
      // Apps.
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        onGenerateTitle: (context) {
          return S(context).homeScreenTitle;
        },
        home: PlatformAdaptingHomePage(
          selectedPaymentMethod: widget.selectedPaymentMethod,
        ),
      ),
    );
  }
}
