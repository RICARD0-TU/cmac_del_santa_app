abstract interface class LocalDatabase {
  Future<void> initialize();
  Future<void> close();
}
