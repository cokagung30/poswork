part of 'main_bloc.dart';

abstract class MainEvent extends Equatable {
  const MainEvent();

  @override
  List<Object?> get props => [];
}

class ClockUpdated extends MainEvent {
  const ClockUpdated(this.currenTime);

  final DateTime currenTime;

  @override
  List<Object?> get props => [currenTime];
}
