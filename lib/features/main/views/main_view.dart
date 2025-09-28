import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dayfi/features/send/views/send_view.dart';
import 'package:dayfi/features/transactions/views/transactions_view.dart';
import 'package:dayfi/features/recipients/views/recipients_view.dart';
import 'package:dayfi/features/profile/views/profile_view.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MainView extends ConsumerStatefulWidget {
  const MainView({super.key});

  @override
  ConsumerState<MainView> createState() => _MainViewState();
}

class _MainViewState extends ConsumerState<MainView> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const SendView(),
    const TransactionsView(),
    const RecipientsView(),
    const ProfileView(),
  ];

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Disable device back button
      onPopInvoked: (didPop) {
        // Optional: Show a dialog or snackbar to inform user
        // For now, we'll just prevent the back action silently
      },
      child: Scaffold(
        extendBody: true, // 👈 makes nav bar float over body
        body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        margin: EdgeInsets.fromLTRB(48.w, 0, 48.w, 36.h), // float up a bit
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(100.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 0.w, vertical: 0.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                index: 0,
                icon: "assets/icons/svgs/Box.svg",
                isSelected: _currentIndex == 0,
              ),
              _buildNavItem(
                index: 1,
                icon: "assets/icons/svgs/Box.svg",
                isSelected: _currentIndex == 1,
              ),
              _buildNavItem(
                index: 2,
                icon: "assets/icons/svgs/Box.svg",
                isSelected: _currentIndex == 2,
              ),
              _buildNavItem(
                index: 3,
                icon: "assets/icons/svgs/Box.svg",
                isSelected: _currentIndex == 3,
              ),
            ],
          ),
        ),
      ),
    ));
  }

  Widget _buildNavItem({
    required int index,
    required String icon,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          // color: isSelected ? AppColors.purple500 : Colors.transparent,
          borderRadius: BorderRadius.circular(50.r),
        ),
        child: Opacity(
          opacity: isSelected ? 1 : 0.25,
          child: SvgPicture.asset(icon, height: 32.sp),
        ),
      ),
    );
  }
}
