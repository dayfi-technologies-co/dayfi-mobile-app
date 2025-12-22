import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/core/theme/app_typography.dart';
import 'package:dayfi/gen/assets.gen.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class _LoadingModalWidget extends StatefulWidget {
  final String title;

  final double? progress;

  final Stream<double>? progressStream;

  final bool isComplete;

  final VoidCallback? onDismissed;

  final VoidCallback? onComplete;

  final Duration successDuration;

  final Color spinnerColor;

  final Color successColor;

  final Color titleColor;

  final Color progressColor;

  final double spinnerSize;

  final double successIconSize;

  final IconData? successIcon;

  final Widget? customSpinner;

  final bool showDragHandle;

  final String? completionSubtitle;

  final String? completedTitle;

  final bool isSuccess;

  final bool showProgressText;

  const _LoadingModalWidget({
    required this.title,
    this.progress,
    this.progressStream,
    this.isComplete = false,
    this.onDismissed,
    this.onComplete,
    this.successDuration = const Duration(seconds: 2),
    this.spinnerColor = AppColors.neutral500,
    this.successColor = AppColors.success500,
    this.titleColor = AppColors.neutral900,
    this.progressColor = AppColors.neutral600,
    this.spinnerSize = 20.0,
    this.successIconSize = 20.0,
    this.successIcon,
    this.customSpinner,
    this.showDragHandle = true,
    this.completionSubtitle,
    this.completedTitle,
    this.isSuccess = true,
    this.showProgressText = true,
  });

  @override
  State<_LoadingModalWidget> createState() => _LoadingModalState();
}

