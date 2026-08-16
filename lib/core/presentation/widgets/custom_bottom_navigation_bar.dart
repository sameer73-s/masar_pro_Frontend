import 'package:flutter/material.dart';

import '../../../config/app_colors.dart';

/// Custom bottom nav with center FAB cutout spacing.
class CustomBottomNavigationBar extends StatelessWidget {
  const CustomBottomNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
    required this.onFabPressed,
  });

  final int selectedIndex;
  final ValueChanged<int> onItemTapped;
  final VoidCallback onFabPressed;

  /// rgba(95, 51, 225, 0.49)
  static const Color _fabShadow = Color(0x7D5F33E1);

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 56,
          color: AppColors.surfacePurple,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavIcon(
                icon: Icons.home_rounded,
                isSelected: selectedIndex == 0,
                onPressed: () => onItemTapped(0),
              ),
              _NavIcon(
                icon: Icons.calendar_today_rounded,
                isSelected: selectedIndex == 1,
                onPressed: () => onItemTapped(1),
              ),
              const SizedBox(width: 44),
              _NavIcon(
                icon: Icons.description_outlined,
                isSelected: selectedIndex == 2,
                onPressed: () => onItemTapped(2),
              ),
              _NavIcon(
                icon: Icons.person_outline_rounded,
                isSelected: selectedIndex == 3,
                onPressed: () => onItemTapped(3),
              ),
            ],
          ),
        ),
        Positioned(
          top: -22,
          left: 0,
          right: 0,
          child: Center(
            child: GestureDetector(
              onTap: onFabPressed,
              child: Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: AppColors.accentPurple,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _fabShadow,
                      offset: Offset(2, 10),
                      blurRadius: 18,
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _NavIcon extends StatelessWidget {
  const _NavIcon({
    required this.icon,
    required this.isSelected,
    required this.onPressed,
  });

  final IconData icon;
  final bool isSelected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final color = isSelected
        ? AppColors.accentPurple
        : AppColors.accentPurple.withValues(alpha: 0.35);

    return IconButton(
      onPressed: onPressed,
      icon: Icon(
        icon,
        color: color,
        size: 24,
        shadows: isSelected
            ? [
                Shadow(
                  color: AppColors.accentPurple.withValues(alpha: 0.35),
                  blurRadius: 8,
                ),
              ]
            : null,
      ),
    );
  }
}
