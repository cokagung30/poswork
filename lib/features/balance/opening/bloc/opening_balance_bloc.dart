import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poswork/data/models/models.dart';

part 'opening_balance_event.dart';
part 'opening_balance_state.dart';

class OpeningBalanceBloc
    extends Bloc<OpeningBalanceEvent, OpeningBalanceState> {
  OpeningBalanceBloc() : super(const OpeningBalanceState()) {
    on<ClockUpdated>(_onClockUpdated);
    on<SuggestionSelected>(_onSuggestionSelected);
    on<BalanceChanged>(_onBalanceChanged);
    on<BalanceRemoved>(_onBalanceRemoved);
    on<BalanceCleared>(_onBalanceCleared);
    on<BalanceSubmitted>(_onBalanceSubmitted);

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

  void _onClockUpdated(ClockUpdated event, Emitter<OpeningBalanceState> emit) {
    emit(state.copyWith(currentTime: event.time));
  }

  void _onSuggestionSelected(
    SuggestionSelected event,
    Emitter<OpeningBalanceState> emit,
  ) {
    emit(
      state.copyWith(
        suggestionValueSelected: event.value,
        balance: event.value,
      ),
    );
  }

  void _onBalanceChanged(
    BalanceChanged event,
    Emitter<OpeningBalanceState> emit,
  ) {
    final currentBalance = state.balance;

    emit(state.copyWith(balance: num.parse('$currentBalance${event.value}')));
  }

  void _onBalanceRemoved(BalanceRemoved _, Emitter<OpeningBalanceState> emit) {
    final currentBalance = state.balance.toString();
    final balanceUpdated = currentBalance.substring(
      0,
      currentBalance.length - 1,
    );

    emit(
      state.copyWith(
        balance: num.parse((balanceUpdated.isEmpty) ? '0' : balanceUpdated),
      ),
    );
  }

  void _onBalanceCleared(BalanceCleared _, Emitter<OpeningBalanceState> emit) {
    emit(state.copyWith(balance: 0, suggestionValueSelected: 0));
  }

  Future<void> _onBalanceSubmitted(
    BalanceSubmitted _,
    Emitter<OpeningBalanceState> emit,
  ) async {
    emit(state.copyWith(submitStatus: ProcessStatus.loading));
    await Future.delayed(
      const Duration(
        seconds: 1,
      ),
      () {
        emit(state.copyWith(submitStatus: ProcessStatus.success));
      },
    );
  }
}
