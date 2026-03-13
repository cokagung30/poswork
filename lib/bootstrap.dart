import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:logger/logger.dart';
import 'package:poswork/app/app_bloc_observer.dart';

typedef AppBuilder = Future<Widget> Function();

Future<void> bootstraps(AppBuilder builder) async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('id');

  await Jiffy.setLocale('id');

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarIconBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      statusBarColor: Color(0x00000000),
    ),
  );

  Intl.systemLocale = 'id';

  final logger = Logger();
  final blocObserver = AppBlocObserver(logger: logger);

  Bloc.observer = blocObserver;

  runApp(await builder());
}
