import 'dart:async';
import 'package:flutter/services.dart';
import 'package:dayfi/data/models/wallet_reponse.dart';
import 'package:dayfi/data/storage/secure_storage_service.dart';
import 'package:dayfi/services/api/auth_api_service.dart';
import 'package:dayfi/ui/components/buttons/filled_btn.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:dayfi/ui/components/input_fields/custom_text_field.dart';
import 'package:dayfi/ui/views/home/bottom_sheets/create_dayfi_id_bottomsheet.dart';
import 'package:dayfi/ui/views/home/bottom_sheets/success_bottomsheet.dart';
import 'package:dayfi/ui/views/home/home_viewmodel.dart';
import 'package:stacked_services/stacked_services.dart' show DialogService;

class DayfiIDBottomSheet extends StatefulWidget {
  final HomeViewModel viewModel;
  final Wallet wallet;

  const DayfiIDBottomSheet(
      {super.key, required this.viewModel, required this.wallet});
  @override
  // ignore: library_private_types_in_public_api
  _DayfiIDBottomSheetState createState() => _DayfiIDBottomSheetState();
}

class _DayfiIDBottomSheetState extends State<DayfiIDBottomSheet> {
  String? userDayfiId;
  final _apiService = AuthApiService();
  final _dialogService = DialogService();

  String selectedPaymentMethod = "";
  String get counterLabel => 'Counter is: $counter';

  int counter = 0;

  String dayfiId = '';
  // String get dayfiId => _dayfiId;

  String? dayfiIdErr;
  String? dayfiIdRes;
  Timer? _debounceTimer;
  String? get dayfiIdError => dayfiIdErr;
  String? get dayfiIdResponse => dayfiIdRes;

  @override
  void initState() {
    super.initState();
    _checkDayfiId();
  }

  Future<void> _checkDayfiId() async {
    // Simulate checking if user has a Dayfi ID (replace with actual API call)
    setState(() {
      userDayfiId =
          null; // Set to null if no ID, or a value like '@kolols' if exists
    });
  }

  bool get isFormValid =>
      dayfiId.isNotEmpty &&
      dayfiIdErr == null &&
      dayfiIdRes != null &&
      !dayfiIdRes!.contains('User not found');

  bool get isDayfiIdValid =>
      dayfiId.isNotEmpty && dayfiId.startsWith('@') && dayfiId.length >= 3;

  void setDayfiId(String value) {
    String newValue = value.trim();
    // Ensure single @ prefix and preserve character order
    if (newValue.isNotEmpty) {
      newValue = newValue.replaceAll('@', ''); // Remove all @ symbols
      newValue = '@$newValue'; // Add single @ prefix
    } else {
      newValue = '';
    }
    // Only update if the value has changed
    if (newValue != dayfiId) {
      setState(() {
        dayfiId = newValue;
        dayfiIdErr = _validateDayfiId(newValue);
      });

      // Cancel existing debounce timer
      _debounceTimer?.cancel();

      // Only validate if input is valid
      if (dayfiIdErr == null && isDayfiIdValid) {
        _debounceTimer = Timer(const Duration(milliseconds: 500), () {
          validateDayfiId(newValue);
        });
      } else {
        setState(() {
          dayfiIdRes = null;
        });
      }
    }
  }

  Future<void> validateDayfiId(String dayfiId) async {
    // setBusy(true);
    try {
      final response = await _apiService.validateDayfiId(dayfiId: dayfiId);

      if (response.code == 200) {
        dayfiIdRes = 'This username belongs to ${response.data.accountName}';
        dayfiIdErr = null;
      } else {
        dayfiIdRes = 'User not found';
        dayfiIdErr = 'Invalid Dayfi ID';
      }
    } catch (e) {
      dayfiIdRes = 'User not found';
      dayfiIdErr = 'Error validating Dayfi ID';

      // await _dialogService.showDialog(
      //   title: 'Error',
      //   description: e.toString(),
      // );
    }
    // setBusy(false);
    // notifyListeners();
  }

