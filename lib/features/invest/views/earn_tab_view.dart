import 'package:dayfi/common/constants/feature_intro_keys.dart';
import 'package:dayfi/common/views/feature_intro_view.dart';
import 'package:dayfi/features/dayearn/dayearn_entry.dart';
import 'package:dayfi/features/dayearn/views/dayearn_main_view.dart';
import 'package:dayfi/features/dayearn/dayearn_flow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

/// Bottom-tab root for DayEarn: intro until the user has a pot, then [DayEarnMainView].
class EarnTabView extends ConsumerStatefulWidget {
  const EarnTabView({super.key});

  @override
  ConsumerState<EarnTabView> createState() => EarnTabViewState();
}

class EarnTabViewState extends ConsumerState<EarnTabView> {
  bool _loading = true;
  bool _showIntro = true;

  @override
  void initState() {
    super.initState();
    _resolveContent();
  }

  Future<void> _resolveContent() async {
    setState(() => _loading = true);

    final showMain = await DayEarnEntry.shouldSkipIntro();

    if (!mounted) return;
    setState(() {
      _showIntro = !showMain;
      _loading = false;
    });
  }

  Future<void> _startDayEarnFlow() async {
    await DayEarnFlow.openCreate(context);
    if (!mounted) return;
    if (await DayEarnEntry.shouldSkipIntro()) {
      setState(() => _showIntro = false);
      _resolveContent();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Center(
          child: LoadingAnimationWidget.horizontalRotatingDots(
            color: Theme.of(context).colorScheme.primary,
            size: 24,
          ),
        ),
      );
    }

    if (_showIntro) {
      return FeatureIntroView(
        feature: DayfiHomeFeature.invest,
        onPrimary: _startDayEarnFlow,
        showLaterButton: false,
      );
    }

    return DayEarnMainView(
      showAsTab: true,
      onDataChanged: _resolveContent,
    );
  }
}
