mixin DisposeBagMixin {
  final List<void Function()> _disposeCallbacks = [];

  void registerDispose(void Function() callback) {
    _disposeCallbacks.add(callback);
  }

  void disposeBag() {
    for (final callback in _disposeCallbacks.reversed) {
      callback();
    }
    _disposeCallbacks.clear();
  }
}
