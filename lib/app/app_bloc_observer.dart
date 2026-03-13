import 'package:bloc/bloc.dart';
import 'package:logger/logger.dart';

class AppBlocObserver extends BlocObserver {
  const AppBlocObserver({required Logger logger}) : _logger = logger;

  final Logger _logger;

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);

    _logger.e(
      'onError ${bloc.runtimeType}',
      error: error,
      stackTrace: stackTrace,
    );
  }
}
