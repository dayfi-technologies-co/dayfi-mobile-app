import 'dart:developer';

import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/core/theme/app_typography.dart';
import 'package:dayfi/common/widgets/buttons/primary_button.dart';
import 'package:dayfi/common/widgets/text_fields/custom_text_field.dart';
import 'package:dayfi/features/auth/complete_personal_information/vm/complete_personal_information_viewmodel.dart';
import 'package:dayfi/common/utils/platform_date_picker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class CompletePersonalInformationView extends ConsumerStatefulWidget {
  const CompletePersonalInformationView({super.key});

  @override
  ConsumerState<CompletePersonalInformationView> createState() =>
      _CompletePersonalInformationViewState();
}

class _CompletePersonalInformationViewState
    extends ConsumerState<CompletePersonalInformationView> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // Text controllers
  late TextEditingController _phoneNumberController;
  late TextEditingController _addressController;
  late TextEditingController _postalCodeController;
  late TextEditingController _stateController;
  late TextEditingController _cityController;
  late TextEditingController _referralCodeController;

  final List<String> _steps = [
    // 'Avatar',
    'Username',
    'Date of Birth',
    'Country',
    'State',
    'city',
    'Address',
    'Phone Number',
    'Occupation',
    'Use Case',
  ];

  void _updateControllers(CompletePersonalInfoState state) {
    if (_phoneNumberController.text != state.phoneNumber) {
      _phoneNumberController.text = state.phoneNumber;
    }
    if (_addressController.text != state.address) {
      _addressController.text = state.address;
    }
    if (_postalCodeController.text != state.postalCode) {
      _postalCodeController.text = state.postalCode;
    }
    if (_stateController.text != state.state) {
      _stateController.text = state.state;
    }
    if (_cityController.text != state.city) {
      _cityController.text = state.city;
    }
    if (_referralCodeController.text != state.referralCode) {
      _referralCodeController.text = state.referralCode;
    }
  }

  void _goToStep(int step) {
    if (step < 0) step = 0;
    if (step > _steps.length - 1) step = _steps.length - 1;
    setState(() {
      _currentStep = step;
    });
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  // Username (dayfitag)
  late TextEditingController _usernameController;
  String _selectedOccupation = '';
  final List<String> _occupationOptions = [
    'Technology',
    'Finance & Banking',
    'Healthcare',
    'Education',
    'Marketing & Advertising',
    'Engineering',
    'Legal',
    'Business & Management',
    'Creative & Design',
    'Media & Entertainment',
    'Retail & Sales',
    'Food & Hospitality',
    'Transportation & Logistics',
    'Real Estate',
    'Government & Public Service',
    'Consulting',
    'Human Resources',
    'Customer Service',
    'Manufacturing',
    'Agriculture',
    'Science & Research',
    'Travel & Tourism',
    'Administrative',
    'Skilled Trades',
    'Entertainment & Sports',
    'Non-profit & NGO',
    'Entrepreneur',
    'Student',
    'Homemaker',
    'Other',
  ];
  final List<String> _useCaseOptions = [
    'Send Money',
    'Receive Money',
    'Save',
    'Invest',
    'Pay Bills',
    'Shop Online',
    'Freelance',
    'Business',
    'Travel',
    'Family',
    'Education',
    'Other',
  ];
  final Set<String> _selectedUseCases = <String>{};

  @override
  void initState() {
    super.initState();
    _phoneNumberController = TextEditingController();
    _addressController = TextEditingController();
    _postalCodeController = TextEditingController();
    _stateController = TextEditingController();
    _cityController = TextEditingController();
    _referralCodeController = TextEditingController();
    _usernameController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(completePersonalInfoProvider.notifier).resetForm();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _phoneNumberController.dispose();
    _addressController.dispose();
    _postalCodeController.dispose();
    _stateController.dispose();
    _cityController.dispose();
    _referralCodeController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  // Username (dayfitag) Step
  Widget _buildUsernameStep() {
    final state = ref.watch(completePersonalInfoProvider);
    final notifier = ref.read(completePersonalInfoProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 8),
        Padding(
          padding: EdgeInsets.only(left: 18, right: 72.0),
          child: Text(
            "Create your Dayfi Tag",
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontFamily: 'FunnelDisplay',
              fontSize: MediaQuery.of(context).size.width > 600 ? 28 : 24,
              height: 1.000,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: 12),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 18),
          child: Text(
            "Create a unique Dayfi Tag — this is how others can find and pay you.",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              fontFamily: 'Chirp',
              letterSpacing: -.25,
              height: 1.2,
              color: Theme.of(
                context,
              ).textTheme.bodyMedium!.color!.withOpacity(0.65),
            ),
            textAlign: TextAlign.start,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 24, horizontal: 18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                label: "Dayfi Tag",
                hintText: "username",
                controller: _usernameController,
                isDayfiId: true,
                keyboardType: TextInputType.text,
                textCapitalization: TextCapitalization.none,
                prefix: Padding(
                  padding: EdgeInsets.only(left: 0, right: 2),
                  child: Text(
                    '@',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Chirp',
                      fontWeight: FontWeight.w600,
                      color: AppColors.purple500ForTheme(context),
                    ),
                  ),
                ),
                onChanged: (value) {
                  notifier.setDayfiId(value);
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
                        : state.dayfiId.isNotEmpty &&
                            state.dayfiIdError.isEmpty &&
                            state.isDayfiIdValid
                        ? Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: SvgPicture.asset(
                            "assets/icons/svgs/circle-check.svg",
                            color: AppColors.success500,
                          ),
                        )
                        : null,
              ),

              if (state.dayfiIdError.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0, left: 14),
                  child: Text(
                    state.dayfiIdError,
                    style: const TextStyle(
                      color: Colors.red,
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
          ),
        ),

        SizedBox(height: 32),
      ],
    );
  }

  // Date of Birth Step
  Widget _buildDobStep(ThemeData theme) {
    final state = ref.watch(completePersonalInfoProvider);
    final notifier = ref.read(completePersonalInfoProvider.notifier);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        SizedBox(height: 8),
        Padding(
          padding: EdgeInsets.only(left: 18, right: 72.0),
          child: Text(
            "Date of birth",
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontFamily: 'FunnelDisplay',
              fontSize: MediaQuery.of(context).size.width > 600 ? 28 : 24,
              height: 1.000,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: 12),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 18),
          child: Text(
            "Required for identity verification and compliance.",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              fontFamily: 'Chirp',
              letterSpacing: -.25,
              height: 1.2,
              color: Theme.of(
                context,
              ).textTheme.bodyMedium!.color!.withOpacity(0.65),
            ),
            textAlign: TextAlign.start,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 24, horizontal: 18.0),
          child: CustomTextField(
            label: "Date of Birth",
            hintText: "Select your date of birth",
            controller: TextEditingController(
              text: _formatDateForDisplay(state.dateOfBirth),
            ),
            onChanged: notifier.setDateOfBirth,
            suffixIcon: Container(
              width: 40,
              alignment: Alignment.centerRight,
              constraints: BoxConstraints.tightForFinite(),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Center(
                    child: SvgPicture.asset(
                      'assets/icons/svgs/calendar.svg',
                      height: 26,
                      color: theme.colorScheme.onSurface.withOpacity(.65),
                    ),
                  ),
                ],
              ),
            ),
            shouldReadOnly: true,
            onTap: () => _showDatePicker(notifier),
          ),
        ),
        // if (state.dateOfBirthError.isNotEmpty)
        //   Padding(
        //     padding: const EdgeInsets.only(top: 4.0, left: 14),
        //     child: Text(
        //       state.dateOfBirthError,
        //       style: const TextStyle(
        //         color: Colors.red,
        //         fontSize: 13,
        //         fontFamily: 'Chirp',
        //         letterSpacing: -.25,
        //         fontWeight: FontWeight.w500,
        //         height: 1.2,
        //       ),
        //     ),
        //   )
        // else
        //   const SizedBox.shrink(),
      ],
    );
  }

  // Country Step
  Widget _buildCountryStep() {
    final state = ref.watch(completePersonalInfoProvider);
    final notifier = ref.read(completePersonalInfoProvider.notifier);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 8),
        Padding(
          padding: EdgeInsets.only(left: 18, right: 72.0),
          child: Text(
            "Country of residence",
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontFamily: 'FunnelDisplay',
              fontSize: MediaQuery.of(context).size.width > 600 ? 28 : 24,
              height: 1.000,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: 12),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 18),
          child: Text(
            "Select where you currently reside.",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              fontFamily: 'Chirp',
              letterSpacing: -.25,
              height: 1.2,
              color: Theme.of(
                context,
              ).textTheme.bodyMedium!.color!.withOpacity(0.65),
            ),
            textAlign: TextAlign.start,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 24, horizontal: 18.0),
          child: CustomTextField(
            label: "Country",
            hintText: "Select your country",
            controller: TextEditingController(text: state.country),
            onChanged: notifier.setCountry,
            suffixIcon: Icon(
              Icons.keyboard_arrow_down,
              color: AppColors.neutral400,
              size: 20,
            ),
            shouldReadOnly: true,
            onTap: () => _showCountryBottomSheet(notifier),
          ),
        ),

        // if (state.countryError.isNotEmpty)
        //   Padding(
        //     padding: const EdgeInsets.only(top: 4.0, left: 18),
        //     child: Text(
        //       state.countryError,
        //       style: const TextStyle(
        //         color: Colors.red,
        //         fontSize: 13,
        //         fontFamily: 'Chirp',
        //         letterSpacing: -.25,
        //         fontWeight: FontWeight.w500,
        //         height: 1.2,
        //       ),
        //     ),
        //   )
        // else
        //   const SizedBox.shrink(),
      ],
    );
  }

  Widget _buildCityField(
    CompletePersonalInfoState state,
    CompletePersonalInfoNotifier notifier,
  ) {
    // Determine the correct label and description based on country
    String divisionLabel = "City";
    String divisionDesc =
        "Select your city of residence to help us customize your experience.";
    final country = state.country;
    if (country == "Kenya") {
      divisionLabel = "Town";
      divisionDesc =
          "Select your town of residence to help us customize your experience.";
    } else if (country == "South Africa") {
      divisionLabel = "Municipality";
      divisionDesc =
          "Select your municipality of residence to help us customize your experience.";
    } else if (country == "Botswana") {
      divisionLabel = "Village";
      divisionDesc =
          "Select your village of residence to help us customize your experience.";
    } else if (country == "Zambia") {
      divisionLabel = "Town";
      divisionDesc =
          "Select your town of residence to help us customize your experience.";
    } else if (country == "Rwanda") {
      divisionLabel = "Sector";
      divisionDesc =
          "Select your sector of residence to help us customize your experience.";
    } else if (country == "Malawi") {
      divisionLabel = "Town";
      divisionDesc =
          "Select your town of residence to help us customize your experience.";
    } else if (country == "Tanzania") {
      divisionLabel = "District";
      divisionDesc =
          "Select your district of residence to help us customize your experience.";
    } else if (country == "Uganda") {
      divisionLabel = "Town";
      divisionDesc =
          "Select your town of residence to help us customize your experience.";
    } else if (country == "Cameroon") {
      divisionLabel = "Commune";
      divisionDesc =
          "Select your commune of residence to help us customize your experience.";
    } else if (country == "Benin") {
      divisionLabel = "Commune";
      divisionDesc =
          "Select your commune of residence to help us customize your experience.";
    } else if (country == "Côte d’Ivoire") {
      divisionLabel = "Commune";
      divisionDesc =
          "Select your commune of residence to help us customize your experience.";
    } else if (country == "Senegal") {
      divisionLabel = "Commune";
      divisionDesc =
          "Select your commune of residence to help us customize your experience.";
    } else if (country == "DR Congo") {
      divisionLabel = "Territory";
      divisionDesc =
          "Select your territory of residence to help us customize your experience.";
    } else if (country == "Republic of the Congo") {
      divisionLabel = "Commune";
      divisionDesc =
          "Select your commune of residence to help us customize your experience.";
    } else if (country == "Gabon") {
      divisionLabel = "Commune";
      divisionDesc =
          "Select your commune of residence to help us customize your experience.";
    } else if (country == "Togo") {
      divisionLabel = "Commune";
      divisionDesc =
          "Select your commune of residence to help us customize your experience.";
    } else if (country == "Mali") {
      divisionLabel = "Commune";
      divisionDesc =
          "Select your commune of residence to help us customize your experience.";
    } else if (country == "Burkina Faso") {
      divisionLabel = "Commune";
      divisionDesc =
          "Select your commune of residence to help us customize your experience.";
    }

    // City lists for Nigeria and Kenya
    List<String> cities = [];
    final stateValue = state.state;
    if (state.country == 'Nigeria') {
      if (stateValue == 'Lagos') {
        cities = [
          'Agege',
          'Ajeromi-Ifelodun',
          'Alimosho',
          'Amuwo-Odofin',
          'Apapa',
          'Badagry',
          'Epe',
          'Eti-Osa',
          'Ibeju-Lekki',
          'Ifako-Ijaiye',
          'Ikeja',
          'Ikorodu',
          'Kosofe',
          'Lagos Island',
          'Lagos Mainland',
          'Mushin',
          'Ojo',
          'Oshodi-Isolo',
          'Shomolu',
          'Surulere',
        ];
      } else if (stateValue == 'Abuja (FCT)') {
        cities = [
          'Abuja Municipal',
          'Gwagwalada',
          'Kuje',
          'Bwari',
          'Kwali',
          'Abaji',
        ];
      } else if (stateValue == 'Oyo') {
        cities = [
          'Ibadan North',
          'Ibadan South-West',
          'Ibadan South-East',
          'Ibadan North-East',
          'Ibadan North-West',
          'Ogbomosho',
          'Oyo',
          'Iseyin',
          'Saki',
          'Igboho',
        ];
      } else if (stateValue == 'Rivers') {
        cities = [
          'Port Harcourt',
          'Obio-Akpor',
          'Eleme',
          'Ikwerre',
          'Okrika',
          'Bonny',
          'Ahoada',
        ];
      } else if (stateValue == 'Ogun') {
        cities = [
          'Abeokuta North',
          'Abeokuta South',
          'Ijebu-Ode',
          'Sagamu',
          'Ilaro',
          'Ota',
        ];
      } else if (stateValue == 'Delta') {
        cities = ['Asaba', 'Warri', 'Ughelli', 'Sapele', 'Agbor', 'Ozoro'];
      } else if (stateValue == 'Edo') {
        cities = ['Benin City', 'Uromi', 'Auchi', 'Ekpoma', 'Igarra'];
      } else if (stateValue == 'Anambra') {
        cities = ['Awka', 'Onitsha', 'Nnewi', 'Ekwulobia', 'Ogidi'];
      } else if (stateValue == 'Imo') {
        cities = ['Owerri', 'Orlu', 'Okigwe', 'Mbaise'];
      } else if (stateValue == 'Abia') {
        cities = ['Umuahia', 'Aba', 'Ohafia', 'Bende'];
      } else if (stateValue == 'Enugu') {
        cities = ['Enugu', 'Nsukka', 'Agbani', 'Udi'];
      } else if (stateValue == 'Akwa Ibom') {
        cities = ['Uyo', 'Eket', 'Ikot Ekpene', 'Oron'];
      } else if (stateValue == 'Cross River') {
        cities = ['Calabar', 'Ikom', 'Ogoja', 'Obudu'];
      } else if (stateValue == 'Kaduna') {
        cities = ['Kaduna', 'Zaria', 'Kafanchan', 'Birnin Gwari'];
      } else if (stateValue == 'Kano') {
        cities = ['Kano', 'Wudil', 'Gaya', 'Bichi', 'Rano'];
      } else if (stateValue == 'Plateau') {
        cities = ['Jos', 'Bukuru', 'Pankshin', 'Shendam'];
      } else if (stateValue == 'Benue') {
        cities = ['Makurdi', 'Gboko', 'Otukpo', 'Katsina-Ala'];
      } else if (stateValue == 'Niger') {
        cities = ['Minna', 'Bida', 'Kontagora', 'Suleja'];
      } else if (stateValue == 'Kwara') {
        cities = ['Ilorin', 'Offa', 'Omu-Aran', 'Jebba'];
      } else if (stateValue == 'Kogi') {
        cities = ['Lokoja', 'Okene', 'Kabba', 'Idah'];
      } else if (stateValue == 'Osun') {
        cities = ['Osogbo', 'Ile-Ife', 'Ilesa', 'Ede'];
      } else if (stateValue == 'Ondo') {
        cities = ['Akure', 'Owo', 'Ondo', 'Ikare'];
      } else if (stateValue == 'Ekiti') {
        cities = ['Ado-Ekiti', 'Ikere', 'Ilawe', 'Omuo'];
      } else if (stateValue == 'Bayelsa') {
        cities = ['Yenagoa', 'Brass', 'Ogbia', 'Sagbama'];
      } else if (stateValue == 'Sokoto') {
        cities = ['Sokoto', 'Tambuwal', 'Gwadabawa', 'Illela'];
      } else if (stateValue == 'Borno') {
        cities = ['Maiduguri', 'Biu', 'Dikwa', 'Gwoza'];
      } else if (stateValue == 'Yobe') {
        cities = ['Damaturu', 'Potiskum', 'Gashua', 'Nguru'];
      } else if (stateValue == 'Zamfara') {
        cities = ['Gusau', 'Kaura Namoda', 'Anka', 'Talata Mafara'];
      }
    } else if (state.country == 'Kenya') {
      if (stateValue == 'Nairobi') {
        cities = [
          'Westlands',
          'Kilimani',
          'Karen',
          'Ruiru',
          'Embakasi',
          'Kasarani',
        ];
      } else if (stateValue == 'Mombasa') {
        cities = ['Nyali', 'Kisauni', 'Likoni', 'Changamwe', 'Mvita'];
      } else if (stateValue == 'Kiambu') {
        cities = ['Thika', 'Ruiru', 'Kiambu', 'Limuru', 'Githurai'];
      } else if (stateValue == 'Nakuru') {
        cities = ['Nakuru Town', 'Naivasha', 'Gilgil', 'Molo'];
      } else if (stateValue == 'Kisumu') {
        cities = ['Kisumu City', 'Ahero', 'Maseno', 'Muhoroni'];
      } else if (stateValue == 'Uasin Gishu') {
        cities = ['Eldoret', 'Turbo', 'Burnt Forest'];
      } else if (stateValue == 'Machakos') {
        cities = ['Machakos', 'Athi River', 'Mavoko', 'Kangundo'];
      } else if (stateValue == 'Kajiado') {
        cities = ['Ngong', 'Kitengela', 'Kajiado Town', 'Namanga'];
      } else if (stateValue == 'Meru') {
        cities = ['Meru Town', 'Maua', 'Nkubu'];
      } else if (stateValue == 'Kakamega') {
        cities = ['Kakamega Town', 'Mumias', 'Butere'];
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 8),
        Padding(
          padding: EdgeInsets.only(left: 18, right: 72.0),
          child: Text(
            "Select your ${divisionLabel.toLowerCase()}",
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontFamily: 'FunnelDisplay',
              fontSize: MediaQuery.of(context).size.width > 600 ? 28 : 24,
              height: 1.000,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: 12),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 18),
          child: Text(
            "Choose your ${divisionLabel.toLowerCase()} for accurate service.",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              fontFamily: 'Chirp',
              letterSpacing: -.25,
              height: 1.2,
              color: Theme.of(
                context,
              ).textTheme.bodyMedium!.color!.withOpacity(0.65),
            ),
            textAlign: TextAlign.start,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 24, horizontal: 18.0),
          child:
              cities.isNotEmpty
                  ? CustomTextField(
                    label: divisionLabel,
                    hintText:
                        cities.isNotEmpty
                            ? "Select your ${divisionLabel.toLowerCase()}"
                            : "Enter your ${divisionLabel.toLowerCase()}",
                    controller: _cityController,
                    onChanged: notifier.setCity,
                    textCapitalization: TextCapitalization.words,
                    shouldReadOnly: cities.isNotEmpty,
                    suffixIcon:
                        cities.isNotEmpty
                            ? Icon(
                              Icons.keyboard_arrow_down,
                              color: AppColors.neutral400,
                              size: 20,
                            )
                            : null,
                    onTap:
                        cities.isNotEmpty
                            ? () => _showCityBottomSheet(cities, notifier)
                            : null,
                  )
                  : CustomTextField(
                    label: divisionLabel,
                    hintText: "Enter your ${divisionLabel.toLowerCase()}",
                    controller: _cityController,
                    onChanged: notifier.setCity,
                    textCapitalization: TextCapitalization.words,
                  ),
        ),
        // if (state.cityError.isNotEmpty)
        //   Padding(
        //     padding: const EdgeInsets.only(top: 4.0, left: 14),
        //     child: Text(
        //       state.cityError,
        //       style: const TextStyle(
        //         color: Colors.red,
        //         fontSize: 13,
        //         fontFamily: 'Chirp',
        //         letterSpacing: -.25,
        //         fontWeight: FontWeight.w500,
        //         height: 1.2,
        //       ),
        //     ),
        //   )
        // else
        //   const SizedBox.shrink(),
      ],
    );
  }
  // Avatar/profile state

  // Phone Step
  Widget _buildPhoneStep() {
    final state = ref.watch(completePersonalInfoProvider);
    final notifier = ref.read(completePersonalInfoProvider.notifier);

    // Country-specific phone rules
    final phoneRules = {
      "Nigeria": {
        "code": "+234",
        "min": 10,
        "max": 11,
        "regex": r"^(0?[789][01]\d{8})$",
        "desc": "Enter 10 or 11 digits, e.g. 08012345678.",
      },

      "Kenya": {
        "code": "+254",
        "min": 9,
        "max": 9,
        "regex": r"^[17]\d{8}$",
        "desc": "Enter 9 digits, e.g. 712345678.",
      },

      "South Africa": {
        "code": "+27",
        "min": 9,
        "max": 9,
        "regex": r"^[6-8]\d{8}$",
        "desc": "Enter 9 digits, e.g. 712345678.",
      },

      "Botswana": {
        "code": "+267",
        "min": 8,
        "max": 8,
        "regex": r"^7\d{7}$",
        "desc": "Enter 8 digits, e.g. 71234567.",
      },

      "Zambia": {
        "code": "+260",
        "min": 9,
        "max": 9,
        "regex": r"^[79]\d{8}$",
        "desc": "Enter 9 digits, e.g. 971234567.",
      },

      "Rwanda": {
        "code": "+250",
        "min": 9,
        "max": 9,
        "regex": r"^7\d{8}$",
        "desc": "Enter 9 digits, e.g. 712345678.",
      },

      "Malawi": {
        "code": "+265",
        "min": 9,
        "max": 9,
        "regex": r"^[89]\d{8}$",
        "desc": "Enter 9 digits, e.g. 912345678.",
      },

      "Tanzania": {
        "code": "+255",
        "min": 9,
        "max": 9,
        "regex": r"^[67]\d{8}$",
        "desc": "Enter 9 digits, e.g. 712345678.",
      },

      "Uganda": {
        "code": "+256",
        "min": 9,
        "max": 9,
        "regex": r"^[37]\d{8}$",
        "desc": "Enter 9 digits, e.g. 712345678.",
      },

      "Cameroon": {
        "code": "+237",
        "min": 9,
        "max": 9,
        "regex": r"^6\d{8}$",
        "desc": "Enter 9 digits, e.g. 612345678.",
      },

      "Benin": {
        "code": "+229",
        "min": 8,
        "max": 8,
        "regex": r"^[24569]\d{7}$",
        "desc": "Enter 8 digits, e.g. 61234567.",
      },

      "Côte d’Ivoire": {
        "code": "+225",
        "min": 8,
        "max": 8,
        "regex": r"^[0-7]\d{7}$",
        "desc": "Enter 8 digits, e.g. 01234567.",
      },

      "Senegal": {
        "code": "+221",
        "min": 9,
        "max": 9,
        "regex": r"^7\d{8}$",
        "desc": "Enter 9 digits, e.g. 712345678.",
      },

      "DR Congo": {
        "code": "+243",
        "min": 9,
        "max": 9,
        "regex": r"^[89]\d{8}$",
        "desc": "Enter 9 digits, e.g. 812345678.",
      },

      "Republic of the Congo": {
        "code": "+242",
        "min": 9,
        "max": 9,
        "regex": r"^[05]\d{8}$",
        "desc": "Enter 9 digits, e.g. 051234567.",
      },

      "Gabon": {
        "code": "+241",
        "min": 8,
        "max": 8,
        "regex": r"^[0267]\d{7}$",
        "desc": "Enter 8 digits, e.g. 06234567.",
      },

      "Togo": {
        "code": "+228",
        "min": 8,
        "max": 8,
        "regex": r"^[29]\d{7}$",
        "desc": "Enter 8 digits, e.g. 91234567.",
      },

      "Mali": {
        "code": "+223",
        "min": 8,
        "max": 8,
        "regex": r"^[67]\d{7}$",
        "desc": "Enter 8 digits, e.g. 67234567.",
      },

      "Burkina Faso": {
        "code": "+226",
        "min": 8,
        "max": 8,
        "regex": r"^[567]\d{7}$",
        "desc": "Enter 8 digits, e.g. 57234567.",
      },
    };

    final country = state.country;
    final rules =
        phoneRules[country] ??
        {
          "code": "",
          "min": 8,
          "max": 12,
          "regex": r"^\d+$",
          "desc": "Enter a valid phone number.",
        };
    final countryCode = rules["code"] as String;
    final minLength = rules["min"] as int;
    final maxLength = rules["max"] as int;
    final regex = RegExp(rules["regex"] as String);
    final desc = rules["desc"] as String;

    String? errorMsg;
    final phone = state.phoneNumber;
    if (phone.isNotEmpty) {
      if (!RegExp(r"^\d+$").hasMatch(phone)) {
        errorMsg = "Phone number must be digits only.";
      } else if (phone.length < minLength || phone.length > maxLength) {
        errorMsg = "Phone number must be $minLength to $maxLength digits.";
      } else if (!regex.hasMatch(phone)) {
        errorMsg = "Invalid format";
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 8),
        Padding(
          padding: EdgeInsets.only(left: 18, right: 72.0),
          child: Text(
            "Phone number",
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontFamily: 'FunnelDisplay',
              fontSize: MediaQuery.of(context).size.width > 600 ? 28 : 24,
              height: 1.000,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: 12),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 18),
          child: Text(
            "For account security and transaction alerts.",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              fontFamily: 'Chirp',
              letterSpacing: -.25,
              height: 1.2,
              color: Theme.of(
                context,
              ).textTheme.bodyMedium!.color!.withOpacity(0.65),
            ),
            textAlign: TextAlign.start,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 24, horizontal: 18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                label: "Phone Number",
                hintText: "(801) 234-5678",
                controller: _phoneNumberController,
                maxLength: maxLength,
                keyboardType: TextInputType.number,
                prefix:
                    countryCode.isNotEmpty
                        ? Padding(
                          padding: EdgeInsets.only(right: 4.0),
                          child: Text(
                            countryCode,
                            style: TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 15,
                            ),
                          ),
                        )
                        : null,
                onChanged: (val) {
                  // Only allow digits
                  final digitsOnly = val.replaceAll(RegExp(r"[^\d]"), "");
                  if (digitsOnly != val) {
                    _phoneNumberController.text = digitsOnly;
                    _phoneNumberController
                        .selection = TextSelection.fromPosition(
                      TextPosition(offset: digitsOnly.length),
                    );
                  }
                  notifier.setPhoneNumber(digitsOnly);
                },
                textCapitalization: TextCapitalization.none,
              ),
              if (errorMsg != null && errorMsg.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0, left: 14),
                  child: Text(
                    errorMsg,
                    style: const TextStyle(
                      color: Colors.red,
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
          ),
        ),
      ],
    );
  }

  void _showCityBottomSheet(
    List<String> cities,
    CompletePersonalInfoNotifier notifier,
  ) {
    showModalBottomSheet(
      barrierColor: Colors.black.withOpacity(0.85),
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => _CityBottomSheet(
            cities: cities,
            onCitySelected: (city) {
              notifier.setCity(city);
              _cityController.text = city;
              Navigator.pop(context);
            },
          ),
    );
  }

  // Occupation Step
  Widget _buildOccupationStep() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.only(left: 18, right: 72.0),
            child: Text(
              "Occupation",
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontFamily: 'FunnelDisplay',
                fontSize: MediaQuery.of(context).size.width > 600 ? 28 : 24,
                height: 1.000,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 12),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 18),
            child: Text(
              "Tell us what you do — this is optional.",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                fontFamily: 'Chirp',
                letterSpacing: -.25,
                height: 1.2,
                color: Theme.of(
                  context,
                ).textTheme.bodyMedium!.color!.withOpacity(0.65),
              ),
              textAlign: TextAlign.start,
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(vertical: 24),
            padding: EdgeInsets.all(18),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Theme.of(
                    context,
                  ).textTheme.bodyMedium!.color!.withOpacity(0.075),
                ),
                // bottom: BorderSide(color: AppColors.neutral300),
              ),
            ),
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              padding: EdgeInsets.symmetric(vertical: 14),
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 2.5,
              children:
                  _occupationOptions.map((occupation) {
                    final isSelected = occupation == _selectedOccupation;
                    return InkWell(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap:
                          () => setState(() {
                            _selectedOccupation = occupation;
                          }),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color:
                              isSelected
                                  ? Color(0xff5A78F4)
                                  : Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .color!
                                      .withOpacity(0.03),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Theme.of(
                              context,
                            ).textTheme.bodyMedium!.color!.withOpacity(0.1),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(width: 16, height: 16),
                                isSelected
                                    ? SvgPicture.asset(
                                      "assets/icons/svgs/circle-check.svg",
                                      height: 16,
                                      color: AppColors.neutral0,
                                    )
                                    : SizedBox(width: 16, height: 16),
                              ],
                            ),
                            Align(
                              alignment: Alignment.bottomLeft,
                              child: Text(
                                occupation,
                                style: Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.copyWith(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Chirp',
                                  color:
                                      isSelected
                                          ? AppColors.neutral0
                                          : Theme.of(
                                            context,
                                          ).textTheme.bodyMedium!.color,
                                  letterSpacing: -.40,
                                  height: 1,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // Use Case Step
  Widget _buildUseCaseStep() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.only(left: 18, right: 72.0),
            child: Text(
              "How will you use dayfi?",
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontFamily: 'FunnelDisplay',
                fontSize: MediaQuery.of(context).size.width > 600 ? 28 : 24,
                height: 1.000,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 12),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 18),
            child: Text(
              "Select up to 5 ways you plan to use DayFi.",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                fontFamily: 'Chirp',
                letterSpacing: -.25,
                height: 1.2,
                color: Theme.of(
                  context,
                ).textTheme.bodyMedium!.color!.withOpacity(0.65),
              ),
              textAlign: TextAlign.start,
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(vertical: 24),
            padding: EdgeInsets.all(18),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Theme.of(
                    context,
                  ).textTheme.bodyMedium!.color!.withOpacity(0.075),
                ),
                // bottom: BorderSide(color: AppColors.neutral300),
              ),
            ),
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              padding: EdgeInsets.symmetric(vertical: 14),
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 2.5,
              children:
                  _useCaseOptions.map((useCase) {
                    final isSelected = _selectedUseCases.contains(useCase);
                    return InkWell(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap:
                          () => setState(() {
                            if (isSelected) {
                              _selectedUseCases.remove(useCase);
                            } else if (_selectedUseCases.length < 5) {
                              _selectedUseCases.add(useCase);
                            }
                          }),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color:
                              isSelected
                                  ? Color(0xff5A78F4)
                                  : Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .color!
                                      .withOpacity(0.03),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Theme.of(
                              context,
                            ).textTheme.bodyMedium!.color!.withOpacity(0.1),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(width: 16, height: 0),
                                isSelected
                                    ? SvgPicture.asset(
                                      "assets/icons/svgs/circle-check.svg",
                                      height: 16,
                                      color: AppColors.neutral0,
                                    )
                                    : SizedBox(width: 16, height: 0),
                              ],
                            ),
                            Align(
                              alignment: Alignment.bottomLeft,
                              child: Text(
                                useCase,
                                style: Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.copyWith(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Chirp',
                                  color:
                                      isSelected
                                          ? AppColors.neutral0
                                          : Theme.of(
                                            context,
                                          ).textTheme.bodyMedium!.color,
                                  letterSpacing: -.40,
                                  height: 1,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  bool _isStepValid(int step) {
    final state = ref.read(completePersonalInfoProvider);
    switch (step) {
      case 1: // Username
        return _usernameController.text.isNotEmpty;
      case 3: // Country
        return state.country.isNotEmpty && state.countryError.isEmpty;
      case 4: // Phone Number
        return state.phoneNumber.isNotEmpty && state.phoneNumberError.isEmpty;
      case 6: // Use Case
        return _selectedUseCases.isNotEmpty;
      default:
        return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final personalInfoState = ref.watch(completePersonalInfoProvider);
    final personalInfoNotifier = ref.read(
      completePersonalInfoProvider.notifier,
    );
    _updateControllers(personalInfoState);

    // Step indices: 0-Username, 1-DOB, 2-Country, 3-State, 4-City, 5-Address, 6-Phone, 7-Occupation, 8-Use Case
    // REQUIRED for fintech KYC: Username (0), DOB (1), Country (2), Phone (6)
    // OPTIONAL (improves UX): State (3), City (4), Address (5), Occupation (7), Use Case (8)
    final compulsorySteps = <int>{0, 1, 2, 6};
    final optionalSteps = <int>{3, 4, 5, 7, 8};
    final isCurrentStepOptional = optionalSteps.contains(_currentStep);

    // Only enable button if current step is valid (if compulsory), or always if optional
    bool isButtonEnabled;
    if (_currentStep == 0) {
      // Username step: only enable if Dayfi Tag is valid
      isButtonEnabled =
          personalInfoState.isDayfiIdValid && !personalInfoState.isBusy;
    } else if (_currentStep == 1) {
      isButtonEnabled =
          personalInfoState.dateOfBirth.isNotEmpty &&
          personalInfoState.dateOfBirthError.isEmpty &&
          !personalInfoState.isBusy;
    } else if (_currentStep == 2) {
      // Country step: only enable if country is not empty and has no error
      isButtonEnabled =
          personalInfoState.country.isNotEmpty &&
          personalInfoState.countryError.isEmpty &&
          !personalInfoState.isBusy;
    } else if (_currentStep == 3) {
      // State step: optional - always allow continue
      isButtonEnabled = !personalInfoState.isBusy;
    } else if (_currentStep == 4) {
      // City step: optional - always allow continue
      isButtonEnabled = !personalInfoState.isBusy;
    } else if (_currentStep == 5) {
      // Address step: optional - always allow continue
      isButtonEnabled = !personalInfoState.isBusy;
    } else if (_currentStep == 6) {
      final country = personalInfoState.country;

      // Updated & corrected phone rules
      final phoneRules = {
        "Nigeria": {"min": 10, "max": 11, "regex": r"^(0?[789][01]\d{8})$"},
        "Kenya": {"min": 9, "max": 9, "regex": r"^[17]\d{8}$"},
        "South Africa": {"min": 9, "max": 9, "regex": r"^[6-8]\d{8}$"},
        "Botswana": {"min": 8, "max": 8, "regex": r"^[3-7]\d{7}$"},
        "Zambia": {"min": 9, "max": 9, "regex": r"^9\d{8}$"},
        "Rwanda": {"min": 9, "max": 9, "regex": r"^7\d{8}$"},
        "Malawi": {"min": 9, "max": 9, "regex": r"^[2789]\d{8}$"},
        "Tanzania": {"min": 9, "max": 9, "regex": r"^(6|7)\d{8}$"},
        "Uganda": {"min": 9, "max": 9, "regex": r"^7\d{8}$"},
        "Cameroon": {"min": 9, "max": 9, "regex": r"^6\d{8}$"},
        "Benin": {"min": 8, "max": 8, "regex": r"^[24569]\d{7}$"},
        "Côte d’Ivoire": {"min": 8, "max": 8, "regex": r"^[01567]\d{7}$"},
        "Senegal": {"min": 9, "max": 9, "regex": r"^7\d{8}$"},
        "DR Congo": {"min": 9, "max": 9, "regex": r"^[8-9]\d{8}$"},
        "Republic of the Congo": {"min": 9, "max": 9, "regex": r"^[6]\d{8}$"},
        "Gabon": {"min": 8, "max": 8, "regex": r"^[1-7]\d{7}$"},
        "Togo": {"min": 8, "max": 8, "regex": r"^[29]\d{7}$"},
        "Mali": {"min": 8, "max": 8, "regex": r"^[2567]\d{7}$"},
        "Burkina Faso": {"min": 8, "max": 8, "regex": r"^[2456]\d{7}$"},
      };

      final rules =
          phoneRules[country] ?? {"min": 8, "max": 12, "regex": r"^\d+$"};

      final minLength = rules["min"] as int;
      final maxLength = rules["max"] as int;
      final regex = RegExp(rules["regex"] as String);
      final phone = personalInfoState.phoneNumber;

      String? errorMsg;

      if (phone.isNotEmpty) {
        if (!RegExp(r"^\d+$").hasMatch(phone)) {
          errorMsg = "Phone number must be digits only.";
        } else if (phone.length < minLength || phone.length > maxLength) {
          errorMsg = "Phone number must be $minLength to $maxLength digits.";
        } else if (!regex.hasMatch(phone)) {
          errorMsg = "Invalid format.";
        } else {
          errorMsg = "";
        }
      } else {
        errorMsg = "";
      }

      isButtonEnabled =
          phone.isNotEmpty && errorMsg == "" && !personalInfoState.isBusy;
    } else if (_currentStep == 7) {
      // Occupation step: optional - always allow continue
      isButtonEnabled = !personalInfoState.isBusy;
    } else if (_currentStep == 8) {
      // Use Case step: optional - always allow continue
      isButtonEnabled = !personalInfoState.isBusy;
    } else if (compulsorySteps.contains(_currentStep)) {
      isButtonEnabled =
          personalInfoState.isFormValid &&
          !personalInfoState.isBusy &&
          _isStepValid(_currentStep);
    } else {
      isButtonEnabled =
          personalInfoState.isFormValid && !personalInfoState.isBusy;
    }

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: WillPopScope(
        onWillPop: () async => false,
        child: Stack(
          children: [
            Scaffold(
              appBar: AppBar(
                elevation: 0,
                leadingWidth: 72,
                scrolledUnderElevation: .5,
                foregroundColor: Theme.of(context).scaffoldBackgroundColor,
                shadowColor: Theme.of(context).scaffoldBackgroundColor,
                surfaceTintColor: Theme.of(context).scaffoldBackgroundColor,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                leading:
                    _currentStep == 0
                        ? null
                        : InkWell(
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () => _goToStep(_currentStep - 1),
                          child: Stack(
                            alignment: AlignmentGeometry.center,
                            children: [
                              SvgPicture.asset(
                                "assets/icons/svgs/notificationn.svg",
                                height: 40,
                                color: Theme.of(context).colorScheme.surface,
                              ),
                              SizedBox(
                                height: 40,
                                width: 40,
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: Icon(
                                      Icons.arrow_back_ios,
                                      size: 20,
                                      color:
                                          Theme.of(
                                            context,
                                          ).textTheme.bodyLarge!.color,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                title: Image.asset('assets/images/logo_splash.png', height: 24),
                centerTitle: true,
                actions: [
                  StepIndicator(currentStep: _currentStep, steps: _steps),
                ],
              ),
              body: LayoutBuilder(
                builder: (context, constraints) {
                  final bool isWide = constraints.maxWidth > 600;
                  return Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: isWide ? 500 : double.infinity,
                      ),
                      child: SafeArea(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // StepIndicator(currentStep: _currentStep, steps: _steps),
                            Expanded(
                              child: PageView(
                                controller: _pageController,
                                physics: const NeverScrollableScrollPhysics(),
                                children: [
                                  // _buildAvatarStep(Theme.of(context)),
                                  _buildUsernameStep(), // Username
                                  _buildDobStep(
                                    Theme.of(context),
                                  ), // Date of Birth
                                  _buildCountryStep(), // Country
                                  _buildStateField(
                                    personalInfoState,
                                    personalInfoNotifier,
                                  ), // State
                                  _buildCityField(
                                    personalInfoState,
                                    personalInfoNotifier,
                                  ),
                                  _buildAddressField(
                                    personalInfoState,
                                    personalInfoNotifier,
                                  ), // Address
                                  _buildPhoneStep(), // Phone
                                  _buildOccupationStep(), // Occupation
                                  _buildUseCaseStep(), // Use Case
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
              bottomNavigationBar: SafeArea(
                child: AnimatedContainer(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: Theme.of(context).dividerColor.withOpacity(.2),
                        width: 1,
                      ),
                    ),
                  ),
                  duration: const Duration(milliseconds: 10),
                  padding: EdgeInsets.only(
                    left: 18,
                    right: 18,
                    top: 8,
                    bottom:
                        MediaQuery.of(context).viewInsets.bottom > 0
                            ? MediaQuery.of(context).viewInsets.bottom + 8
                            : 8,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 300,
                            child: PrimaryButton(
                                  borderRadius: 38,
                                  text:
                                      _currentStep == _steps.length - 1
                                          ? 'Complete'
                                          : 'Continue',
                                  onPressed:
                                      isButtonEnabled
                                          ? () async {
                                            if (_currentStep == 6) {
                                              FocusManager.instance.primaryFocus
                                                  ?.unfocus();
                                            }
                                            if (_currentStep == 0) {
                                              // Username step: only go next if validated
                                              if (personalInfoState
                                                      .dayfiId
                                                      .isNotEmpty &&
                                                  personalInfoState
                                                      .dayfiIdError
                                                      .isEmpty &&
                                                  personalInfoState
                                                      .isDayfiIdValid) {
                                                _goToStep(_currentStep + 1);
                                              }
                                            } else if (_currentStep <
                                                _steps.length - 1) {
                                              _goToStep(_currentStep + 1);
                                            } else {
                                              log('Submitting personal info...');
                                              // Show loading indicator and call endpoint
                                              if (compulsorySteps.every(
                                                (i) => _isStepValid(i),
                                              )) {
                                                log(
                                                  'All compulsory steps valid. Proceeding to submit...',
                                                );
                                                setState(
                                                  () {},
                                                ); // trigger loading state
                                                await personalInfoNotifier
                                                    .submitPersonalInfo(
                                                      context,
                                                    );
                                              }
                                            }
                                          }
                                          : null,
                                  enabled: isButtonEnabled,
                                  isLoading: personalInfoState.isBusy,
                                  backgroundColor:
                                      isButtonEnabled
                                          ? AppColors.purple500ForTheme(context)
                                          : AppColors.purple500ForTheme(
                                            context,
                                          ).withOpacity(.15),
                                  height: 48.00000,
                                  textColor:
                                      isButtonEnabled
                                          ? AppColors.neutral0
                                          : AppColors.neutral0.withOpacity(.20),
                                  fontFamily: 'Chirp',
                                  letterSpacing: -.70,
                                  fontSize: 18,
                                  fullWidth: true,
                                )
                                .animate()
                                .fadeIn(
                                  delay: 500.ms,
                                  duration: 300.ms,
                                  curve: Curves.easeOutCubic,
                                )
                                .slideY(
                                  begin: 0.2,
                                  end: 0,
                                  delay: 500.ms,
                                  duration: 300.ms,
                                  curve: Curves.easeOutCubic,
                                )
                                .scale(
                                  begin: const Offset(0.95, 0.95),
                                  end: const Offset(1.0, 1.0),
                                  delay: 500.ms,
                                  duration: 300.ms,
                                  curve: Curves.easeOutCubic,
                                ),
                          ),
                        ],
                      ),
                      if (isCurrentStepOptional) SizedBox(height: 12),
                      if (isCurrentStepOptional)
                        TextButton(
                          style: TextButton.styleFrom(
                            // padding: EdgeInsets.zero,
                            // minimumSize: Size(50, 30),
                            splashFactory: NoSplash.splashFactory,
                            backgroundColor: Colors.transparent,
                            foregroundColor: Colors.transparent,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            alignment: Alignment.center,
                          ),
                          onPressed:
                              () =>
                                  isCurrentStepOptional
                                      ? _goToStep(_currentStep + 1)
                                      : null,
                          child: Text(
                            _currentStep == 8 && _selectedUseCases.isNotEmpty
                                ? '${_selectedUseCases.length} of 5 selected! 🎉'
                                : (isCurrentStepOptional
                                    ? 'Skip for now'
                                    : ' '),
                            style: TextStyle(
                              fontFamily: 'Chirp',
                              color:
                                  Theme.of(context).textTheme.bodyLarge!.color,
                              fontSize: _currentStep == 8 ? 16 : 18,
                              fontWeight: FontWeight.w500,
                              letterSpacing: -.40,
                              decoration:
                                  _currentStep == 8
                                      ? TextDecoration.none
                                      : TextDecoration.underline,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            if (personalInfoState.isBusy)
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

  Widget _buildAddressField(
    CompletePersonalInfoState state,
    CompletePersonalInfoNotifier notifier,
  ) {
    // Dynamic label/desc for address field
    String divisionLabel = "State";
    String divisionDesc =
        "Enter your full address including your state of residence.";
    final country = state.country;
    if (country == "Kenya") {
      divisionLabel = "County";
      divisionDesc =
          "Enter your full address including your county of residence.";
    } else if (country == "South Africa") {
      divisionLabel = "Province";
      divisionDesc =
          "Enter your full address including your province of residence.";
    } else if (country == "Botswana") {
      divisionLabel = "District";
      divisionDesc =
          "Enter your full address including your district of residence.";
    } else if (country == "Zambia") {
      divisionLabel = "Province";
      divisionDesc =
          "Enter your full address including your province of residence.";
    } else if (country == "Rwanda") {
      divisionLabel = "Province";
      divisionDesc =
          "Enter your full address including your province of residence.";
    } else if (country == "Malawi") {
      divisionLabel = "Region";
      divisionDesc =
          "Enter your full address including your region of residence.";
    } else if (country == "Tanzania") {
      divisionLabel = "Region";
      divisionDesc =
          "Enter your full address including your region of residence.";
    } else if (country == "Uganda") {
      divisionLabel = "Region";
      divisionDesc =
          "Enter your full address including your region of residence.";
    } else if (country == "Cameroon") {
      divisionLabel = "Region";
      divisionDesc =
          "Enter your full address including your region of residence.";
    } else if (country == "Benin") {
      divisionLabel = "Department";
      divisionDesc =
          "Enter your full address including your department of residence.";
    } else if (country == "Côte d’Ivoire") {
      divisionLabel = "District";
      divisionDesc =
          "Enter your full address including your district of residence.";
    } else if (country == "Senegal") {
      divisionLabel = "Region";
      divisionDesc =
          "Enter your full address including your region of residence.";
    } else if (country == "DR Congo") {
      divisionLabel = "Province";
      divisionDesc =
          "Enter your full address including your province of residence.";
    } else if (country == "Republic of the Congo") {
      divisionLabel = "Department";
      divisionDesc =
          "Enter your full address including your department of residence.";
    } else if (country == "Gabon") {
      divisionLabel = "Province";
      divisionDesc =
          "Enter your full address including your province of residence.";
    } else if (country == "Togo") {
      divisionLabel = "Region";
      divisionDesc =
          "Enter your full address including your region of residence.";
    } else if (country == "Mali") {
      divisionLabel = "Region";
      divisionDesc =
          "Enter your full address including your region of residence.";
    } else if (country == "Burkina Faso") {
      divisionLabel = "Region";
      divisionDesc =
          "Enter your full address including your region of residence.";
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 8),
        Padding(
          padding: EdgeInsets.only(left: 18, right: 72.0),
          child: Text(
            "Street address",
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontFamily: 'FunnelDisplay',
              fontSize: MediaQuery.of(context).size.width > 600 ? 28 : 24,
              height: 1.000,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: 12),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 18),
          child: Text(
            "Enter your residential address.",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              fontFamily: 'Chirp',
              letterSpacing: -.25,
              height: 1.2,
              color: Theme.of(
                context,
              ).textTheme.bodyMedium!.color!.withOpacity(0.65),
            ),
            textAlign: TextAlign.start,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 24, horizontal: 18.0),
          child: CustomTextField(
            label: "Address",
            hintText: "Enter your address",
            controller: _addressController,
            maxLength: 100,
            onChanged: notifier.setAddress,
            textCapitalization: TextCapitalization.words,
            // minLines: 2,
          ),
        ),
        // if (state.addressError.isNotEmpty)
        //   Padding(
        //     padding: const EdgeInsets.only(top: 4.0, left: 18),
        //     child: Text(
        //       state.addressError,
        //       style: const TextStyle(
        //         color: Colors.red,
        //         fontSize: 13,
        //         fontFamily: 'Chirp',
        //         letterSpacing: -.25,
        //         fontWeight: FontWeight.w500,
        //         height: 1.2,
        //       ),
        //     ),
        //   )
        // else
        //   const SizedBox.shrink(),
      ],
    );
  }

  Widget _buildStateField(
    CompletePersonalInfoState state,
    CompletePersonalInfoNotifier notifier,
  ) {
    // Determine the correct label and description based on country
    String divisionLabel = "State";
    String divisionDesc =
        "Select your state of residence to help us customize your experience.";
    final country = state.country;
    if (country == "Kenya") {
      divisionLabel = "County";
      divisionDesc =
          "Select your county of residence to help us customize your experience.";
    } else if (country == "South Africa") {
      divisionLabel = "Province";
      divisionDesc =
          "Select your province of residence to help us customize your experience.";
    } else if (country == "Botswana") {
      divisionLabel = "District";
      divisionDesc =
          "Select your district of residence to help us customize your experience.";
    } else if (country == "Zambia") {
      divisionLabel = "Province";
      divisionDesc =
          "Select your province of residence to help us customize your experience.";
    } else if (country == "Rwanda") {
      divisionLabel = "Province";
      divisionDesc =
          "Select your province of residence to help us customize your experience.";
    } else if (country == "Malawi") {
      divisionLabel = "Region";
      divisionDesc =
          "Select your region of residence to help us customize your experience.";
    } else if (country == "Tanzania") {
      divisionLabel = "Region";
      divisionDesc =
          "Select your region of residence to help us customize your experience.";
    } else if (country == "Uganda") {
      divisionLabel = "Region";
      divisionDesc =
          "Select your region of residence to help us customize your experience.";
    } else if (country == "Cameroon") {
      divisionLabel = "Region";
      divisionDesc =
          "Select your region of residence to help us customize your experience.";
    } else if (country == "Benin") {
      divisionLabel = "Department";
      divisionDesc =
          "Select your department of residence to help us customize your experience.";
    } else if (country == "Côte d’Ivoire") {
      divisionLabel = "District";
      divisionDesc =
          "Select your district of residence to help us customize your experience.";
    } else if (country == "Senegal") {
      divisionLabel = "Region";
      divisionDesc =
          "Select your region of residence to help us customize your experience.";
    } else if (country == "DR Congo") {
      divisionLabel = "Province";
      divisionDesc =
          "Select your province of residence to help us customize your experience.";
    } else if (country == "Republic of the Congo") {
      divisionLabel = "Department";
      divisionDesc =
          "Select your department of residence to help us customize your experience.";
    } else if (country == "Gabon") {
      divisionLabel = "Province";
      divisionDesc =
          "Select your province of residence to help us customize your experience.";
    } else if (country == "Togo") {
      divisionLabel = "Region";
      divisionDesc =
          "Select your region of residence to help us customize your experience.";
    } else if (country == "Mali") {
      divisionLabel = "Region";
      divisionDesc =
          "Select your region of residence to help us customize your experience.";
    } else if (country == "Burkina Faso") {
      divisionLabel = "Region";
      divisionDesc =
          "Select your region of residence to help us customize your experience.";
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 8),
        Padding(
          padding: EdgeInsets.only(left: 18, right: 72.0),
          child: Text(
            "Select your ${divisionLabel.toLowerCase()}",
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontFamily: 'FunnelDisplay',
              fontSize: MediaQuery.of(context).size.width > 600 ? 28 : 24,
              height: 1.000,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: 12),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 18),
          child: Text(
            "Choose your ${divisionLabel.toLowerCase()} for accurate service.",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              fontFamily: 'Chirp',
              letterSpacing: -.25,
              height: 1.2,
              color: Theme.of(
                context,
              ).textTheme.bodyMedium!.color!.withOpacity(0.65),
            ),
            textAlign: TextAlign.start,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 24, horizontal: 18.0),
          child: CustomTextField(
            label: divisionLabel,
            hintText: "Select your ${divisionLabel.toLowerCase()}",
            controller: _stateController,
            onChanged: notifier.setState,
            suffixIcon: Icon(
              Icons.keyboard_arrow_down,
              color: AppColors.neutral400,
              size: 20,
            ),
            shouldReadOnly: true,
            onTap: () => _showStatePicker(notifier),
          ),
        ),
        // if (state.stateError.isNotEmpty)
        //   Padding(
        //     padding: const EdgeInsets.only(top: 4.0, left: 14),
        //     child: Text(
        //       state.stateError,
        //       style: const TextStyle(
        //         color: Colors.red,
        //         fontSize: 13,
        //         fontFamily: 'Chirp',
        //         letterSpacing: -.25,
        //         fontWeight: FontWeight.w500,
        //         height: 1.2,
        //       ),
        //     ),
        //   )
        // else
        //   const SizedBox.shrink(),
      ],
    );
  }

  String _formatDateForDisplay(String isoDate) {
    if (isoDate.isEmpty) return '';

    try {
      final date = DateTime.parse(isoDate);
      return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
    } catch (e) {
      return isoDate; // Return as-is if parsing fails
    }
  }

  void _showDatePicker(CompletePersonalInfoNotifier notifier) async {
    final DateTime? picked = await PlatformDatePicker.showDateOfBirthPicker(
      context: context,
      initialDate: DateTime.now().subtract(
        const Duration(days: 7300), // ~20 years ago as default
      ),
      title: 'Select Date of Birth',
    );

    if (picked != null) {
      // Format date as ISO 8601 (YYYY-MM-DD) for API compatibility
      final formattedDate =
          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      notifier.setDateOfBirth(formattedDate);
    }
  }

  void _showCountryBottomSheet(CompletePersonalInfoNotifier notifier) {
    showModalBottomSheet(
      barrierColor: Colors.black.withOpacity(0.85),
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => _CountryBottomSheet(
            onCountrySelected: (country) {
              notifier.setCountry(country);
              notifier.setState(""); // Clear state
              notifier.setCity(""); // Clear city
              notifier.setAddress(""); // Clear address
              _stateController.clear();
              _cityController.clear();
              _addressController.clear();
              Navigator.pop(context);
            },
          ),
    );
  }

  void _showStatePicker(CompletePersonalInfoNotifier notifier) async {
    final currentState = ref.read(completePersonalInfoProvider);
    final country = currentState.country;
    List<String> states = [];
    if (country == 'Nigeria') {
      states = [
        'Abia',
        'Adamawa',
        'Akwa Ibom',
        'Anambra',
        'Bauchi',
        'Bayelsa',
        'Benue',
        'Borno',
        'Cross River',
        'Delta',
        'Ebonyi',
        'Edo',
        'Ekiti',
        'Enugu',
        'Gombe',
        'Imo',
        'Jigawa',
        'Kaduna',
        'Kano',
        'Katsina',
        'Kebbi',
        'Kogi',
        'Kwara',
        'Lagos',
        'Nasarawa',
        'Niger',
        'Ogun',
        'Ondo',
        'Osun',
        'Oyo',
        'Plateau',
        'Rivers',
        'Sokoto',
        'Taraba',
        'Yobe',
        'Zamfara',
        'Abuja (FCT)',
      ];
    } else if (country == 'Kenya') {
      states = [
        'Baringo',
        'Bomet',
        'Bungoma',
        'Busia',
        'Elgeyo-Marakwet',
        'Embu',
        'Garissa',
        'Homa Bay',
        'Isiolo',
        'Kajiado',
        'Kakamega',
        'Kericho',
        'Kiambu',
        'Kilifi',
        'Kirinyaga',
        'Kisii',
        'Kisumu',
        'Kitui',
        'Kwale',
        'Laikipia',
        'Lamu',
        'Machakos',
        'Makueni',
        'Mandera',
        'Marsabit',
        'Meru',
        'Migori',
        'Mombasa',
        'Murang’a',
        'Nairobi',
        'Nakuru',
        'Nandi',
        'Narok',
        'Nyamira',
        'Nyandarua',
        'Nyeri',
        'Samburu',
        'Siaya',
        'Taita-Taveta',
        'Tana River',
        'Tharaka-Nithi',
        'Trans-Nzoia',
        'Turkana',
        'Uasin Gishu',
        'Vihiga',
        'Wajir',
        'West Pokot',
      ];
    } else if (country == 'South Africa') {
      states = [
        'Eastern Cape',
        'Free State',
        'Gauteng',
        'KwaZulu-Natal',
        'Limpopo',
        'Mpumalanga',
        'Northern Cape',
        'North West',
        'Western Cape',
      ];
    } else if (country == 'Botswana') {
      states = [
        'Central',
        'Chobe',
        'Ghanzi',
        'Kgalagadi',
        'Kgatleng',
        'Kweneng',
        'North-East',
        'North-West',
        'South-East',
        'Southern',
      ];
    } else if (country == 'Zambia') {
      states = [
        'Central',
        'Copperbelt',
        'Eastern',
        'Luapula',
        'Lusaka',
        'Muchinga',
        'Northern',
        'North-Western',
        'Southern',
        'Western',
      ];
    } else if (country == 'Rwanda') {
      states = ['Kigali', 'Eastern', 'Northern', 'Western', 'Southern'];
    } else if (country == 'Malawi') {
      states = ['Northern', 'Central', 'Southern'];
    } else if (country == 'Tanzania') {
      states = [
        'Arusha',
        'Dar es Salaam',
        'Dodoma',
        'Geita',
        'Iringa',
        'Kagera',
        'Katavi',
        'Kigoma',
        'Kilimanjaro',
        'Lindi',
        'Manyara',
        'Mara',
        'Mbeya',
        'Morogoro',
        'Mtwara',
        'Mwanza',
        'Njombe',
        'Pemba North',
        'Pemba South',
        'Pwani',
        'Rukwa',
        'Ruvuma',
        'Shinyanga',
        'Simiyu',
        'Singida',
        'Tabora',
        'Tanga',
        'Zanzibar North',
        'Zanzibar South',
        'Zanzibar Urban/West',
      ];
    } else if (country == 'Uganda') {
      states = ['Central', 'Eastern', 'Northern', 'Western'];
    } else if (country == 'Cameroon') {
      states = [
        'Adamawa',
        'Centre',
        'East',
        'Far North',
        'Littoral',
        'North',
        'North-West',
        'West',
        'South',
        'South-West',
      ];
    } else if (country == 'Benin') {
      states = [
        'Alibori',
        'Atakora',
        'Atlantique',
        'Borgou',
        'Collines',
        'Donga',
        'Kouffo',
        'Littoral',
        'Mono',
        'Ouémé',
        'Plateau',
        'Zou',
      ];
    } else if (country == 'Côte d’Ivoire') {
      states = [
        'Abidjan',
        'Bas-Sassandra',
        'Comoé',
        'Denguélé',
        'Gôh-Djiboua',
        'Lacs',
        'Lagunes',
        'Montagnes',
        'Savanes',
        'Sassandra-Marahoué',
        'Vallée du Bandama',
        'Woroba',
        'Yamoussoukro',
        'Zanzan',
      ];
    } else if (country == 'Senegal') {
      states = [
        'Dakar',
        'Diourbel',
        'Fatick',
        'Kaolack',
        'Kédougou',
        'Kolda',
        'Louga',
        'Matam',
        'Saint-Louis',
        'Sédhiou',
        'Tambacounda',
        'Thiès',
        'Ziguinchor',
      ];
    } else if (country == 'DR Congo') {
      states = [
        'Bas-Uele',
        'Haut-Uele',
        'Ituri',
        'Tshopo',
        'Haut-Lomami',
        'Haut-Katanga',
        'Kasaï',
        'Kasaï-Central',
        'Kasaï-Oriental',
        'Kwango',
        'Kwilu',
        'Mai-Ndombe',
        'Maniema',
        'Mongala',
        'Nord-Kivu',
        'Nord-Ubangi',
        'Sud-Kivu',
        'Sud-Ubangi',
        'Tanganyika',
        'Tshuapa',
        'Équateur',
      ];
    } else if (country == 'Republic of the Congo') {
      states = [
        'Bouenza',
        'Brazzaville',
        'Cuvette',
        'Cuvette-Ouest',
        'Kouilou',
        'Lekoumou',
        'Likouala',
        'Niari',
        'Plateaux',
        'Pointe-Noire',
        'Sangha',
        'Pool',
      ];
    } else if (country == 'Gabon') {
      states = [
        'Estuaire',
        'Haut-Ogooué',
        'Moyen-Ogooué',
        'Ngounié',
        'Nyanga',
        'Ogooué-Ivindo',
        'Ogooué-Lolo',
        'Ogooué-Maritime',
        'Woleu-Ntem',
      ];
    } else if (country == 'Togo') {
      states = ['Centrale', 'Kara', 'Maritime', 'Plateaux', 'Savanes'];
    } else if (country == 'Mali') {
      states = [
        'Bamako',
        'Gao',
        'Kayes',
        'Kidal',
        'Koulikoro',
        'Mopti',
        'Ségou',
        'Sikasso',
        'Tombouctou',
        'Taoudénit',
        'Ménaka',
        'Kéniéba',
      ];
    } else if (country == 'Burkina Faso') {
      states = [
        'Boucle du Mouhoun',
        'Cascades',
        'Centre',
        'Centre-Est',
        'Centre-Nord',
        'Centre-Ouest',
        'Centre-Sud',
        'Est',
        'Hauts-Bassins',
        'Nord',
        'Plateau-Central',
        'Sahel',
        'Sud-Ouest',
      ];
    }
    // Add more countries as needed

    showModalBottomSheet(
      barrierColor: Colors.black.withOpacity(0.85),
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.92,
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              SizedBox(height: 18),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 18),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(height: 24, width: 24),
                    Text(
                      'Select State',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontFamily: 'Chirp',
                        fontSize: 16,
                        letterSpacing: -.25,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Image.asset(
                        "assets/icons/pngs/cancelicon.png",
                        height: 24,
                        width: 24,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 18),
                  itemCount: states.length,
                  itemBuilder: (context, index) {
                    final stateName = states[index];
                    return ListTile(
                      contentPadding: EdgeInsets.symmetric(vertical: 4),
                      onTap: () {
                        notifier.setState(stateName);
                        notifier.setCity(""); // Clear city when state changes
                        notifier.setAddress(
                          "",
                        ); // Clear address when state changes
                        _cityController.clear();
                        _addressController.clear();
                        Navigator.pop(context);
                        _stateController.text = stateName;
                      },
                      title: Text(
                        stateName,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontFamily: 'Chirp',
                          fontSize: 18,
                          letterSpacing: -.25,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Country Bottom Sheet
class _CountryBottomSheet extends StatefulWidget {
  final Function(String) onCountrySelected;

  const _CountryBottomSheet({required this.onCountrySelected});

  @override
  State<_CountryBottomSheet> createState() => _CountryBottomSheetState();
}

class _CountryBottomSheetState extends State<_CountryBottomSheet> {
  final List<Map<String, String>> _countries = [
    // ...existing country maps...
    {
      'name': 'Nigeria',
      'code': 'NG',
      'flag': 'assets/icons/svgs/world_flags/nigeria.svg',
      'api': 'Yellow Card Payments API',
      'dial_code': '+234',
    },
    {
      'name': 'Kenya',
      'code': 'KE',
      'flag': 'assets/icons/svgs/world_flags/kenya.svg',
      'api': 'Yellow Card Payments API',
      'dial_code': '+254',
    },
    {
      'name': 'South Africa',
      'code': 'ZA',
      'flag': 'assets/icons/svgs/world_flags/south africa.svg',
      'api': 'Yellow Card Payments API',
      'dial_code': '+27',
    },
    {
      'name': 'Botswana',
      'code': 'BW',
      'flag': 'assets/icons/svgs/world_flags/botswana.svg',
      'api': 'Yellow Card Payments API',
      'dial_code': '+267',
    },
    {
      'name': 'Zambia',
      'code': 'ZM',
      'flag': 'assets/icons/svgs/world_flags/zambia.svg',
      'api': 'Yellow Card Payments API',
      'dial_code': '+260',
    },
    {
      'name': 'Rwanda',
      'code': 'RW',
      'flag': 'assets/icons/svgs/world_flags/rwanda.svg',
      'api': 'Yellow Card Payments API',
      'dial_code': '+250',
    },
    {
      'name': 'Malawi',
      'code': 'MW',
      'flag': 'assets/icons/svgs/world_flags/malawi.svg',
      'api': 'Yellow Card Payments API',
      'dial_code': '+265',
    },
    {
      'name': 'Tanzania',
      'code': 'TZ',
      'flag': 'assets/icons/svgs/world_flags/tanzania.svg',
      'api': 'Yellow Card Payments API',
      'dial_code': '+255',
    },
    {
      'name': 'Uganda',
      'code': 'UG',
      'flag': 'assets/icons/svgs/world_flags/uganda.svg',
      'api': 'Yellow Card Payments API',
      'dial_code': '+256',
    },
    {
      'name': 'Cameroon',
      'code': 'CM',
      'flag': 'assets/icons/svgs/world_flags/cameroon.svg',
      'api': 'Yellow Card Payments API',
      'dial_code': '+237',
    },
    {
      'name': 'Benin',
      'code': 'BJ',
      'flag': 'assets/icons/svgs/world_flags/benin.svg',
      'api': 'Yellow Card Payments API',
      'dial_code': '+229',
    },
    {
      'name': 'Côte d’Ivoire',
      'code': 'CI',
      'flag': 'assets/icons/svgs/world_flags/ivory coast.svg',
      'api': 'Yellow Card Payments API',
      'dial_code': '+225',
    },
    {
      'name': 'Senegal',
      'code': 'SN',
      'flag': 'assets/icons/svgs/world_flags/senegal.svg',
      'api': 'Yellow Card Payments API',
      'dial_code': '+221',
    },
    {
      'name': 'Republic of the Congo',
      'code': 'CG',
      'flag': 'assets/icons/svgs/world_flags/republic of the congo.svg',
      'api': 'Yellow Card Payments API',
      'dial_code': '+242',
    },
    {
      'name': 'Gabon',
      'code': 'GA',
      'flag': 'assets/icons/svgs/world_flags/gabon.svg',
      'api': 'Yellow Card Payments API',
      'dial_code': '+241',
    },
    {
      'name': 'Togo',
      'code': 'TG',
      'flag': 'assets/icons/svgs/world_flags/togo.svg',
      'api': 'Yellow Card Payments API',
      'dial_code': '+228',
    },
    {
      'name': 'Mali',
      'code': 'ML',
      'flag': 'assets/icons/svgs/world_flags/mali.svg',
      'api': 'Yellow Card Payments API',
      'dial_code': '+223',
    },
    {
      'name': 'Burkina Faso',
      'code': 'BF',
      'flag': 'assets/icons/svgs/world_flags/burkina faso.svg',
      'api': 'Yellow Card Payments API',
      'dial_code': '+226',
    },
  ];

  @override
  void initState() {
    super.initState();
    _countries.sort((a, b) => a['name']!.compareTo(b['name']!));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.92,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          SizedBox(height: 18),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(height: 24, width: 24),
                Text(
                  'Select Country',
                  style: AppTypography.titleLarge.copyWith(
                    fontFamily: 'Chirp',
                    fontSize: 16,
                    letterSpacing: -.25,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Image.asset(
                    "assets/icons/pngs/cancelicon.png",
                    height: 24,
                    width: 24,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 18),
              itemCount: _countries.length,
              itemBuilder: (context, index) {
                final country = _countries[index];
                return ListTile(
                  contentPadding: EdgeInsets.symmetric(vertical: 4),
                  onTap: () => widget.onCountrySelected(country['name']!),
                  title: Row(
                    children: [
                      SvgPicture.asset(country['flag']!, height: 24.000),
                      SizedBox(width: 12),
                      Text(
                        country['name']!,
                        style: AppTypography.bodyLarge.copyWith(
                          fontFamily: 'Chirp',
                          fontSize: 18,
                          letterSpacing: -.25,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  trailing: Text(
                    country['code']!,
                    style: AppTypography.bodyLarge.copyWith(
                      fontFamily: 'Chirp',
                      fontSize: 14,
                      letterSpacing: -.25,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Occupation Bottom Sheet
class _OccupationBottomSheet extends StatefulWidget {
  final Function(String) onOccupationSelected;

  const _OccupationBottomSheet({required this.onOccupationSelected});

  @override
  State<_OccupationBottomSheet> createState() => _OccupationBottomSheetState();
}

class _OccupationBottomSheetState extends State<_OccupationBottomSheet> {
  final List<Map<String, String>> _occupations = [
    {'emoji': '💻', 'name': 'Technology'},
    {'emoji': '💰', 'name': 'Finance & Banking'},
    {'emoji': '🏥', 'name': 'Healthcare'},
    {'emoji': '🎓', 'name': 'Education'},
    {'emoji': '📈', 'name': 'Marketing & Advertising'},
    {'emoji': '🏗️', 'name': 'Engineering'},
    {'emoji': '⚖️', 'name': 'Legal'},
    {'emoji': '🏢', 'name': 'Business & Management'},
    {'emoji': '🎨', 'name': 'Creative & Design'},
    {'emoji': '📺', 'name': 'Media & Entertainment'},
    {'emoji': '🛒', 'name': 'Retail & Sales'},
    {'emoji': '🍽️', 'name': 'Food & Hospitality'},
    {'emoji': '🚗', 'name': 'Transportation & Logistics'},
    {'emoji': '🏠', 'name': 'Real Estate'},
    {'emoji': '🏛️', 'name': 'Government & Public Service'},
    {'emoji': '🤝', 'name': 'Consulting'},
    {'emoji': '👥', 'name': 'Human Resources'},
    {'emoji': '🎯', 'name': 'Customer Service'},
    {'emoji': '🏭', 'name': 'Manufacturing'},
    {'emoji': '🌱', 'name': 'Agriculture'},
    {'emoji': '🔬', 'name': 'Science & Research'},
    {'emoji': '✈️', 'name': 'Travel & Tourism'},
    {'emoji': '💼', 'name': 'Administrative'},
    {'emoji': '🔧', 'name': 'Skilled Trades'},
    {'emoji': '🎪', 'name': 'Entertainment & Sports'},
    {'emoji': '🌍', 'name': 'Non-profit & NGO'},
    {'emoji': '🏪', 'name': 'Entrepreneur'},
    {'emoji': '📚', 'name': 'Student'},
    {'emoji': '🏠', 'name': 'Homemaker'},
    {'emoji': '❓', 'name': 'Other'},
  ];

  List<Map<String, String>> _filteredOccupations = [];

  @override
  void initState() {
    super.initState();
    _filteredOccupations = _occupations;
  }

  void _filterOccupations(String query) {
    setState(() {
      _filteredOccupations =
          _occupations
              .where(
                (occupation) => occupation['name']!.toLowerCase().contains(
                  query.toLowerCase(),
                ),
              )
              .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.92,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          SizedBox(height: 18),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(height: 24, width: 24),
                Text(
                  'Select Occupation',
                  style: AppTypography.titleLarge.copyWith(
                    fontFamily: 'FunnelDisplay',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () => Navigator.pop(context),
                  child: Stack(
                    alignment: AlignmentGeometry.center,
                    children: [
                      SvgPicture.asset(
                        "assets/icons/svgs/notificationn.svg",
                        height: 40,
                        color: Theme.of(context).colorScheme.surface,
                      ),
                      SizedBox(
                        height: 40,
                        width: 40,
                        child: Center(
                          child: Image.asset(
                            "assets/icons/pngs/cancelicon.png",
                            height: 20,
                            width: 20,
                            color: Theme.of(context).textTheme.bodyLarge!.color,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                // Search field
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                  child: CustomTextField(
                    isSearch: true,
                    onChanged: (value) => _filterOccupations(value),
                    hintText: 'Search occupations...',
                    prefixIcon: Container(
                      width: 40,
                      alignment: Alignment.centerRight,
                      constraints: BoxConstraints.tightForFinite(),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SvgPicture.asset(
                            'assets/icons/svgs/swap.svg',
                            height: 34,
                            color: AppColors.neutral700.withOpacity(.35),
                          ),
                          Center(
                            child: SvgPicture.asset(
                              'assets/icons/svgs/search-normal.svg',
                              height: 26,
                              color: AppColors.neutral700.withOpacity(.65),
                            ),
                          ),
                        ],
                      ),
                    ),
                    borderRadius: 40,
                  ),
                ),
                // Occupations list
                Expanded(
                  child:
                      _filteredOccupations.isEmpty
                          ? Center(
                            child: Text(
                              'No occupations found',
                              style: AppTypography.bodyLarge.copyWith(
                                fontFamily: 'Chirp',
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                          )
                          : ListView.builder(
                            padding: EdgeInsets.symmetric(horizontal: 18),
                            itemCount: _filteredOccupations.length,
                            itemBuilder: (context, index) {
                              final occupation = _filteredOccupations[index];
                              return ListTile(
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 4,
                                ),
                                onTap:
                                    () => widget.onOccupationSelected(
                                      occupation['name']!,
                                    ),
                                title: Row(
                                  children: [
                                    Text(
                                      occupation['emoji']!,
                                      style: TextStyle(fontSize: 24),
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        occupation['name']!,
                                        style: AppTypography.bodyLarge.copyWith(
                                          fontFamily: 'Chirp',
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// City Bottom Sheet
class _CityBottomSheet extends StatelessWidget {
  final List<String> cities;
  final Function(String) onCitySelected;

  const _CityBottomSheet({required this.cities, required this.onCitySelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.92,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          SizedBox(height: 18),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(height: 24, width: 24),
                Text(
                  'Select City',
                  style: AppTypography.titleLarge.copyWith(
                    fontFamily: 'Chirp',
                    fontSize: 16,
                    letterSpacing: -.25,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Image.asset(
                    "assets/icons/pngs/cancelicon.png",
                    height: 24,
                    width: 24,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 18),
              itemCount: cities.length,
              itemBuilder: (context, index) {
                final city = cities[index];
                return ListTile(
                  contentPadding: EdgeInsets.symmetric(vertical: 4),
                  onTap: () => onCitySelected(city),
                  title: Text(
                    city,
                    style: AppTypography.bodyLarge.copyWith(
                      fontFamily: 'Chirp',
                      fontSize: 18,
                      letterSpacing: -.25,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Simple step indicator widget
class StepIndicator extends StatelessWidget {
  final int currentStep;
  final List<String> steps;
  const StepIndicator({
    super.key,
    required this.currentStep,
    required this.steps,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0),
        child: Text(
          'Step ${currentStep + 1} of ${steps.length}',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            fontFamily: 'Chirp',
            letterSpacing: -.25,
            height: 1.2,
            color: Theme.of(
              context,
            ).textTheme.bodyMedium!.color!.withOpacity(0.65),
          ),
        ),
      ),
    );
  }
}
