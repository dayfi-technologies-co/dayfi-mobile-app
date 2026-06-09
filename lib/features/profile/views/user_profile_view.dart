import 'package:dayfi/common/widgets/dayfi_screen_app_bar.dart';
import 'package:dayfi/features/profile/widgets/profile_account_settings.dart';
import 'package:dayfi/features/profile/widgets/profile_header_section.dart';
import 'package:dayfi/features/profile/widgets/profile_settings_style.dart';
import 'package:dayfi/features/profile/widgets/profile_upgrade_card.dart';
import 'package:flutter/material.dart';

class UserProfileView extends StatelessWidget {
  const UserProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const DayfiScreenAppBar(title: 'Profile'),
      body: const SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ProfileHeaderSection(),
            SizedBox(height: 8),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: ProfileSettingsStyle.contentPadding,
              ),
              child: ProfileUpgradeCard(),
            ),
            SizedBox(height: 16),
            ProfileAccountSettings(),
          ],
        ),
      ),
    );
  }
}
