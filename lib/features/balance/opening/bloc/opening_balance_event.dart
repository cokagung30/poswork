part of 'opening_balance_bloc.dart';

abstract class OpeningBalanceEvent extends Equatable {
  const OpeningBalanceEvent();

  @override
  List<Object?> get props => [];
}

class ClockUpdated extends OpeningBalanceEvent {
  const ClockUpdated(this.time);

  final DateTime time;

  @override
  List<Object?> get props => [time];
}

class SuggestionSelected extends OpeningBalanceEvent {
  const SuggestionSelected(this.value);

  final num value;

  @override
  List<Object?> get props => [value];
}

class BalanceChanged extends OpeningBalanceEvent {
  const BalanceChanged(this.value);

  final num value;

  @override
  List<Object?> get props => [value];
}

class BalanceRemoved extends OpeningBalanceEvent {
  const BalanceRemoved();
}

class BalanceCleared extends OpeningBalanceEvent {
  const BalanceCleared();
}

class BalanceSubmitted extends OpeningBalanceEvent {
  const BalanceSubmitted();
}
