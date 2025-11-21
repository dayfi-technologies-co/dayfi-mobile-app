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
        child: Scaffold(
          appBar: AppBar(
            scrolledUnderElevation: 0,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                color: Theme.of(context).colorScheme.onSurface,
                // size: 20.sp,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              "Create Your DayFi Tag",
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
             fontFamily: 'CabinetGrotesk',
                 fontSize: 19.sp, // height: 1.6,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 18.w,
                      vertical: 4.h,
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
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w400,
                            fontFamily: 'Karla',
                            letterSpacing: -.3,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 36.h),

                        // DayFi Tag field
                        _buildDayfiTagField(tagState, tagNotifier),

                        // Show validation response
                        if (tagState.dayfiIdResponse != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0, left: 14),
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
                                        : tagState.dayfiIdResponse!.contains(
                                          'belongs to',
                                        )
                                        ? AppColors.error400
                                        : AppColors.error400,
                                fontSize: 13.sp,
                                fontFamily: 'Karla',
                                letterSpacing: -.3,
                                fontWeight: FontWeight.w400,
                                height: 1.4,
                              ),
                            ),
                          ),

                        SizedBox(height: 40.h),

                        // Submit Button
                        PrimaryButton(
                          borderRadius: 38,
                          text: "Create Tag",
                          onPressed:
                              tagState.isFormValid && !tagState.isBusy
                                  ? () => tagNotifier.createDayfiId(context)
                                  : null,

                          backgroundColor:
                              tagState.isFormValid
                                  ? AppColors.purple500ForTheme(context)
                                  : AppColors.purple500ForTheme(
                                    context,
                                  ).withOpacity(.25),
                          height: 48.000.h,
                          textColor:
                              tagState.isFormValid
                                  ? AppColors.neutral0
                                  : AppColors.neutral0.withOpacity(.65),
                          fontFamily: 'Karla',
                          letterSpacing: -.8,
                          fontSize: 18,
                          width: double.infinity,
                          fullWidth: true,
                          isLoading: tagState.isBusy,
                        ),
                        SizedBox(height: 50.h),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDayfiTagField(DayfiTagState state, DayfiTagNotifier notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          label: "DayFi Tag",
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
              _dayfiIdController.text = _dayfiIdController.text.substring(0, 15);
              _dayfiIdController.selection = TextSelection.fromPosition(
                TextPosition(offset: _dayfiIdController.text.length),
              );
            }

            notifier.setDayfiId(_dayfiIdController.text);
          },
          suffixIcon: state.isValidating
              ? Padding(
                  padding: EdgeInsets.all(12.w),
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
                fontSize: 13.sp,
                fontFamily: 'Karla',
                letterSpacing: -.3,
                fontWeight: FontWeight.w400,
                height: 1.4,
              ),
            ),
          )
        else
          const SizedBox.shrink(),
      ],
    );
  }
}