  String? _validateDayfiId(String value) {
    value = value.trim();
    if (value.isEmpty) return 'Dayfi ID is required';
    if (!value.startsWith('@')) return 'Dayfi ID must start with @';
    if (value.length < 3) return 'Dayfi ID must be at least 3 characters';
    return null;
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<void> _createDayfiId(String dayfiId) async {
    // User? user;

    final SecureStorageService secureStorage = SecureStorageService();

    final userJson = await secureStorage.read('user');
    if (userJson != null) {
      // setState(() {
      //   user = User.fromJson(json.decode(userJson));
      // });
    }

    try {
      final response = await _apiService.createDayfiId(dayfiId: dayfiId);

      if (response.code == 200) {
        setState(() {
          userDayfiId = '@$dayfiId';
        });
        _showSuccessBottomSheet(context);
      }
    } catch (e) {
      print(e.toString());
      await _dialogService.showDialog(
        title: 'Error',
        description: e.toString(),
      );
    }
  }

  void _showCreateDayfiSheet() {
    showModalBottomSheet(
      context: context,
      barrierColor: const Color(0xff5645F5).withOpacity(0.5),
      isDismissible: false,
      isScrollControlled: true,
      enableDrag: false,
      // sheetAnimationStyle: AnimationStyle(
      //     duration: Duration.zero), // Set animation duration to zero
      elevation: 0,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28.00))),
      builder: (context) => CreateDayfiIDSheet(
        onCreate: _createDayfiId,
        viewModel: widget.viewModel,
      ),
    );
  }

  void _showSuccessBottomSheet(BuildContext context) {
    showModalBottomSheet(
      barrierColor: const Color(0xff5645F5).withOpacity(0.5),
      context: context,
      isDismissible: false,
      enableDrag: false,
      // sheetAnimationStyle: AnimationStyle(
      //     duration: Duration.zero), // Set animation duration to zero
      isScrollControlled: false,
      elevation: 0,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28.00))),
      builder: (context) => SuccessBottomSheet(dayfiId: userDayfiId!),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(28.00), topRight: Radius.circular(28.00)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              width: 88,
              height: 4,
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: Theme.of(context)
                    .textTheme
                    .bodyLarge!
                    .color!
                    .withOpacity(0.25),
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.01),
          Align(
            alignment: Alignment.centerRight,
            child: InkWell(
              onTap: () => {Navigator.pop(context)},
              child: SvgPicture.asset(
                'assets/svgs/close_24dp_1F1F1F_FILL0_wght400_GRAD0_opsz24.svg',
                color: const Color(0xff5645F5), // innit
                height: 28.00,
              ),
            ),
          ),
          // SizedBox(height: MediaQuery.of(context).size.height * 0.01),
          Container(
            // padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                buildBottomSheetHeader(
                  context,
                  title: "Via Dayfi-ID",
                  subtitle:
                      "Easily receive funds from your peers by copying your Dayfi ID",
                ),
                widget.wallet.dayfiId != null &&
                        widget.wallet.dayfiId!.isNotEmpty
                    ? _buildDayfiIdContent()
                    : _buildNoDayfiIdContent(),
              ],
            ),
          )
        ],
      ),
    );
  }

  Column _buildDayfiIdContent() {
    return Column(
      children: [
        const SizedBox(height: 18),
        CustomTextField(
          label: "dayfi ID",
          hintText: "",
          enableInteractiveSelection: false,
          shouldReadOnly: true,
          controller: TextEditingController(text: "Username"),
          onChanged: (value) {},
          keyboardType: TextInputType.number,
          suffixIcon: Container(
            constraints: const BoxConstraints.tightForFinite(),
            margin: const EdgeInsets.symmetric(
              vertical: 12.0,
              horizontal: 10.0,
            ),
            height: 32,
            child: GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: widget.wallet.dayfiId!));
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.copy,
                    color: Color(0xff5645F5), // innit
                    size: 20,
                  ),
                  SizedBox(width: 3),
                  Text(
                    "@${widget.wallet.dayfiId}",
                    style: TextStyle(
                      fontFamily: 'Karla',
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      letterSpacing: 0.00,
                      height: 1.450,
                      color: Color(0xff5645F5), // innit
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 48),
        FilledBtn(
          onPressed: () => widget.viewModel.navigationService.back(),
          text: 'Okay, close',
          backgroundColor: const Color(0xff5645F5),
        ),
        SizedBox(height: 20),
        FilledBtn(
          onPressed: () {},
          text: 'Do you need help?',
          backgroundColor: Colors.transparent,
          textColor: Color(0xff5645F5), // innit
        ),
        SizedBox(height: 20),
      ],
    );
  }

  Column _buildNoDayfiIdContent() {
    return Column(
      children: [
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(12),
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xffF6F5FE),
            borderRadius: BorderRadius.circular(4),
            border:
                Border.all(color: const Color(0xff2A0079).withOpacity(0.99)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/images/idea.png",
                  height: 22,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Your Dayfi tag for receiving payments hasn\'t been created yet. Click the button below to create your tag and start receiving money!',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                      height: 1.5,
                      color: Color(0xff5645F5), // innit
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 16),
        FilledBtn(
          onPressed: _showCreateDayfiSheet,
          text: 'Create Dayfi tag',
          backgroundColor: const Color(0xff5645F5),
        ),
        SizedBox(height: 20),
        FilledBtn(
          onPressed: () {},
          text: 'Do you need help?',
          backgroundColor: Colors.transparent,
          textColor: Color(0xff5645F5), // innit
        ),
        SizedBox(height: 20),
      ],
    );
  }
}
