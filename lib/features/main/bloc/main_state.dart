part of 'main_bloc.dart';

class MainState extends Equatable {
  const MainState({
    this.currentTime,
  });

  final DateTime? currentTime;

  MainState copyWith({DateTime? currentTime}) {
    return MainState(currentTime: currentTime);
  }

  @override
  List<Object?> get props => [currentTime];
}
