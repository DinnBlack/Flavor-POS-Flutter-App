import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../features/order/views/active_order.dart';
import '../../../../features/shift/bloc/shift_bloc.dart';
import '../../../../features/shift/model/shift_model.dart';
import '../../../../features/shift/services/shift_service.dart';
import 'widgets/activity_header.dart';

class OrderScreen extends StatefulWidget {
  final bool? isWaiter;

  const OrderScreen({super.key, this.isWaiter = false});

  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  late ShiftModel? shift;
  bool isShiftClosed = false;
  Timer? _timeUpdateTimer;
  bool _isTimerInitialized = false;

  @override
  void initState() {
    super.initState();
    _loadShift();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isTimerInitialized) {
      _startTimer();
      _isTimerInitialized = true;
    }
  }

  @override
  void dispose() {
    _timeUpdateTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadShift() async {
    shift = await ShiftService().getCurrentShift();
    if (mounted) {
      setState(() {
        isShiftClosed = shift == null;
      });
    }
  }

  void _startTimer() {
    _timeUpdateTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  String _formattedTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:'
        '${now.minute.toString().padLeft(2, '0')}:'
        '${now.second.toString().padLeft(2, '0')}';
  }

  void _startShift() async {
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
      _loadShift();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ShiftBloc, ShiftState>(
      listener: (context, state) {
        if (state is ShiftStartSuccess || state is ShiftEndSuccess) {
          _loadShift();
        }
      },
      child: SafeArea(
        child: Stack(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: Column(
                    children: [
                      if (!(widget.isWaiter ?? false))
                        const ActivityHeader(
                          title: 'Đơn hàng',
                        ),
                      const Expanded(
                        child: ActiveOrder(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (isShiftClosed)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.7),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/images/off_shift.jpg',
                          height: 300,
                          width: 300,
                        ),
                        Text(
                          'Đã đóng ca trực.\nHiện tại là ${_formattedTime()}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
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
              ),
          ],
        ),
      ),
    );
  }
}
