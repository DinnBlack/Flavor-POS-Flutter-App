import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:order_management_flutter_app/features/table/model/table_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';

import '../../../core/widgets/custom_toast.dart';

class QRCodeGenerator extends StatefulWidget {
  final TableModel table;

  const QRCodeGenerator({super.key, required this.table});

  @override
  State<QRCodeGenerator> createState() => _QRCodeGeneratorState();
}

class _QRCodeGeneratorState extends State<QRCodeGenerator> {
  int _selectedTabIndex = 0;
  int _selectedBackgroundIndex = 0;
  int _selectedQRColorIndex = 0;
  final ScreenshotController _screenshotController = ScreenshotController();
  final GlobalKey _qrKey = GlobalKey();

  Future<void> _saveQRCode() async {
    try {
      final PermissionState ps = await PhotoManager.requestPermissionExtend();

      if (!ps.hasAccess) {
        print('Không thể truy cập thư viện ảnh');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Ứng dụng cần quyền truy cập thư viện ảnh để lưu mã QR.')),
        );
        return;
      }

      // Chụp widget QR code thành ảnh
      RenderRepaintBoundary boundary =
          _qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage();
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List uint8List = byteData!.buffer.asUint8List();

      // Lưu ảnh tạm
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/qr_code.png';
      final file = File(filePath);
      await file.writeAsBytes(uint8List);

      // Lưu ảnh vào thư viện ảnh
      final asset = await PhotoManager.editor.saveImage(
        file.readAsBytesSync(),
        title: 'qr_code.png',
        filename: 'qr_code.png',
      );

      if (asset != null) {
        Navigator.pop(context);
        CustomToast.showToast(context, "Đã lưu mã QR vào thư viện ảnh!",
            type: ContentType.success);
      } else {
        print('Không thể lưu ảnh vào thư viện ảnh');
      }
    } catch (e) {
      print("Lỗi khi lưu ảnh: $e");
    }
  }

  final List<Map<String, dynamic>> _restaurantThemes = [
    {
      'name': 'Sang trọng',
      'image':
          'https://images.unsplash.com/photo-1593270797842-4b8e6cecd2b2?crop=faces&fit=crop&w=800&h=800',
      'background':
          'https://images.unsplash.com/photo-1593270797842-4b8e6cecd2b2',
    },
    {
      'name': 'Truyền thống',
      'image':
          'https://images.unsplash.com/photo-1616689314353-046ee6021f56?crop=faces&fit=crop&w=800&h=800',
      'background':
          'https://images.unsplash.com/photo-1616689314353-046ee6021f56',
    },
    {
      'name': 'Da dạng',
      'image':
          'https://images.unsplash.com/photo-1576325782051-6ccdcaf096a6?crop=faces&fit=crop&w=800&h=800',
      'background':
          'https://images.unsplash.com/photo-1576325782051-6ccdcaf096a6',
    },
    {
      'name': 'Hiện đại',
      'image':
          'https://images.unsplash.com/photo-1627955280978-f54fff2f316a?crop=faces&fit=crop&w=800&h=800',
      'background':
          'https://images.unsplash.com/photo-1627955280978-f54fff2f316a',
    },
    {
      'name': 'Gia đình',
      'image':
          'https://images.unsplash.com/photo-1601467573241-01a8da2dda96?crop=faces&fit=crop&w=800&h=800',
      'background':
          'https://images.unsplash.com/photo-1601467573241-01a8da2dda96',
    },
  ];

  final List<Color> _qrColors = [
    Colors.black,
    Colors.red,
    Colors.brown,
    Colors.amber,
    Colors.green,
    Colors.teal,
    Colors.blue,
    Colors.purple,
    Colors.pink,
    Colors.indigo,
    Colors.cyan,
    Colors.lightGreen,
    Colors.brown.shade800,
    Colors.deepOrange,
    Colors.red.shade900,
  ];

  Widget _buildQRCodeDisplay() {
    final selectedBackground = _restaurantThemes[_selectedBackgroundIndex];
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
        image: DecorationImage(
          image: NetworkImage(selectedBackground['background']),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.3),
            BlendMode.darken,
          ),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Chào mừng đến nhà hàng Flavor!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Quét mã để order món ăn tại bàn ${widget.table.number}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.normal,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(10),
            ),
            child: QrImageView(
              data:
                  'https://flavor-customer.netlify.app/#/selection/${widget.table.number}',
              version: QrVersions.auto,
              size: 200.0,
              eyeStyle: QrEyeStyle(
                eyeShape: QrEyeShape.circle,
                color: _qrColors[_selectedQRColorIndex],
              ),
              dataModuleStyle: QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square,
                color: _qrColors[_selectedQRColorIndex],
              ),
              embeddedImage:
                  const NetworkImage('https://i.imgur.com/YourLogo.png'),
              embeddedImageStyle: const QrEmbeddedImageStyle(
                size: Size(40, 40),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Screenshot(
                    controller: _screenshotController,
                    child: RepaintBoundary(
                      key: _qrKey,
                      child: _buildQRCodeDisplay(),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Bottom Sheet
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Tab buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildTabButton('Chủ đề', 0),
                      _buildTabButton('Màu QR', 1),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Content based on selected tab
                  SizedBox(
                    height: 100,
                    child: _selectedTabIndex == 0
                        ? _buildZodiacThemes()
                        : _buildColorPicker(),
                  ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.all(10),
          decoration: const BoxDecoration(
            color: Colors.transparent,
          ),
          child: SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _selectedTabIndex = 0;
                        _selectedBackgroundIndex = 0;
                        _selectedQRColorIndex = 0;
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      side: BorderSide(color: colors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      'Quay lại',
                      style: TextStyle(color: colors.primary),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: _saveQRCode,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      backgroundColor: colors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text('Tải Mã Bàn'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabButton(String title, int index) {
    final colors = Theme.of(context).colorScheme;
    final isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTabIndex = index),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              color: isSelected ? colors.primary : Colors.grey,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: 40,
            height: 2,
            color: isSelected ? colors.primary : Colors.transparent,
          ),
        ],
      ),
    );
  }

  Widget _buildZodiacThemes() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      scrollDirection: Axis.horizontal,
      itemCount: _restaurantThemes.length,
      itemBuilder: (context, index) {
        final theme = _restaurantThemes[index];
        final isSelected = _selectedBackgroundIndex == index;

        return GestureDetector(
          onTap: () => setState(() => _selectedBackgroundIndex = index),
          child: Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    border: Border.all(width: 1, color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      height: 70,
                      width: 70,
                      theme['image'],
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 32,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  theme['name'],
                  style: TextStyle(
                    fontSize: 12,
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey[600],
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildColorPicker() {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      itemCount: _qrColors.length,
      itemBuilder: (context, index) {
        final color = _qrColors[index];
        final isSelected = _selectedQRColorIndex == index;
        return GestureDetector(
          onTap: () {
            if (index >= 0 && index < _qrColors.length) {
              setState(() => _selectedQRColorIndex = index);
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? Colors.blue : Colors.transparent,
                width: 2,
              ),
            ),
            child: isSelected
                ? const Icon(
                    Icons.check,
                    color: Colors.white,
                  )
                : null,
          ),
        );
      },
    );
  }
}
