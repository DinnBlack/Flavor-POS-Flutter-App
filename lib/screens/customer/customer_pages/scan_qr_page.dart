import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:go_router/go_router.dart';

class ScanQRPage extends StatefulWidget {
  const ScanQRPage({super.key});

  @override
  State<ScanQRPage> createState() => _ScanQRPageState();
}

class _ScanQRPageState extends State<ScanQRPage> {
  bool _isProcessing = false;

  void _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;
    _isProcessing = true;

    final barcode = capture.barcodes.firstWhere((b) => b.rawValue != null, orElse: () => Barcode(rawValue: null));
    final value = barcode.rawValue;

    if (value != null) {
      try {
        final uri = Uri.parse(value);
        if (uri.host == 'flavor-customer.netlify.app') {
          final tableId = uri.queryParameters['tableId'];
          if (tableId != null) {
            context.go('/?tableId=$tableId');
          } else {
            _showMessage('Không tìm thấy tableId trong mã QR.');
          }
        } else {
          _showMessage('Mã QR không hợp lệ với hệ thống.');
        }
      } catch (_) {
        _showMessage('Định dạng mã QR không hợp lệ.');
      }
    }

    _isProcessing = false;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quét mã QR')),
      body: MobileScanner(
        onDetect: _onDetect,
        errorBuilder: (context, error, child) {
          return Center(
            child: Text(
              'Không thể mở camera.\n${error.errorDetails?.message ?? ''}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
          );
        },
      ),
    );
  }
}
