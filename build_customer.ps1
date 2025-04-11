if (Test-Path -Path "build_customer") {
    Remove-Item -Path "build_customer" -Recurse -Force
}
flutter clean
flutter build web --release -t lib/main_customer.dart
Rename-Item -Path "build\web" -NewName "build_customer"

# Tạo file _redirects
Set-Content -Path "build\build_customer\_redirects" -Value "/*    /index.html   200"