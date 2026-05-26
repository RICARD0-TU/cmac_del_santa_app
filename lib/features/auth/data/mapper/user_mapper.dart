import '../../domain/entities/user_entity.dart';
import '../dto/user_dto.dart';

extension UserMapper on UserDto {
  UserEntity toEntity() {
    return UserEntity(
      id: id,
      email: email,
      fullName: fullName,
      dni: dni,
      phone: phone,
      photoUrl: photoUrl,
    );
  }
}
