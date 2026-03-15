part of 'opening_balance_bloc.dart';

class OpeningBalanceState extends Equatable {
  const OpeningBalanceState({
    this.currentTime,
    this.suggestionValueSelected = 0,
    this.balance = 0,
    this.submitStatus = ProcessStatus.initial,
  });

  final DateTime? currentTime;

  final num suggestionValueSelected;

  final num balance;

  final ProcessStatus submitStatus;

  OpeningBalanceState copyWith({
    DateTime? currentTime,
    num? suggestionValueSelected,
    num? balance,
    ProcessStatus? submitStatus,
  }) {
    return OpeningBalanceState(
      currentTime: currentTime ?? this.currentTime,
      suggestionValueSelected:
          suggestionValueSelected ?? this.suggestionValueSelected,
      balance: balance ?? this.balance,
      submitStatus: submitStatus ?? this.submitStatus,
    );
  }

  @override
  List<Object?> get props => [
    currentTime,
    suggestionValueSelected,
    balance,
    submitStatus,
  ];
}
