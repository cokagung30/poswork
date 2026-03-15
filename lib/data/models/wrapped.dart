import 'package:equatable/equatable.dart';

class Wrapped<T> extends Equatable {
  const Wrapped.value(this.value);

  final T value;

  @override
  List<Object?> get props => [value];
}

extension WrappedExt<T> on Wrapped<T>? {
  T? wrap(T? value) {
    return this != null ? this!.value : value;
  }
}
