import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:flutter/foundation.dart';
// import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'auth_config.dart';

class AuthService {
  Credentials? _credentials;
  late dynamic auth0;
  String? _accessToken;

  AuthService() {
    if (kIsWeb) {
      // auth0 = Auth0Web(
      //   'vinpos.jp.auth0.com',
      //   'eGkiBlm1hAkq43bz7xQ7wIDL2ZW6Rsyt',
      // );
    } else {
      auth0 = Auth0(
        'vinpos.jp.auth0.com',
        'eGkiBlm1hAkq43bz7xQ7wIDL2ZW6Rsyt',
      );
    }
  }

  // Đăng nhập
  Future<void> login() async {
    try {
      if (kIsWeb) {
        // final url = Uri.parse(
        //   'https://vinpos.jp.auth0.com/authorize?response_type=token&client_id=eGkiBlm1hAkq43bz7xQ7wIDL2ZW6Rsyt&redirect_uri=http://localhost:1803/callback',
        // );

        // final result = await FlutterWebAuth.authenticate(
        //   url: url.toString(),
        //   callbackUrlScheme: 'http',
        // );

        // final uri = Uri.parse(result);
        // final accessToken = uri.fragment
        //     .split('&')
        //     .firstWhere((e) => e.startsWith('access_token='), orElse: () => ' ')
        //     .split('=')[1];

        // _accessToken = accessToken;
        // await AuthConfig.saveToken(_accessToken!);
      } else {
        _credentials = await auth0.webAuthentication().login(
              audience: "http://localhost:8080",
              redirectUrl:
                  "demo://vinpos.jp.auth0.com/android/com.example.order_management_app/callback",
            );

        // Tính thời gian hết hạn (1 ngày sau khi đăng nhập)
        final expiresAt = DateTime.now().add(const Duration(days: 1));
        await AuthConfig.saveToken(_credentials!.accessToken, expiresAt);
      }
    } catch (e) {
      throw Exception('Lỗi khi đăng nhập: $e');
    }
  }

  // Đăng xuất
  Future<void> logout() async {
    try {
      if (kIsWeb) {
        // await auth0.logout(
        //   returnTo: "https://vinpos.jp.auth0.com/",
        //   useHTTPS: true,
        // );
      } else {
        await auth0.webAuthentication().logout(
              returnTo:
                  "demo://vinpos.jp.auth0.com/android/com.example.order_management_app/logout",
              useHTTPS: true,
            );
      }
      await AuthConfig.clearToken();
    } catch (e) {
      throw Exception('Lỗi khi đăng xuất: $e');
    }
  }

  // Lấy thông tin người dùng
  Credentials? get credentials => _credentials;

  String? get accessToken => _accessToken;
}
