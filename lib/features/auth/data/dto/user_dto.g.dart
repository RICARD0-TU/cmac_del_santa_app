// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserDto _$UserDtoFromJson(Map<String, dynamic> json) => _UserDto(
  id: json['id'] as String,
  email: json['email'] as String,
  fullName: json['fullName'] as String,
  dni: json['dni'] as String,
  phone: json['phone'] as String,
  photoUrl: json['photoUrl'] as String?,
);

Map<String, dynamic> _$UserDtoToJson(_UserDto instance) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'fullName': instance.fullName,
  'dni': instance.dni,
  'phone': instance.phone,
  'photoUrl': instance.photoUrl,
};
