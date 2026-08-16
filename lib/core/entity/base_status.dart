enum PageStatus { initial, loading, success, error }

extension PageStatusExtension on PageStatus {
  bool get isInitial => this == PageStatus.initial;
  bool get isLoading => this == PageStatus.loading;
  bool get isSuccess => this == PageStatus.success;
  bool get isError => this == PageStatus.error;
}
