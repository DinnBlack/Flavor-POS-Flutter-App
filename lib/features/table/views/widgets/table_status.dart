import 'package:flutter/material.dart';

class TableStatus extends StatelessWidget {
  const TableStatus({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Chữ "Table Status" bên trái
          Text(
            "Trạng thái bàn:",
            style: TextStyle(
              fontSize: 14,
            ),
          ),
          // Các item trạng thái nằm gần nhau
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatusRow("Có sẵn", Colors.grey),
              const SizedBox(width: 10),
              _buildStatusRow("Đang hoạt động", Theme.of(context).primaryColor),
              const SizedBox(width: 10),
              _buildStatusRow("Đóng", Colors.red),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String statusText, Color statusColor) {
    return Row(
      children: [
        CircleAvatar(
          radius: 8,
          backgroundColor: statusColor,
        ),
        const SizedBox(width: 10),
        Text(
          statusText,
          style: TextStyle(
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
