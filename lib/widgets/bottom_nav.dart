import 'package:flutter/material.dart';

import '../core/routes.dart';
import '../core/theme.dart';

class BottomNav extends StatelessWidget {
  final int selectedIndex;

  const BottomNav({
    super.key,
    required this.selectedIndex,
  });

  void _navigate(
      BuildContext context,
      int index,
      ) {
    if (index == selectedIndex) {
      return;
    }

    switch (index) {
      case 0:
        Navigator.pushNamed(
          context,
          AppRoutes.dashboard,
        );
        break;

      case 1:
        Navigator.pushNamed(
          context,
          AppRoutes.products,
        );
        break;

      case 2:
        Navigator.pushNamed(
          context,
          AppRoutes.bill,
        );
        break;

      case 3:
        Navigator.pushNamed(
          context,
          AppRoutes.invoices,
        );
        break;

      case 4:
        Navigator.pushNamed(
          context,
          AppRoutes.settings,
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 82,
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          top: BorderSide(
            color: StackFlowColors.border,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: _NavItem(
                icon: Icons.home_outlined,
                selectedIcon: Icons.home_rounded,
                label: 'Home',
                selected: selectedIndex == 0,
                onTap: () => _navigate(context, 0),
              ),
            ),

            Expanded(
              child: _NavItem(
                icon: Icons.inventory_2_outlined,
                selectedIcon: Icons.inventory_2_rounded,
                label: 'Products',
                selected: selectedIndex == 1,
                onTap: () => _navigate(context, 1),
              ),
            ),

            Expanded(
              child: _NewBillButton(
                selected: selectedIndex == 2,
                onTap: () => _navigate(context, 2),
              ),
            ),

            Expanded(
              child: _NavItem(
                icon: Icons.receipt_long_outlined,
                selectedIcon: Icons.receipt_long_rounded,
                label: 'Sales',
                selected: selectedIndex == 3,
                onTap: () => _navigate(context, 3),
              ),
            ),

            Expanded(
              child: _NavItem(
                icon: Icons.more_horiz_rounded,
                selectedIcon: Icons.more_horiz_rounded,
                label: 'More',
                selected: selectedIndex == 4,
                onTap: () => _navigate(context, 4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? StackFlowColors.primary
        : StackFlowColors.secondaryText;

    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: selected ? 46 : 42,
              height: 30,
              decoration: BoxDecoration(
                color: selected
                    ? StackFlowColors.primary.withValues(alpha: 0.10)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                selected ? selectedIcon : icon,
                size: 21,
                color: color,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: selected
                    ? FontWeight.w600
                    : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NewBillButton extends StatelessWidget {
  final bool selected;
  final VoidCallback onTap;

  const _NewBillButton({
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: SizedBox(
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    StackFlowColors.primary,
                    StackFlowColors.primaryDark,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(17),
                boxShadow: [
                  BoxShadow(
                    color: StackFlowColors.primary.withValues(
                      alpha: 0.25,
                    ),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.add_rounded,
                color: Colors.white,
                size: 30,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              'New Bill',
              style: TextStyle(
                fontSize: 10,
                fontWeight: selected
                    ? FontWeight.bold
                    : FontWeight.w600,
                color: StackFlowColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}