import 'package:flutter/material.dart';

class CustomPopupMenu extends StatelessWidget {
  final List<Map<String, dynamic>> menuItems; // chứa text và callback
  final Offset position;

  const CustomPopupMenu({
    Key? key,
    required this.menuItems,
    required this.position,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (TapDownDetails details) {
        _showPopupMenu(context); // mở menu khi nhấn
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Text('Show Menu'),
      ),
    );
  }

  void _showPopupMenu(BuildContext context) {
    final items = menuItems.map<PopupMenuEntry<String>>((item) {
      return PopupMenuItem<String>(
        value: item['text'], // Dù không sử dụng value ở đây, bạn có thể loại bỏ nếu không cần thiết
        child: GestureDetector(
          onTap: () {
            item['callback'](); // gọi callback khi nhấn vào item
            Navigator.pop(context); // đóng menu sau khi chọn
          },
          child: Text(
            item['text'],
            style: const TextStyle(fontWeight: FontWeight.normal),
          ),
        ),
      );
    }).toList();

    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(position.dx, position.dy, position.dx, position.dy),
      items: items,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: Colors.grey.shade300,
          width: 1, // Độ dày của border
        ),
      ),
    );
  }
}
