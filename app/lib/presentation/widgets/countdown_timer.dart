import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

/// カウントダウンタイマー
class CountdownTimer extends StatefulWidget {
  const CountdownTimer({
    super.key,
    required this.duration,
    required this.onComplete,
    this.showControls = true,
  });

  final Duration duration;
  final VoidCallback onComplete;
  final bool showControls;

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  late Duration _remaining;
  Timer? _timer;
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    _remaining = widget.duration;
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remaining.inSeconds > 0) {
          _remaining = Duration(seconds: _remaining.inSeconds - 1);
        } else {
          _timer?.cancel();
          widget.onComplete();
        }
      });
    });
  }

  void _togglePause() {
    setState(() {
      if (_isPaused) {
        _startTimer();
      } else {
        _timer?.cancel();
      }
      _isPaused = !_isPaused;
    });
  }

  void _reset() {
    setState(() {
      _timer?.cancel();
      _remaining = widget.duration;
      _isPaused = false;
      _startTimer();
    });
  }

  @override
  Widget build(BuildContext context) {
    final minutes = _remaining.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = _remaining.inSeconds.remainder(60).toString().padLeft(2, '0');
    final progress = _remaining.inSeconds / widget.duration.inSeconds;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 120,
              height: 120,
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: 8,
                backgroundColor: AppColors.surfaceLight,
                valueColor: AlwaysStoppedAnimation<Color>(
                  _remaining.inSeconds <= 10
                      ? AppColors.error
                      : AppColors.primary,
                ),
              ),
            ),
            Text(
              '$minutes:$seconds',
              style: AppTextStyles.displayMedium.copyWith(
                color: _remaining.inSeconds <= 10
                    ? AppColors.error
                    : AppColors.textPrimaryLight,
              ),
            ),
          ],
        ),
        if (widget.showControls) ...[
          const SizedBox(height: 24),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(_isPaused ? Icons.play_arrow : Icons.pause),
                onPressed: _togglePause,
                iconSize: 32,
                color: AppColors.primary,
              ),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _reset,
                iconSize: 32,
                color: AppColors.primary,
              ),
            ],
          ),
        ],
      ],
    );
  }
}
