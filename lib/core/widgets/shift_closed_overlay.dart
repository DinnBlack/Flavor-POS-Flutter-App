import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:order_management_flutter_app/features/shift/bloc/shift_bloc.dart';
import 'package:order_management_flutter_app/features/shift/services/shift_service.dart';

import '../../features/user/model/user_model.dart';
import '../../features/user/services/user_service.dart';

class ShiftClosedOverlay extends StatefulWidget {
  const ShiftClosedOverlay({super.key});

  @override
  State<ShiftClosedOverlay> createState() => _ShiftClosedOverlayState();
}

class _ShiftClosedOverlayState extends State<ShiftClosedOverlay> {
  bool isShiftClosed = false;
  Timer? _timeUpdateTimer;
  String _time = '';
  late UserModel user;

  @override
  void initState() async {
    super.initState();
    _checkShiftStatus();
    _startTimer();
    user = await UserService().getProfile();
  }

  void _startTimer() {
    _updateTime();
    _timeUpdateTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) _updateTime();
    });
  }

  void _updateTime() {
    final now = DateTime.now();
    setState(() {
      _time = '${now.hour.toString().padLeft(2, '0')}:'
          '${now.minute.toString().padLeft(2, '0')}:'
          '${now.second.toString().padLeft(2, '0')}';
    });
  }

  Future<void> _checkShiftStatus() async {
    final shift = await ShiftService().getCurrentShift();
    setState(() {
      isShiftClosed = shift == null;
    });
  }

  Future<void> _startShift() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận mở ca'),
        content: const Text('Bạn có chắc chắn muốn mở ca trực mới không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      context.read<ShiftBloc>().add(ShiftStartStarted());
      await _checkShiftStatus();
    }
  }

  @override
  void dispose() {
    _timeUpdateTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!isShiftClosed) return const SizedBox.shrink();

    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.7),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/logo.png',
                height: 80,
              ),
              const SizedBox(
                height: 20,
              ),
              Text(
                'Đã đóng ca trực. Hiện tại là $_time',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                'Vui lòng mở ca để tiếp tục sử dụng hệ thống',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _startShift,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Mở ca trực'),
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 15,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
