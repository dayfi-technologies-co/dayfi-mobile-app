import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/common/widgets/buttons/primary_button.dart';
import 'package:dayfi/common/widgets/text_fields/custom_text_field.dart';
import 'package:dayfi/features/auth/dayfi_tag/vm/dayfi_tag_viewmodel.dart';

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
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppBar(
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
                      "Create DayFi Tag",
                      style: Theme.of(
                        context,
                      ).textTheme.headlineMedium?.copyWith(
                        fontFamily: 'CabinetGrotesk',
                        fontSize: 28.00,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.w,
                      vertical: 4.h,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Subtitle
                        Text(
                          "Choose a unique DayFi Tag that others can use to send you money. Your tag must start with @ and be at least 3 characters long.\n\nNote: DayFi Tag transfers are only available for NGN (Nigerian Naira).",
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w400,
                            fontFamily: 'Karla',
                            letterSpacing: -.6,
                            height: 1.4,
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
                                  ? 'This DayFi Tag is available!'
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
                                letterSpacing: -.6,
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
                                  ? AppColors.purple500
                                  : AppColors.purple500.withOpacity(.25),
                          height: 60.h,
                          textColor:
                              tagState.isFormValid
                                  ? AppColors.neutral0
                                  : AppColors.neutral0.withOpacity(.5),
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
          onChanged: notifier.setDayfiId,
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
                letterSpacing: -.6,
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
