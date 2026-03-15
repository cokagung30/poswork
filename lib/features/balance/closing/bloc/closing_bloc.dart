import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poswork/data/models/models.dart';

part 'closing_event.dart';
part 'closing_state.dart';

class ClosingBloc extends Bloc<ClosingEvent, ClosingState> {
  ClosingBloc() : super(const ClosingState()) {
    on<BalanceChanged>(_onBalanceChanged);
    on<BalanceRemoved>(_onBalanceRemoved);
    on<BalanceCleared>(_onBalanceCleared);
    on<ClosingSubmitted>(_onClosingSubmitted);
  }

  void _onBalanceChanged(BalanceChanged event, Emitter<ClosingState> emit) {
    final currentClosingBalance = state.closingBalance?.toString();

    emit(
      state.copyWith(
        closingBalance: Wrapped.value(
          num.parse('${currentClosingBalance ?? ''}${event.value}'),
        ),
      ),
    );
  }

  void _onBalanceRemoved(BalanceRemoved _, Emitter<ClosingState> emit) {
    final currentClosingBalance = state.closingBalance?.toString();

    if (currentClosingBalance == null || currentClosingBalance.isEmpty) return;

    final balanceUpdated = currentClosingBalance.substring(
      0,
      currentClosingBalance.length - 1,
    );

    emit(
      state.copyWith(
        closingBalance: Wrapped.value(
          balanceUpdated.isNotEmpty ? num.parse(balanceUpdated) : null,
        ),
      ),
    );
  }

  void _onBalanceCleared(BalanceCleared _, Emitter<ClosingState> emit) {
    emit(state.copyWith(closingBalance: const Wrapped.value(null)));
  }

  Future<void> _onClosingSubmitted(
    ClosingSubmitted _,
    Emitter<ClosingState> emit,
  ) async {
    emit(state.copyWith(submitStatus: ProcessStatus.loading));

    await Future.delayed(const Duration(seconds: 1), () {
      emit(state.copyWith(submitStatus: ProcessStatus.success));
    });
  }
}
