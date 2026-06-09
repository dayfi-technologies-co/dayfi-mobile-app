import 'dart:async';

import 'package:dayfi/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Center nav orb — tap opens chat; press-and-hold opens voice (release sends utterance).
class DayxOrbButton extends StatefulWidget {
  final VoidCallback onTap;
  final VoidCallback? onHoldStart;
  final VoidCallback? onHoldEnd;

  const DayxOrbButton({
    super.key,
    required this.onTap,
    this.onHoldStart,
    this.onHoldEnd,
  });

  @override
  State<DayxOrbButton> createState() => _DayxOrbButtonState();
}

class _DayxOrbButtonState extends State<DayxOrbButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  Timer? _holdTimer;
  final bool _holdActivated = false;

  static const _holdDelay = Duration(milliseconds: 420);

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _holdTimer?.cancel();
    _pulse.dispose();
    super.dispose();
  }

  // void _onPointerDown(PointerDownEvent _) {
  //   _holdTimer?.cancel();
  //   _holdActivated = false;
  //   _holdTimer = Timer(_holdDelay, () {
  //     if (!mounted) return;
  //     _holdActivated = true;
  //     HapticFeedback.mediumImpact();
  //     widget.onHoldStart?.call();
  //   });
  // }

  void _onPointerUp(PointerUpEvent _) {
    _holdTimer?.cancel();
    // if (_holdActivated) {
    //   widget.onHoldEnd?.call();
    //   _holdActivated = false;
    //   return;
    // }
    HapticFeedback.selectionClick();
    widget.onTap();
  }

  // void _onPointerCancel(PointerCancelEvent _) {
  //   _holdTimer?.cancel();
  //   if (_holdActivated) {
  //     widget.onHoldEnd?.call();
  //   }
  //   _holdActivated = false;
  // }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'DayX AI assistant',
      // hint: 'Tap for chat. Press and hold for voice.',
      child: Listener(
        // onPointerDown: _onPointerDown,
        onPointerUp: _onPointerUp,
        // onPointerCancel: _onPointerCancel,
        child: AnimatedBuilder(
          animation: _pulse,
          builder: (context, child) {
            final scale = 1.0 + (_pulse.value * 0.05);
            return Transform.scale(
              scale: scale,
              child: Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primary400, AppColors.orange500],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary400.withValues(alpha: 0.2),
                      blurRadius: 1,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: child,
              ),
            );
          },
          child: const Center(
            child: Text(
              'X',
              style: TextStyle(
                fontFamily: 'FunnelDisplay',
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                height: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
