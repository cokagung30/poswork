part of 'login_bloc.dart';

class LoginState extends Equatable {
  const LoginState({this.currentTime});

  final DateTime? currentTime;

  LoginState copyWith({DateTime? currentTime}) {
    return LoginState(currentTime: currentTime);
  }

  @override
  List<Object?> get props => [currentTime];
}
