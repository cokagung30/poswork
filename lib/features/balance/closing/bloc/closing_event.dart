part of 'closing_bloc.dart';

abstract class ClosingEvent extends Equatable {
  const ClosingEvent();

  @override
  List<Object?> get props => [];
}

class BalanceChanged extends ClosingEvent {
  const BalanceChanged(this.value);

  final num value;

  @override
  List<Object?> get props => [value];
}

class BalanceRemoved extends ClosingEvent {
  const BalanceRemoved();
}

class BalanceCleared extends ClosingEvent {
  const BalanceCleared();
}

class ClosingSubmitted extends ClosingEvent {
  const ClosingSubmitted();
}
