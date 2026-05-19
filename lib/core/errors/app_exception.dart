class AppException implements Exception {
  const AppException(this.message, {this.code, this.stackTrace});

  final String message;
  final String? code;
  final StackTrace? stackTrace;

  @override
  String toString() {
    final suffix = code == null ? '' : ' ($code)';
    return 'AppException$suffix: $message';
  }
}
