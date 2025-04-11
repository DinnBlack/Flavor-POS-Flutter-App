@echo off
rmdir /s /q build_staff
flutter clean
flutter build web --release --web-renderer canvaskit --dart-define=FLUTTER_WEB_USE_SKIA=true -t lib/main_staff.dart
rename "build\web" "build_staff"
copy "web\index_staff.html" "build_staff\index.html" 