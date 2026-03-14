import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(const LoginState()) {
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

  void _onClockUpdated(ClockUpdated event, Emitter<LoginState> emit) {
    emit(state.copyWith(currentTime: event.time));
  }
}
