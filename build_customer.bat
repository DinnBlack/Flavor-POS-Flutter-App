@echo off
rmdir /s /q build_customer
flutter clean
flutter build web --release --web-renderer canvaskit --dart-define=FLUTTER_WEB_USE_SKIA=true -t lib/main_customer.dart
rename "build\web" "build_customer"
copy "web\index_customer.html" "build_customer\index.html"

:: Tạo file _redirects
echo /*    /index.html   200 > build_customer\_redirects