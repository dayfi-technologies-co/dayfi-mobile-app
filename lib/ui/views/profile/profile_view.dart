import 'package:dayfi/ui/common/app_scaffold.dart';
import 'package:dayfi/ui/common/ui_helpers.dart';
import 'package:dayfi/ui/components/buttons/filled_btn.dart';
import 'package:dayfi/ui/components/input_fields/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stacked/stacked.dart';
import 'profile_viewmodel.dart';

class ProfileView extends StackedView<ProfileViewModel> {
  const ProfileView({super.key});

  @override
  Widget builder(
    BuildContext context,
    ProfileViewModel viewModel,
    Widget? child,
  ) {
    return ViewModelBuilder<ProfileViewModel>.reactive(
      viewModelBuilder: () => ProfileViewModel(),
      builder: (context, model, child) => AppScaffold(
        appBar: AppBar(
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          backgroundColor: Color(0xffF6F5FE),
          leading: IconButton(
            onPressed: () => model.navigationService.back(),
            icon: const Icon(
              Icons.arrow_back,
              color: Color(0xff5645F5), // innit
            ),
          ),
        ),
        backgroundColor: Color(0xffF6F5FE),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    verticalSpace(12.h),
                    Text(
                      "Personal Details",
                      style: TextStyle(
                        fontFamily: 'Boldonse',
                        fontSize: 27.5,
                        height: 1.2,
                        letterSpacing: 0.00,
                        fontWeight: FontWeight.w600,
                        color: Color(0xff2A0079),
                        // color: Color( 0xff5645F5), // innit
                      ),
                      textAlign: TextAlign.start,
                    ),
                    verticalSpace(8.h),
                    Text(
                      "See your profile details",
                      style: TextStyle(
                        fontFamily: 'Karla',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                        height: 1.450,
                        color: Color(0xFF302D53),
                      ),
                      textAlign: TextAlign.start,
                    ),
                    verticalSpace(36.h),
                    Center(
                      child: CircleAvatar(
                        radius: 30,
                        backgroundColor: Color(0xff2A0079).withOpacity(0.2),
                        backgroundImage: const NetworkImage(
                            'https://avatar.iran.liara.run/public/52'),
                      ),
                    ),
                    verticalSpace(24.h),
                    ReadOnlyCustomTextField(
                      label: "Email Address",
                      hintText: "",
                      controller: TextEditingController(
                          text: viewModel.user?.email ?? ""),
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      textCapitalization: TextCapitalization.none,
                    ),
                    verticalSpace(17.5.h),
                    Row(
                      children: [
                        Expanded(
                          child: ReadOnlyCustomTextField(
                            label: "First Name",
                            hintText: "",
                            keyboardType: TextInputType.name,
                            textInputAction: TextInputAction.next,
                            controller: TextEditingController(
                                text: viewModel.user?.firstName ?? ""),
                          ),
                        ),
                        horizontalSpaceSmall,
                        Expanded(
                          child: ReadOnlyCustomTextField(
                            label: "Last Name (Surname)",
                            hintText: "",
                            keyboardType: TextInputType.name,
                            textInputAction: TextInputAction.next,
                            controller: TextEditingController(
                                text: viewModel.user?.lastName ?? ""),
                          ),
                        ),
                      ],
                    ),
                    verticalSpace(
                        viewModel.user?.middleName == null ? 0 : 17.5.h),
                    viewModel.user?.middleName == null
                        ? verticalSpace(0.h)
                        : ReadOnlyCustomTextField(
                            label: "Middle Name",
                            hintText: "",
                            keyboardType: TextInputType.name,
                            textInputAction: TextInputAction.next,
                            controller: TextEditingController(
                                text: viewModel.user?.middleName ?? ""),
                          ),
                    verticalSpace(
                        viewModel.user?.phoneNumber == null ? 0 : 17.5.h),
                    viewModel.user?.phoneNumber == null
                        ? verticalSpace(0.h)
                        : ReadOnlyCustomTextField(
                            label: "Phone Number",
                            hintText: "+234",
                            keyboardType: TextInputType.name,
                            textInputAction: TextInputAction.next,
                            controller: TextEditingController(
                                text: viewModel.user?.phoneNumber ?? ""),
                          ),
                    verticalSpace(viewModel.user?.gender == null ? 0 : 17.5.h),
                    viewModel.user?.gender == null
                        ? verticalSpace(0.h)
                        : ReadOnlyCustomTextField(
                            label: "Gender",
                            hintText: "",
                            keyboardType: TextInputType.name,
                            textInputAction: TextInputAction.next,
                            controller: TextEditingController(
                                text: capitalizeFirst(
                                    viewModel.user!.gender.toString())),
                          ),
                    verticalSpace(
                        viewModel.user?.dateOfBirth == null ? 0 : 17.5.h),
                    viewModel.user?.dateOfBirth == null
                        ? verticalSpace(0.h)
                        : Row(
                            children: [
                              Expanded(
                                child: ReadOnlyCustomTextField(
                                  label: "Date of Birth",
                                  hintText: "",
                                  keyboardType: TextInputType.name,
                                  textInputAction: TextInputAction.next,
                                  controller: TextEditingController(
                                      text: viewModel.day.toString()),
                                ),
                              ),
                              horizontalSpaceSmall,
                              Expanded(
                                child: ReadOnlyCustomTextField(
                                  label: "",
                                  hintText: "",
                                  keyboardType: TextInputType.name,
                                  textInputAction: TextInputAction.next,
                                  controller: TextEditingController(
                                      text:
                                          viewModel.month.toString().length == 1
                                              ? "0${viewModel.month.toString()}"
                                              : viewModel.month.toString()),
                                ),
                              ),
                              horizontalSpaceSmall,
                              Expanded(
                                child: ReadOnlyCustomTextField(
                                  label: "",
                                  hintText: "",
                                  keyboardType: TextInputType.name,
                                  textInputAction: TextInputAction.next,
                                  controller: TextEditingController(
                                      text: viewModel.year.toString()),
                                ),
                              ),
                            ],
                          ),
                    verticalSpace(viewModel.user?.country == null ? 0 : 17.5.h),
                    viewModel.user?.country == null
                        ? verticalSpace(0.h)
                        : ReadOnlyCustomTextField(
                            label: "Country",
                            hintText: "",
                            prefixIcon: Padding(
                              padding: EdgeInsets.fromLTRB(12, 14, 0, 14),
                              child: Image.asset(
                                'assets/images/nigeria.png',
                                height: 10,
                              ),
                            ),
                            keyboardType: TextInputType.name,
                            textInputAction: TextInputAction.next,
                            controller: TextEditingController(
                                text: capitalizeFirst(
                                    viewModel.user!.country.toString())),
                          ),
                    const SizedBox(height: 20),
                    FilledBtn(
                      onPressed: () {},
                      text: 'Do you need help?',
                      backgroundColor: Colors.transparent,
                      textColor: const Color(0xff5645F5), // innit
                    ),
                    Container(
                      padding: EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 249, 254, 255),
                        borderRadius: BorderRadius.circular(4.0),
                        border: Border.all(
                          color: Color.fromARGB(255, 26, 77, 104),
                        ),
                      ),
                      child: Row(
                        // crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(width: 8),
                          Image.asset(
                            "assets/images/idea.png",
                            height: 22,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'To update your profile, kindly reach out to our support team at support@dayfi.co or click the "Do you need help" button above this.',
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'Karla',
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.3,
                                height: 1.450,
                                color: Color.fromARGB(255, 26, 77, 104),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    verticalSpace(40.h),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String capitalizeFirst(String input) {
    if (input.isEmpty) return input;
    return input[0].toUpperCase() + input.substring(1);
  }

  @override
  ProfileViewModel viewModelBuilder(BuildContext context) => ProfileViewModel();

  @override
  void onViewModelReady(ProfileViewModel viewModel) {
    viewModel.loadUser();
    viewModel.notifyListeners();
    super.onViewModelReady(viewModel);
  }
}
