import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

/// プレイヤーアバター
class PlayerAvatar extends StatelessWidget {
  const PlayerAvatar({
    super.key,
    required this.name,
    this.isWolf = false,
    this.size = 48,
  });

  final String name;
  final bool isWolf;
  final double size;

  @override
  Widget build(BuildContext context) {
    final color = isWolf ? AppColors.wolfColor : AppColors.citizenColor;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0] : '?',
          style: AppTextStyles.headlineMedium.copyWith(
            color: Colors.white,
            fontSize: size * 0.4,
          ),
        ),
      ),
    );
  }
}
