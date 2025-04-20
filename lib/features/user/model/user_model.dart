import 'permission_model.dart';

class UserModel {
  final String id;
  final String nickname;
  final String email;
  final String avatar;
  final String? languageCode;
  final List<PermissionModel>? permissions;

  //<editor-fold desc="Data Methods">
  const UserModel({
    required this.id,
    required this.nickname,
    required this.email,
    required this.avatar,
    this.languageCode,
    this.permissions,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          (other is UserModel &&
              runtimeType == other.runtimeType &&
              id == other.id &&
              nickname == other.nickname &&
              email == other.email &&
              avatar == other.avatar &&
              languageCode == other.languageCode &&
              permissions == other.permissions);

  @override
  int get hashCode =>
      id.hashCode ^
      nickname.hashCode ^
      email.hashCode ^
      avatar.hashCode ^
      languageCode.hashCode ^
      permissions.hashCode;

  @override
  String toString() {
    return 'UserModel{' +
        ' id: $id,' +
        ' nickname: $nickname,' +
        ' email: $email,' +
        ' avatar: $avatar,' +
        ' languageCode: $languageCode,' +
        ' permissions: $permissions,' +
        '}';
  }

  UserModel copyWith({
    String? id,
    String? nickname,
    String? email,
    String? avatar,
    String? languageCode,
    List<PermissionModel>? permissions, // Change to PermissionModel
  }) {
    return UserModel(
      id: id ?? this.id,
      nickname: nickname ?? this.nickname,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      languageCode: languageCode ?? this.languageCode,
      permissions: permissions ?? this.permissions,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'nickname': this.nickname,
      'email': this.email,
      'avatar': this.avatar,
      'languageCode': this.languageCode,
      'permissions': this.permissions?.map((x) => x.toMap()).toList(), // Convert PermissionModel to Map
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      nickname: map['nickname'] as String,
      email: map['email'] as String,
      avatar: map['avatar'] as String,
      languageCode: map['languageCode'] as String?,
      permissions: map['permissions'] != null
          ? List<PermissionModel>.from(
          map['permissions'].map((x) => PermissionModel.fromMap(x)))
          : null,
    );
  }

//</editor-fold>
}
