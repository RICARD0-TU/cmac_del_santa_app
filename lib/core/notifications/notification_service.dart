abstract interface class NotificationService {
  Future<void> initialize();
  Future<void> requestPermissions();
}
