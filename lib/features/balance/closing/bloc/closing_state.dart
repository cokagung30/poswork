part of 'closing_bloc.dart';

class ClosingState extends Equatable {
  const ClosingState({
    this.closingBalance,
    this.totalCash = 2450000,
    this.submitStatus = ProcessStatus.initial,
  });

  final num? closingBalance;

  final num totalCash;

  final ProcessStatus submitStatus;

  BalanceValidationStatus get status {
    if (closingBalance == null) return BalanceValidationStatus.initial;

    if (totalCash == closingBalance) return BalanceValidationStatus.valid;

    return BalanceValidationStatus.invalid;
  }

  num? get balanceDiff {
    if (closingBalance == null) return null;

    return closingBalance! - totalCash;
  }

  ClosingState copyWith({
    Wrapped<num?>? closingBalance,
    ProcessStatus? submitStatus,
  }) {
    return ClosingState(
      closingBalance: closingBalance != null
          ? closingBalance.value
          : this.closingBalance,
      submitStatus: submitStatus ?? this.submitStatus,
    );
  }

  @override
  List<Object?> get props => [closingBalance, submitStatus];
}

enum BalanceValidationStatus { initial, valid, invalid }
