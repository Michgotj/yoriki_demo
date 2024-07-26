class ControllerResult<R, E> {
  final R? result;
  final E? error;

  ControllerResult({this.result, this.error});

  bool get isError => error != null;
}
