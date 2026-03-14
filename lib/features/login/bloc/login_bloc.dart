import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(const LoginState()) {
    on<ClockUpdated>(_onClockUpdated);
    on<PinChanged>(_onPinChanged);
    on<PinRemoved>(_onPinRemoved);

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

  void _onPinChanged(PinChanged event, Emitter<LoginState> emit) {
    final currentPin = state.pin;

    if (currentPin.length < 4) {
      emit(state.copyWith(pin: '$currentPin${event.pin}'));
    }
  }

  void _onPinRemoved(PinRemoved _, Emitter<LoginState> emit) {
    final currentPin = state.pin;
    if (currentPin.isEmpty) return;
    emit(state.copyWith(pin: currentPin.substring(0, currentPin.length - 1)));
  }
}
