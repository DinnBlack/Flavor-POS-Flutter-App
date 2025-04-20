import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/config/api_config.dart';
import '../../../core/utils/api_headers.dart';
import '../model/user_model.dart';
import '../model/permission_model.dart';

class UserService {
  final String baseUrl = "${ApiConfig.baseUrl}users";

  /// Lấy thông tin người dùng hiện tại (dựa vào access token)
  Future<UserModel> getProfile() async {
    final headers = await ApiHeaders.getHeaders();
    final response = await http.get(
      Uri.parse("$baseUrl/profile"),
      headers: headers,
    );
    print(response.body);
    print(response.statusCode);
    if (response.statusCode == 200) {
      return UserModel.fromMap(json.decode(response.body));
    } else {
      throw Exception("Failed to load profile");
    }
  }

  /// Lấy danh sách người dùng với phân trang và sắp xếp
  Future<List<UserModel>> getUsers({
    int page = 0,
    int size = 1000,
    String sort = "createdAt,ASC",
  }) async {
    final headers = await ApiHeaders.getHeaders();
    final response = await http.get(
      Uri.parse("$baseUrl?page=$page&size=$size&sort=$sort"),
      headers: headers,
    );
    if (response.statusCode == 200) {
    final data = json.decode(utf8.decode(response.bodyBytes));
    final List users = data['items'];

    return users.map((e) => UserModel.fromMap(e)).toList();
    } else {
    throw Exception("Failed to load users");
    }
  }

  /// Lấy thông tin một người dùng theo ID
  Future<UserModel> getUserById(String id) async {
    final headers = await ApiHeaders.getHeaders();
    final response = await http.get(
      Uri.parse("$baseUrl/$id"),
      headers: headers,
    );
    if (response.statusCode == 200) {
      return UserModel.fromMap(json.decode(response.body));
    } else {
      throw Exception("Failed to load user with id $id");
    }
  }

  /// Tạo người dùng mới
  Future<void> createUser(String email, String permissions) async {
    final headers = await ApiHeaders.getHeaders();
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        ...headers,
        "Content-Type": "application/json",
      },
      body: json.encode({
        "email": email,
        "permissions": permissions,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception("Failed to create user");
    }
  }

  /// Cập nhật thông tin một người dùng theo ID
  Future<void> updateUser(String id, String email,
      List<String> permissions) async {
    final headers = await ApiHeaders.getHeaders();
    final response = await http.put(
      Uri.parse("$baseUrl/$id"),
      headers: {
        ...headers,
        "Content-Type": "application/json",
      },
      body: json.encode({
        "email": email,
        "permissions": permissions,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception("Failed to update user");
    }
  }

  /// Cập nhật profile người dùng hiện tại (nickname, avatar, languageCode)
  Future<void> updateProfile({
    required String nickname,
    required String avatar,
    String? languageCode,
  }) async {
    final headers = await ApiHeaders.getHeaders();
    final response = await http.put(
      Uri.parse("$baseUrl/profile"),
      headers: {
        ...headers,
        "Content-Type": "application/json",
      },
      body: json.encode({
        "nickname": nickname,
        "avatar": avatar,
        "languageCode": languageCode,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception("Failed to update profile");
    }
  }

  /// Cập nhật mật khẩu người dùng hiện tại
  Future<void> updatePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    final headers = await ApiHeaders.getHeaders();
    final response = await http.put(
      Uri.parse("$baseUrl/password"),
      headers: {
        ...headers,
        "Content-Type": "application/json",
      },
      body: json.encode({
        "oldPassword": oldPassword,
        "newPassword": newPassword,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception("Failed to update password");
    }
  }

  /// Xóa người dùng theo ID
  Future<void> deleteUser(String id) async {
    final headers = await ApiHeaders.getHeaders();
    final response = await http.delete(
      Uri.parse("$baseUrl/$id"),
      headers: headers,
    );
    if (response.statusCode != 200) {
      throw Exception("Failed to delete user");
    }
  }

  /// Lấy danh sách tất cả permission có thể gán cho người dùng
  Future<List<PermissionModel>> getAvailablePermissions() async {
    final headers = await ApiHeaders.getHeaders();
    final response = await http.get(
      Uri.parse("$baseUrl/permissions"),
      headers: headers,
    );
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => PermissionModel.fromMap(e)).toList();
    } else {
      throw Exception("Failed to load permissions");
    }
  }
}
