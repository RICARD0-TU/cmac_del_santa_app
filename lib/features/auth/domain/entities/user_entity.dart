class UserEntity {
  const UserEntity({
    required this.id,
    required this.email,
    required this.fullName,
    required this.dni,
    required this.phone,
    this.photoUrl,
  });

  final String id;
  final String email;
  final String fullName;
  final String dni;
  final String phone;
  final String? photoUrl;
}
