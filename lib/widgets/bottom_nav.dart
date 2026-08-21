import 'package:flutter/material.dart';

import '../core/routes.dart';
import '../core/theme.dart';

class BottomNav extends StatelessWidget {
  final int selectedIndex;

  const BottomNav({
    super.key,
    required this.selectedIndex,
  });

  // ================================================================
  // NAVIGATION
  // ================================================================

  void _navigate(
      BuildContext context,
      int index,
      ) {
    if (index == selectedIndex) {
      return;
    }

    switch (index) {
      case 0:
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.dashboard,
              (route) => false,
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

  // ================================================================
  // BUILD
  // ================================================================

  @override
  Widget build(BuildContext context) {
    /*
     * IMPORTANT:
     *
     * Previously the navigation had:
     *
     *   Container(height: 82)
     *       -> SafeArea
     *
     * This caused SafeArea's bottom padding to reduce the available
     * height inside the 82px container.
     *
     * The New Bill button then became taller than the available
     * space and Flutter showed:
     *
     *   BOTTOM OVERFLOWED BY 10.0 PIXELS
     *
     * Now SafeArea is OUTSIDE the fixed navigation content height.
     * Therefore the phone's system bottom inset is added instead
     * of taking space away from the navigation items.
     */

    return Material(
      color: Colors.white,

      child: SafeArea(
        top: false,

        child: Container(
          height: 72,

          decoration: BoxDecoration(
            color: Colors.white,

            border: const Border(
              top: BorderSide(
                color: StackFlowColors.border,
              ),
            ),

            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: 0.05,
                ),
                blurRadius: 15,
                offset: const Offset(0, -3),
              ),
            ],
          ),

          child: Row(
            children: [
              // ======================================================
              // HOME
              // ======================================================

              Expanded(
                child: _NavItem(
                  icon: Icons.home_outlined,
                  selectedIcon: Icons.home_rounded,
                  label: 'Home',
                  selected: selectedIndex == 0,
                  onTap: () => _navigate(
                    context,
                    0,
                  ),
                ),
              ),

              // ======================================================
              // PRODUCTS
              // ======================================================

              Expanded(
                child: _NavItem(
                  icon: Icons.inventory_2_outlined,
                  selectedIcon: Icons.inventory_2_rounded,
                  label: 'Products',
                  selected: selectedIndex == 1,
                  onTap: () => _navigate(
                    context,
                    1,
                  ),
                ),
              ),

              // ======================================================
              // NEW BILL
              // ======================================================

              Expanded(
                child: _NewBillButton(
                  selected: selectedIndex == 2,
                  onTap: () => _navigate(
                    context,
                    2,
                  ),
                ),
              ),

              // ======================================================
              // SALES
              // ======================================================

              Expanded(
                child: _NavItem(
                  icon: Icons.receipt_long_outlined,
                  selectedIcon: Icons.receipt_long_rounded,
                  label: 'Sales',
                  selected: selectedIndex == 3,
                  onTap: () => _navigate(
                    context,
                    3,
                  ),
                ),
              ),

              // ======================================================
              // MORE
              // ======================================================

              Expanded(
                child: _NavItem(
                  icon: Icons.more_horiz_rounded,
                  selectedIcon: Icons.more_horiz_rounded,
                  label: 'More',
                  selected: selectedIndex == 4,
                  onTap: () => _navigate(
                    context,
                    4,
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

// ==================================================================
// NORMAL NAVIGATION ITEM
// ==================================================================

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
    final Color color = selected
        ? StackFlowColors.primary
        : StackFlowColors.secondaryText;

    return Material(
      color: Colors.transparent,

      child: InkWell(
        onTap: onTap,

        child: SizedBox(
          height: 72,

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,

            children: [
              // ======================================================
              // ICON CONTAINER
              // ======================================================

              AnimatedContainer(
                duration: const Duration(
                  milliseconds: 180,
                ),

                width: selected ? 46 : 42,
                height: 30,

                decoration: BoxDecoration(
                  color: selected
                      ? StackFlowColors.primary.withValues(
                    alpha: 0.10,
                  )
                      : Colors.transparent,

                  borderRadius: BorderRadius.circular(12),
                ),

                child: Icon(
                  selected
                      ? selectedIcon
                      : icon,

                  size: 21,
                  color: color,
                ),
              ),

              const SizedBox(height: 2),

              // ======================================================
              // LABEL
              // ======================================================

              Text(
                label,

                maxLines: 1,
                overflow: TextOverflow.ellipsis,

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
      ),
    );
  }
}

// ==================================================================
// NEW BILL BUTTON
// ==================================================================

class _NewBillButton extends StatelessWidget {
  final bool selected;
  final VoidCallback onTap;

  const _NewBillButton({
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,

      child: InkWell(
        onTap: onTap,

        borderRadius: BorderRadius.circular(18),

        child: SizedBox(
          height: 72,

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,

            children: [
              // ======================================================
              // FLOATING BUTTON
              // ======================================================

              AnimatedContainer(
                duration: const Duration(
                  milliseconds: 180,
                ),

                width: 48,
                height: 48,

                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      StackFlowColors.primary,
                      StackFlowColors.primaryDark,
                    ],

                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),

                  borderRadius: BorderRadius.circular(16),

                  boxShadow: [
                    BoxShadow(
                      color: StackFlowColors.primary.withValues(
                        alpha: 0.25,
                      ),

                      blurRadius: 10,

                      offset: const Offset(
                        0,
                        4,
                      ),
                    ),
                  ],
                ),

                child: const Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                  size: 29,
                ),
              ),

              const SizedBox(height: 1),

              // ======================================================
              // LABEL
              // ======================================================

              Text(
                'New Bill',

                maxLines: 1,

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
      ),
    );
  }
}