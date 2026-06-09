import 'package:dayfi/core/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Shared app bar for Send, Add, Swap, Pay, Invest, Budget and related flows.
class DayfiScreenAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final bool showBackButton;
  final VoidCallback? onBack;
  final List<Widget>? actions;

  const DayfiScreenAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.showBackButton = true,
    this.onBack,
    this.actions,
  });

  @override
  Size get preferredSize =>
      Size.fromHeight(subtitle == null ? kToolbarHeight : 72);

  static Widget backButton(BuildContext context, {VoidCallback? onPressed}) {
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () {
        FocusScope.of(context).unfocus();
        if (onPressed != null) {
          onPressed();
        } else {
          Navigator.maybePop(context);
        }
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          SvgPicture.asset(
            'assets/icons/svgs/notificationn.svg',
            height: 40,
            color: Theme.of(context).colorScheme.surface,
          ),
          SizedBox(
            height: 40,
            width: 40,
            child: Center(
              child: Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(
                  Icons.arrow_back_ios,
                  color: Theme.of(context).textTheme.bodyLarge!.color,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      scrolledUnderElevation: .5,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      foregroundColor: Theme.of(context).scaffoldBackgroundColor,
      shadowColor: Theme.of(context).scaffoldBackgroundColor,
      surfaceTintColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
      leadingWidth: showBackButton ? 72 : 0,
      automaticallyImplyLeading: false,
      centerTitle: true,
      leading: showBackButton ? backButton(context, onPressed: onBack) : null,
      actions: actions,
      title: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: AppTypography.titleLarge.copyWith(
              fontFamily: 'FunnelDisplay',
              fontSize: subtitle == null ? 24 : 20,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          if (subtitle != null && subtitle!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: TextStyle(
                fontFamily: 'Chirp',
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface.withValues(
                  alpha: 0.55,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Dismisses keyboard when tapping outside fields.
class DayfiFeatureScaffold extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget body;
  final bool showBackButton;
  final VoidCallback? onBack;
  final Widget? bottomNavigationBar;
  final List<Widget>? actions;
  final bool resizeToAvoidBottomInset;

  const DayfiFeatureScaffold({
    super.key,
    required this.title,
    this.subtitle,
    required this.body,
    this.showBackButton = true,
    this.onBack,
    this.bottomNavigationBar,
    this.actions,
    this.resizeToAvoidBottomInset = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        appBar: DayfiScreenAppBar(
          title: title,
          subtitle: subtitle,
          showBackButton: showBackButton,
          onBack: onBack,
          actions: actions,
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
          child: body,
        ),

        bottomNavigationBar: bottomNavigationBar,
      ),
    );
  }
}
