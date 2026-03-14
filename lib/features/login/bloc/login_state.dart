part of 'login_bloc.dart';

class LoginState extends Equatable {
  const LoginState({this.currentTime, this.pin = ''});

  final DateTime? currentTime;

  final String pin;

  LoginState copyWith({DateTime? currentTime, String? pin}) {
    return LoginState(
      currentTime: currentTime ?? this.currentTime,
      pin: pin ?? this.pin,
    );
  }

  @override
  List<Object?> get props => [currentTime, pin];
}
