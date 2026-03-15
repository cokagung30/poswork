import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'main_event.dart';
part 'main_state.dart';

class MainBloc extends Bloc<MainEvent, MainState> {
  MainBloc() : super(const MainState()) {
    on<ClockUpdated>(_onClockUpdated);

    _clockSubscription =
        Stream<DateTime>.periodic(
          const Duration(seconds: 1),
          (_) => DateTime.now(),
        ).listen((time) {
          add(ClockUpdated(time));
        });
  }

  late final StreamSubscription<DateTime> _clockSubscription;

  @override
  Future<void> close() async {
    await _clockSubscription.cancel();
    return super.close();
  }

  void _onClockUpdated(ClockUpdated event, Emitter<MainState> emit) {
    emit(state.copyWith(currentTime: event.currenTime));
  }
}
