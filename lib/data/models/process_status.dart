enum ProcessStatus { initial, loading, success, failure }

extension ProcessStatusExt on ProcessStatus {
  bool get isLoading => this == ProcessStatus.loading;

  bool get isSuccess => this == ProcessStatus.success;

  bool get isFailure => this == ProcessStatus.failure;
}
