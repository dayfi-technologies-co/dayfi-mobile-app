import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/common/widgets/buttons/primary_button.dart';
import 'package:dayfi/common/widgets/text_fields/custom_text_field.dart';
import 'package:dayfi/features/auth/dayfi_tag/vm/dayfi_tag_viewmodel.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class CreateDayfiTagView extends ConsumerStatefulWidget {
  const CreateDayfiTagView({super.key});

  @override
  ConsumerState<CreateDayfiTagView> createState() => _CreateDayfiTagViewState();
}

class _CreateDayfiTagViewState extends ConsumerState<CreateDayfiTagView> {
  late TextEditingController _dayfiIdController;

  @override
  void initState() {
    super.initState();
    _initializeControllers();

    // Reset form state when view is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(dayfiTagProvider.notifier).resetForm();
    });
  }

  void _initializeControllers() {
    _dayfiIdController = TextEditingController();
  }

  @override
  void dispose() {
    _dayfiIdController.dispose();
    super.dispose();
  }

  void _updateControllers(DayfiTagState state) {
    if (_dayfiIdController.text != state.dayfiId) {
      _dayfiIdController.text = state.dayfiId;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tagState = ref.watch(dayfiTagProvider);
    final tagNotifier = ref.read(dayfiTagProvider.notifier);

    // Update controllers when state changes
    _updateControllers(tagState);

    return WillPopScope(
      onWillPop: () async => false, // Disable device back button
      child: GestureDetector(
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Stack(
          children: [
            Scaffold(
              appBar: AppBar(
                scrolledUnderElevation: .5,
                foregroundColor: Theme.of(context).scaffoldBackgroundColor,
                shadowColor: Theme.of(context).scaffoldBackgroundColor,
                surfaceTintColor: Theme.of(context).scaffoldBackgroundColor,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                elevation: 0,
                leading: IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios,
                    size: 20,
                    color: Theme.of(context).colorScheme.onSurface,
                    // size: 20,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                title: Text(
                  "Create Your Dayfi Tag",
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontFamily: 'FunnelDisplay',
                    fontSize: 24, // height: 1.6,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              body: SafeArea(
                bottom: false,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final bool isWide = constraints.maxWidth > 600;
                    return SingleChildScrollView(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: isWide ? 400 : double.infinity,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isWide ? 24 : 18,
                                  vertical: 4,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // Subtitle
                                    Text(
                                      "Pick a username that's easy to remember. Must start with @ and be at least 3 characters.",
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium?.copyWith(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        fontFamily: 'Chirp',
                                        letterSpacing: -.25,
                                        height: 1.5,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(height: 36),
            
                                    // Dayfi Tag field
                                    _buildDayfiTagField(tagState, tagNotifier),
            
                                    // Show validation response
                                    if (tagState.dayfiIdResponse != null)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          top: 8.0,
                                          left: 14,
                                        ),
                                        child: Text(
                                          tagState.dayfiIdResponse!.contains(
                                                'User not found',
                                              )
                                              ? 'Perfect! This tag is available'
                                              : tagState.dayfiIdResponse!,
                                          style: TextStyle(
                                            color:
                                                tagState.dayfiIdResponse!.contains(
                                                      'User not found',
                                                    )
                                                    ? AppColors.success400
                                                    : tagState.dayfiIdResponse!
                                                        .contains('belongs to')
                                                    ? AppColors.error400
                                                    : AppColors.error400,
                                            fontSize: 13,
                                            fontFamily: 'Chirp',
                                            letterSpacing: -.25,
                                            fontWeight: FontWeight.w500,
                                            height: 1.2,
                                          ),
                                        ),
                                      ),
            
                                    SizedBox(height: 32),
            
                                    // Submit Button
                                    PrimaryButton(
                                      borderRadius: 38,
                                      text: "Create Tag",
                                      onPressed:
                                          tagState.isFormValid && !tagState.isBusy
                                              ? () =>
                                                  tagNotifier.createDayfiId(context)
                                              : null,
            
                                      backgroundColor:
                                          tagState.isFormValid
                                              ? AppColors.purple500ForTheme(context)
                                              : AppColors.purple500ForTheme(
                                                context,
                                              ).withOpacity(.15),
                                      height: 48.00000,
                                      textColor:
                                          tagState.isFormValid
                                             ? AppColors.neutral0
                                          : AppColors.neutral0.withOpacity(.20),
                                      fontFamily: 'Chirp',
                                      letterSpacing: -.70,
                                      fontSize: 18,
                                      width: double.infinity,
                                      fullWidth: true,
                                      isLoading: tagState.isBusy,
                                    ),
                                    SizedBox(height: 50),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

             if (tagState.isBusy)
              Scaffold(
                backgroundColor: Colors.transparent,
                resizeToAvoidBottomInset: true,
                body: Opacity(
                  opacity: 0.5,
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: Colors.black,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayfiTagField(DayfiTagState state, DayfiTagNotifier notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          label: "Dayfi Tag",
          hintText: "@username",
          controller: _dayfiIdController,
          isDayfiId: true,
          keyboardType: TextInputType.text,
          textCapitalization: TextCapitalization.none,
          onChanged: (value) {
            // Ensure the tag starts with '@'
            if (!value.startsWith('@')) {
              _dayfiIdController.text = '@' + value.replaceAll('@', '');
              _dayfiIdController.selection = TextSelection.fromPosition(
                TextPosition(offset: _dayfiIdController.text.length),
              );
            }

            // Limit the length to 15 characters (including '@')
            if (_dayfiIdController.text.length > 15) {
              _dayfiIdController.text = _dayfiIdController.text.substring(
                0,
                15,
              );
              _dayfiIdController.selection = TextSelection.fromPosition(
                TextPosition(offset: _dayfiIdController.text.length),
              );
            }

            notifier.setDayfiId(_dayfiIdController.text);
          },
          suffixIcon:
              state.isValidating
                  ? Padding(
                    padding: EdgeInsets.all(12),
                    child: LoadingAnimationWidget.horizontalRotatingDots(
                      color: AppColors.purple500ForTheme(context),
                      size: 20,
                    ),
                  )
                  : null,
        ),
        if (state.dayfiIdError.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4.0, left: 14),
            child: Text(
              state.dayfiIdError,
              style: TextStyle(
                color: AppColors.error400,
                fontSize: 13,
                fontFamily: 'Chirp',
                letterSpacing: -.25,
                fontWeight: FontWeight.w500,
                height: 1.2,
              ),
            ),
          )
        else
          const SizedBox.shrink(),
      ],
    );
  }
}