class _LoadingModalState extends State<_LoadingModalWidget>
    with TickerProviderStateMixin {
  late AnimationController _spinnerController;
  late AnimationController _successController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  StreamSubscription<double>? _progressSubscription;
  double _currentProgress = 0.0;
  bool _isSuccessState = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _setupProgressListener();
  }

  void _initializeAnimations() {
    _spinnerController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _successController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _successController, curve: Curves.elasticOut),
    );

    _spinnerController.repeat();
  }

  void _setupProgressListener() {
    if (widget.progressStream != null) {
      _progressSubscription = widget.progressStream!.listen((progress) {
        if (mounted) {
          setState(() {
            _currentProgress = progress.clamp(0.0, 1.0);
          });
        }
      });
    } else if (widget.progress != null) {
      _currentProgress = widget.progress!.clamp(0.0, 1.0);
    }
  }

  @override
  void didUpdateWidget(_LoadingModalWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isComplete && !oldWidget.isComplete) {
      _handleCompletion();
    }

    if (widget.progress != oldWidget.progress && widget.progress != null) {
      setState(() {
        _currentProgress = widget.progress!.clamp(0.0, 1.0);
      });
    }
  }

  void _handleCompletion() {
    setState(() {
      _isSuccessState = true;
    });

    _spinnerController.stop();

    _successController.forward();
    _fadeController.forward();

    widget.onComplete?.call();

    Timer(widget.successDuration, () {
      if (mounted) {
        Navigator.of(context).pop();
        widget.onDismissed?.call();
      }
    });
  }

  @override
  void dispose() {
    _spinnerController.dispose();
    _successController.dispose();
    _fadeController.dispose();
    _progressSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.3),
              child: Container(color: Colors.transparent),
            ),
          ),

          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: _buildLoadingModal(),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingModal() {
    return Container(
      width: 343,
      height: 145,
      decoration: BoxDecoration(
        color: AppColors.neutral0,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.showDragHandle) _buildDragHandle(),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildIndicator(),

                  const SizedBox(height: 16), // gap: 16px
                  _buildTitle(),

                  const SizedBox(height: 8),

                  _buildProgressText(),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildDragHandle() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: AppColors.neutral400,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildIndicator() {
    return AnimatedBuilder(
      animation: Listenable.merge([_fadeController, _successController]),
      builder: (context, child) {
        if (_isSuccessState) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: _buildCompletionIcon(),
            ),
          );
        } else {
          return _buildSpinner();
        }
      },
    );
  }

  Widget _buildCompletionIcon() {
    if (widget.isSuccess) {
      return Assets.icons.pngs.successicon.image(
        width: widget.successIconSize,
        height: widget.successIconSize,
      );
    } else {
      return Assets.icons.pngs.cancelicon.image(
        width: widget.successIconSize,
        height: widget.successIconSize,
      );
    }
  }

  Widget _buildSpinner() {
    if (widget.customSpinner != null) {
      return widget.customSpinner!;
    }

    return SizedBox(
      width: widget.spinnerSize,
      height: widget.spinnerSize,
      child: AnimatedBuilder(
        animation: _spinnerController,
        builder: (context, child) {
          return LoadingAnimationWidget.horizontalRotatingDots(
            color: AppColors.neutral950,
            size: 20,
          );
        },
      ),
    );
  }

  Widget _buildTitle() {
    String displayTitle = widget.title;

    if (_isSuccessState && widget.completedTitle != null) {
      displayTitle = widget.completedTitle!;
    } else if (_isSuccessState && widget.completedTitle == null) {
      if (widget.title == 'LOADING') {
        displayTitle = 'COMPLETED';
      } else if (widget.title == 'SUBMITTING') {
        displayTitle = 'SUBMITTED';
      } else if (widget.title == 'CHECKING OTP') {
        displayTitle = 'OTP VERIFIED';
      } else if (widget.title == 'PROCESSING') {
        displayTitle = 'PROCESSED';
      } else {
        displayTitle = 'COMPLETED';
      }
    }

    return Text(
      displayTitle.toUpperCase(),
      style: TextStyle(
        fontFamily: AppTypography.secondaryFontFamily,
        fontWeight: FontWeight.w600,
        fontSize: 18,
        height: 32.32 / 18.18,
        letterSpacing: 0.18,
        color: AppColors.neutral950,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildProgressText() {
    if (!widget.showProgressText) {
      return const SizedBox.shrink();
    }

    final bool isDeterminate =
        widget.progressStream != null || widget.progress != null;

    if (isDeterminate) {
      if (_isSuccessState) {
        if (widget.completionSubtitle != null) {
          return Text(
            widget.completionSubtitle!,
            style: TextStyle(
              fontFamily: AppTypography.secondaryFontFamily,
              fontWeight: FontWeight.w500,
              fontSize: 14.0,
              height: 20.0 / 14.0,
              letterSpacing: 0.14,
              color: AppColors.neutral400,
            ),
            textAlign: TextAlign.center,
          );
        } else {
          return const SizedBox.shrink();
        }
      } else {
        final int percentage = (_currentProgress * 100).round();
        return Text(
          '$percentage%',
          style: TextStyle(
            fontFamily: AppTypography.secondaryFontFamily,
            fontWeight: FontWeight.w500,
            fontSize: 14.0,
            height: 20.0 / 14.0,
            letterSpacing: 0.14,
            color: AppColors.neutral400,
          ),
          textAlign: TextAlign.center,
        );
      }
    } else {
      if (_isSuccessState && widget.completionSubtitle != null) {
        return Text(
          widget.completionSubtitle!,
          style: TextStyle(
            fontFamily: AppTypography.secondaryFontFamily,
            fontWeight: FontWeight.w500,
            fontSize: 14.0,
            height: 20.0 / 14.0,
            letterSpacing: 0.14,
            color: AppColors.neutral400,
          ),
          textAlign: TextAlign.center,
        );
      } else {
        return const SizedBox.shrink();
      }
    }
  }
}

class LoadingModalController {
  static LoadingModalController? _instance;
  static LoadingModalController get instance {
    _instance ??= LoadingModalController._internal();
    return _instance!;
  }

  LoadingModalController._internal();

  final StreamController<double> _progressController =
      StreamController<double>.broadcast();
  final StreamController<bool> _completionController =
      StreamController<bool>.broadcast();

  Stream<double> get progressStream => _progressController.stream;
  Stream<bool> get completionStream => _completionController.stream;

  double _currentProgress = 0.0;
  bool _isComplete = false;

  double get currentProgress => _currentProgress;

  bool get isComplete => _isComplete;

  void updateProgress(double progress) {
    _currentProgress = progress.clamp(0.0, 1.0);
    _progressController.add(_currentProgress);
  }

  void complete() {
    _isComplete = true;
    _completionController.add(true);
  }

  void reset() {
    _currentProgress = 0.0;
    _isComplete = false;
    _progressController.add(0.0);
    _completionController.add(false);
  }

  void dispose() {
    _progressController.close();
    _completionController.close();
    _instance = null;
  }
}

class LoadingModal {
  LoadingModal._();

  static Future<T?> show<T>({
    required BuildContext context,
    String title = 'LOADING',
    String? completedTitle,
    String? completionSubtitle,
    double? progress,
    Stream<double>? progressStream,
    LoadingModalController? controller,
    bool isComplete = false,
    VoidCallback? onDismissed,
    VoidCallback? onComplete,
    Duration successDuration = const Duration(seconds: 2),
    Duration? loadingDuration,
    Color spinnerColor = AppColors.neutral500,
    Color successColor = AppColors.success500,
    Color titleColor = AppColors.neutral900,
    Color progressColor = AppColors.neutral600,
    double spinnerSize = 20.0,
    double successIconSize = 20.0,
    IconData? successIcon,
    Widget? customSpinner,
    bool showDragHandle = true,
    bool isSuccess = true,
    bool showProgressText = false,
  }) {
    // Use singleton controller by default, or provided controller
    final controllerToUse = controller ?? LoadingModalController.instance;

    // Reset the controller to ensure clean state for new modal
    controllerToUse.reset();

    final future = showDialog<T>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      builder:
          (context) => _LoadingModalWithController(
            title: title,
            controller: controllerToUse,
            onDismissed: onDismissed,
            onComplete: onComplete,
            successDuration: successDuration,
            spinnerColor: spinnerColor,
            successColor: successColor,
            titleColor: titleColor,
            progressColor: progressColor,
            spinnerSize: spinnerSize,
            successIconSize: successIconSize,
            successIcon: successIcon,
            customSpinner: customSpinner,
            showDragHandle: showDragHandle,
            completionSubtitle: completionSubtitle,
            completedTitle: completedTitle,
            isSuccess: isSuccess,
            showProgressText: showProgressText,
          ),
    );

    if (loadingDuration != null) {
      Future.delayed(loadingDuration, () {
        if (context.mounted) {
          controllerToUse.complete();
        }
      });
    }

    return future;
  }
}

class _LoadingModalWithController extends StatefulWidget {
  final String title;
  final LoadingModalController controller;
  final VoidCallback? onDismissed;
  final VoidCallback? onComplete;
  final Duration successDuration;
  final Color spinnerColor;
  final Color successColor;
  final Color titleColor;
  final Color progressColor;
  final double spinnerSize;
  final double successIconSize;
  final IconData? successIcon;
  final Widget? customSpinner;
  final bool showDragHandle;
  final String? completionSubtitle;
  final String? completedTitle;
  final bool isSuccess;
  final bool showProgressText;

  const _LoadingModalWithController({
    required this.title,
    required this.controller,
    this.onDismissed,
    this.onComplete,
    this.successDuration = const Duration(seconds: 2),
    this.spinnerColor = AppColors.neutral500,
    this.successColor = AppColors.success500,
    this.titleColor = AppColors.neutral900,
    this.progressColor = AppColors.neutral600,
    this.spinnerSize = 20.0,
    this.successIconSize = 20.0,
    this.successIcon,
    this.customSpinner,
    this.showDragHandle = true,
    this.completionSubtitle,
    this.completedTitle,
    this.isSuccess = true,
    this.showProgressText = true,
  });

  @override
  State<_LoadingModalWithController> createState() =>
      _LoadingModalWithControllerState();
}

class _LoadingModalWithControllerState
    extends State<_LoadingModalWithController> {
  StreamSubscription<double>? _progressSubscription;
  StreamSubscription<bool>? _completionSubscription;
  double _currentProgress = 0.0;
  bool _isComplete = false;

  @override
  void initState() {
    super.initState();
    _currentProgress = widget.controller.currentProgress;
    _isComplete = widget.controller.isComplete;

    _progressSubscription = widget.controller.progressStream.listen((progress) {
      if (mounted) {
        setState(() {
          _currentProgress = progress;
        });
      }
    });

    _completionSubscription = widget.controller.completionStream.listen((
      isComplete,
    ) {
      if (mounted) {
        setState(() {
          _isComplete = isComplete;
        });
      }
    });
  }

  @override
  void dispose() {
    _progressSubscription?.cancel();
    _completionSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _LoadingModalWidget(
      title: widget.title,
      progress: _currentProgress,
      progressStream: null, // Use controller's stream instead
      isComplete: _isComplete,
      onDismissed: widget.onDismissed,
      onComplete: widget.onComplete,
      successDuration: widget.successDuration,
      spinnerColor: widget.spinnerColor,
      successColor: widget.successColor,
      titleColor: widget.titleColor,
      progressColor: widget.progressColor,
      spinnerSize: widget.spinnerSize,
      successIconSize: widget.successIconSize,
      successIcon: widget.successIcon,
      customSpinner: widget.customSpinner,
      showDragHandle: widget.showDragHandle,
      completionSubtitle: widget.completionSubtitle,
      completedTitle: widget.completedTitle,
      isSuccess: widget.isSuccess,
      showProgressText: widget.showProgressText,
    );
  }
}
