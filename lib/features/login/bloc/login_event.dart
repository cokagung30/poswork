part of 'login_bloc.dart';

abstract class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object?> get props => [];
}

class ClockUpdated extends LoginEvent {
  const ClockUpdated(this.time);

  final DateTime time;

  @override
  List<Object?> get props => [time];
}

class PinChanged extends LoginEvent {
  const PinChanged(this.pin);

  final num pin;

  @override
  List<Object?> get props => [pin];
}

class PinRemoved extends LoginEvent {
  const PinRemoved();
}
