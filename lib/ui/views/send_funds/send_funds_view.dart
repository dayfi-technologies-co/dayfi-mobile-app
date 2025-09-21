import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// // import 'package:google_fonts/google_fonts.dart';
import 'package:stacked/stacked.dart';
import 'package:dayfi/ui/views/send_funds/send_funds_viewmodel.dart';

/// Constants for spacing and styling
const _verticalSpaceTiny = SizedBox(height: 4);
const _verticalSpaceMedium = SizedBox(height: 16);
const _verticalSpaceLarge = SizedBox(height: 24);
const _horizontalPadding = EdgeInsets.symmetric(horizontal: 24);
const _cardMargin = EdgeInsets.symmetric(horizontal: 24);

dynamic _titleStyle = TextStyle(
    fontSize: 19,
    color: Color(0xFF151515),
    fontFamily: 'Karla',
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3);

dynamic _labelStyle = TextStyle(
  fontSize: 12.5,
  fontFamily: 'Karla',
  fontWeight: FontWeight.w600,
  color: Color(0xFF797979),
  letterSpacing: -0.2,
);

dynamic _valueStyle = TextStyle(
    fontSize: 12.5,
    fontFamily: 'Karla',
    fontWeight: FontWeight.w600,
    color: Colors.black,
    letterSpacing: 0.3);

dynamic _valueGreenStyle = TextStyle(
    fontSize: 12.5,
    fontFamily: 'Karla',
    fontWeight: FontWeight.w600,
    color: Color(0xFF63C59F),
    letterSpacing: 0.3);

const wallets = [
  {'amount': '\$0', 'currency': 'USD', 'pageIndex': 0},
  {'amount': '£0', 'currency': 'GBP', 'pageIndex': 1},
  {'amount': 'NGN0', 'currency': 'NGN', 'pageIndex': 2},
];

/// View for the "Send Funds" screen
class SendFundsView extends StackedView<SendFundsViewModel> {
  final String currency;
  final String userIcon;
  final String name;
  final String username;
  final String sendFundType;

  const SendFundsView({
    super.key,
    required this.currency,
    required this.userIcon,
    required this.name,
    required this.username,
    required this.sendFundType,
  });

  @override
  Widget builder(
    BuildContext context,
    SendFundsViewModel viewModel,
    Widget? child,
  ) {
    return _MainContentWrapper(
      viewModel: viewModel,
      currency: currency,
      userIcon: userIcon,
      name: name,
      username: username,
      sendFundType: sendFundType,
    );
  }

  @override
  SendFundsViewModel viewModelBuilder(BuildContext context) =>
      SendFundsViewModel();
}

/// Stateful wrapper to manage animation state
class _MainContentWrapper extends StatefulWidget {
  final SendFundsViewModel viewModel;
  final String currency;
  final String userIcon;
  final String name;
  final String username;
  final String sendFundType;

  const _MainContentWrapper({
    required this.viewModel,
    required this.currency,
    required this.userIcon,
    required this.name,
    required this.username,
    required this.sendFundType,
  });

  @override
  _MainContentWrapperState createState() => _MainContentWrapperState();
}

class _MainContentWrapperState extends State<_MainContentWrapper> {
  bool _isUserInfoVisible = true;
  OverlayEntry? _overlayEntry;

  Map<String, dynamic> _selectedWallet = {
    'amount': 'NGN234,287',
    'currency': 'NGN',
    'pageIndex': 2
  };

  void _toggleUserInfoVisibilityToFalse() {
    setState(() {
      _isUserInfoVisible = false;
    });
    _removeOverlay();
  }

  void _showWalletDropdown(BuildContext context, GlobalKey selectorKey) {
    _removeOverlay(); // Remove any existing overlay

    final RenderBox renderBox =
        selectorKey.currentContext!.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          // Transparent background to dismiss overlay on tap
          GestureDetector(
            onTap: _removeOverlay,
            child: Container(
              color: Colors.transparent,
            ),
          ),
          Positioned(
            left: position.dx,
            top: position.dy + size.height + 4,
            width: 144,
            child: Material(
              elevation: 0,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 7),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: const Color(0xFFF6F6F6),
                ),
                child: Column(
                  children: wallets
                      .map(
                        (wallet) => InkWell(
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          onTap: () {
                            setState(() {
                              _selectedWallet = wallet;
                              widget.viewModel.backToZero();
                            });
                            _removeOverlay();
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Image.asset(
                                      wallet['currency'] as String == 'USD'
                                          ? "assets/images/united-states.png"
                                          : wallet['currency'] as String ==
                                                  'GBP'
                                              ? "assets/images/united-kingdom.png"
                                              : "assets/images/nigeria.png",
                                      width: 14,
                                      height: 14,
                                    ),
                                    const SizedBox(width: 4),
                                    RichText(
                                      text: TextSpan(
                                        text: wallet['currency'] as String,
                                        style: TextStyle(
                                            fontSize: 9,
                                            color: Color(0xFF858585),
                                            fontFamily: 'Karla',
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0.3),
                                      ),
                                    ),
                                  ],
                                ),
                                RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(
                                    text: wallet['currency'] as String == 'USD'
                                        ? wallet['amount'].toString()[0]
                                        : wallet['currency'] as String == 'GBP'
                                            ? wallet['amount'].toString()[0]
                                            : wallet['amount'].toString()[0],
                                    style: TextStyle(
                                        fontFamily: 'Karla',
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black,
                                        letterSpacing: 0.3),
                                    children: [
                                      TextSpan(
                                        text: wallet['currency'] as String ==
                                                'USD'
                                            ? wallet['amount']
                                                .toString()
                                                .replaceAll('\$', "")
                                            : wallet['currency'] as String ==
                                                    'GBP'
                                                ? wallet['amount']
                                                    .toString()
                                                    .replaceAll('£', "")
                                                : wallet['amount']
                                                    .toString()
                                                    .replaceAll('NGN', ""),
                                        style: _valueStyle,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey selectorKey = GlobalKey(); // Key for currency selector

    return WillPopScope(
      onWillPop: () async {
        if (!_isUserInfoVisible) {
          setState(() {
            _isUserInfoVisible = true;
            widget.viewModel.backToZero();
          });
          return false;
        } else {
          widget.viewModel.navigationService.back();
          return true;
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  _verticalSpaceMedium,
                  _buildHeader(widget.viewModel),
                  _verticalSpaceLarge,
                  _verticalSpaceMedium,
                  _buildCurrencySelector(widget.viewModel, selectorKey),
                  widget.sendFundType == "dayfiMate"
                      ? AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                          height: _isUserInfoVisible ? 230 : 0,
                          child: SingleChildScrollView(
                            physics: const NeverScrollableScrollPhysics(),
                            child: Column(
                              children: [
                                _verticalSpaceMedium,
                                _verticalSpaceMedium,
                                _buildUserAvatar(),
                                _verticalSpaceTiny,
                                _buildUserName(),
                                _verticalSpaceMedium,
                                _verticalSpaceTiny,
                                _buildUsernameCard(),
                                const SizedBox(height: 8),
                              ],
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                  _buildTransactionDetailsCard(),
                  _verticalSpaceMedium,
                ],
              ),
              _buildAmountDisplay(widget.viewModel),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                height: _isUserInfoVisible ? 0 : 350,
                child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: _buildKeypad(widget.viewModel),
                ),
              ),
              const SizedBox.shrink(),
              const SizedBox.shrink(),
              _buildSendButton(),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the header with back button, title, and close button
  Widget _buildHeader(SendFundsViewModel viewModel) {
    return Padding(
      padding: _horizontalPadding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildIconButton(
            icon: Icons.arrow_back_ios,
            onTap: _isUserInfoVisible
                ? widget.viewModel.navigationService.back
                : () {
                    setState(() {
                      _isUserInfoVisible = true;
                      widget.viewModel.backToZero();
                    });
                  },
          ),
          RichText(
            text: TextSpan(
              text: "Send funds",
              style: _titleStyle,
            ),
          ),
          const SizedBox(
            height: 38,
            width: 38,
          ),
        ],
      ),
    );
  }

  /// Builds a generic icon button with a grey background
  Widget _buildIconButton({
    required VoidCallback onTap,
    required IconData icon,
  }) {
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        height: 38,
        width: 38,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: const Color(0xFFE6E6E6),
        ),
        child: Icon(
          icon,
          color: const Color(0xFF151515),
          size: 22,
        ),
      ),
    );
  }

  /// Builds the currency selector row
  Widget _buildCurrencySelector(
      SendFundsViewModel viewModel, GlobalKey selectorKey) {
    return Column(
      children: [
        InkWell(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
          key: selectorKey,
          onTap: () => _showWalletDropdown(context, selectorKey),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 7),
            height: 33,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: const Color(0xFFF6F6F6),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Image.asset(
                      _getCurrencyFlag(),
                      width: 14,
                      height: 14,
                    ),
                    const SizedBox(width: 4),
                    RichText(
                      text: TextSpan(
                        text: widget.currency,
                        style: TextStyle(
                            fontSize: 9,
                            color: Color(0xFF858585),
                            fontFamily: 'Karla',
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Row(
                  children: [
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text: _selectedWallet['currency'] as String == 'USD'
                            ? _selectedWallet['amount'].toString()[0]
                            : _selectedWallet['currency'] as String == 'GBP'
                                ? _selectedWallet['amount'].toString()[0]
                                : _selectedWallet['amount'].toString()[0],
                        style: TextStyle(
                            fontFamily: 'Karla',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                            letterSpacing: 0.3),
                        children: [
                          TextSpan(
                            text: _selectedWallet['currency'] as String == 'USD'
                                ? _selectedWallet['amount']
                                    .toString()
                                    .replaceAll('\$', "")
                                : _selectedWallet['currency'] as String == 'GBP'
                                    ? _selectedWallet['amount']
                                        .toString()
                                        .replaceAll('£', "")
                                    : _selectedWallet['amount']
                                        .toString()
                                        .replaceAll('NGN', ""),
                            style: _valueStyle,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(6)),
                        color: Colors.white,
                      ),
                      child: Transform.rotate(
                        angle: 90 * 3.1415927 / 180,
                        child: const Icon(Icons.chevron_right_sharp, size: 14),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        _verticalSpaceTiny,
      ],
    );
  }

  /// Returns the appropriate flag image path based on currency
  String _getCurrencyFlag() {
    switch (_selectedWallet['currency']) {
      case 'USD':
        return "assets/images/united-states.png";
      case 'GBP':
        return "assets/images/united-kingdom.png";
      default:
        return "assets/images/nigeria.png";
    }
  }

  /// Builds the user avatar
  Widget _buildUserAvatar() {
    return CircleAvatar(
      radius: 48,
      backgroundColor: const Color(0xFFFFD4B9),
      child: Image.network(widget.userIcon),
    );
  }

  /// Builds the user name text
  Widget _buildUserName() {
    return RichText(
      text: TextSpan(
        text: widget.name,
        style: TextStyle(
          fontSize: 16,
          fontFamily: 'Karla',
          fontWeight: FontWeight.w600,
          color: Colors.black,
          letterSpacing: -0.2,
        ),
      ),
    );
  }

  /// Builds the username card
  Widget _buildUsernameCard() {
    return _buildCard(
      child: _buildRow(label: "Username", value: widget.username, symbol: ""),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
    );
  }

  /// Builds the transaction details card
  Widget _buildTransactionDetailsCard() {
    return _buildCard(
      child: Column(
        children: [
          _buildRow(
              label: "Charges",
              symbol: _selectedWallet['currency'] == 'USD'
                  ? '\$'
                  : _selectedWallet['currency'] == 'GBP'
                      ? '£'
                      : 'NGN', //'NGN'
              value: "0.0"),
          _verticalSpaceTiny,
          _verticalSpaceTiny,
          _buildRow(
              label: "Amount user will receive",
              symbol: _selectedWallet['currency'] == 'USD'
                  ? '\$'
                  : _selectedWallet['currency'] == 'GBP'
                      ? '£'
                      : 'NGN', //'NGN'
              value: widget.viewModel.formattedAmount.toString()),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
    );
  }

  /// Builds a generic card with rounded corners and grey background
  Widget _buildCard({required Widget child, required EdgeInsets padding}) {
    return Container(
      margin: _cardMargin,
      padding: padding,
      decoration: const BoxDecoration(
        color: Color(0xFFF4F4F4),
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: child,
    );
  }

  /// Builds a row with label and value
  Widget _buildRow({
    required String label,
    required String value,
    required String symbol,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: _labelStyle,
          ),
        ),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            text: symbol,
            style: TextStyle(
              fontFamily: 'Karla',
              fontWeight: FontWeight.w600,
              color: Colors.black,
              letterSpacing: 0.3,
              fontSize: 11,
            ),
            children: [
              TextSpan(
                text: value,
                style: label == "Username" ? _valueGreenStyle : _valueStyle,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Builds the numeric keypad
  Widget _buildKeypad(SendFundsViewModel viewModel) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      crossAxisSpacing: 10,
      padding: const EdgeInsets.symmetric(horizontal: 60),
      physics: const NeverScrollableScrollPhysics(),
      children: [
        ...List.generate(9, (index) => index + 1).map(
          (number) => _buildKeypadButton(
            label: number.toString(),
            onPressed: () {
              viewModel.appendNumber(number);
              _removeOverlay();
            },
          ),
        ),
        _buildKeypadButton(
          label: '',
          onPressed: _removeOverlay,
        ),
        _buildKeypadButton(
          label: '0',
          onPressed: () {
            viewModel.appendNumber(0);
            _removeOverlay();
          },
        ),
        _buildKeypadButton(
          label: '×',
          onPressed: () {
            viewModel.backspace();
            _removeOverlay();
          },
        ),
      ],
    );
  }

  /// Builds a single keypad button
  Widget _buildKeypadButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      onTap: onPressed,
      child: Container(
        margin: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: label == '' || label == '×'
              ? Colors.transparent
              : const Color(0xFFF4F4F4),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: RichText(
            text: TextSpan(
              text: label,
              style: TextStyle(
                fontFamily: 'Karla',
                fontSize: 28,
                fontWeight: FontWeight.w300,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the amount display with currency symbol
  Widget _buildAmountDisplay(SendFundsViewModel viewModel) {
    final symbol = _selectedWallet["currency"] == 'USD'
        ? '\$'
        : _selectedWallet["currency"] == 'GBP'
            ? '£'
            : 'NGN';
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      onTap: _toggleUserInfoVisibilityToFalse,
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          text: symbol,
          style: TextStyle(
            fontFamily: 'Karla',
            fontSize: 34,
            color: const Color(0xFF010101),
            fontWeight: FontWeight.w600,
            letterSpacing: -0.8,
          ),
          children: [
            TextSpan(
              text: viewModel.formattedAmount,
              style: TextStyle(
                fontSize: 40,
                color: viewModel.currentAmount == 0
                    ? const Color(0x26010101)
                    : const Color(0xFF010101),
                fontFamily: 'Karla',
                fontWeight: FontWeight.w600,
                letterSpacing: -0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the send button
  Widget _buildSendButton() {
    return Column(
      children: [
        InkWell(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
          onTap: () {
            _removeOverlay();
            TransferSuccessBottomSheet.show(context);
          },
          child: Container(
            width: 200,
            margin: _cardMargin,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF646464),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Center(
              child: RichText(
                text: TextSpan(
                  text: "Send",
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Karla',
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ),
          ),
        ),
        _verticalSpaceMedium,
      ],
    );
  }
}
// TRANSFER SUCCESS BOTTOM SHEET

class TransferSuccessBottomSheetViewModel extends BaseViewModel {
  bool _isInitialLoading = true;
  bool _isPinLoading = false;
  String _pin = '';
  static const String _correctPin = '1234'; // Example PIN for validation

  TransferSuccessBottomSheetViewModel() {
    _startInitialLoadingTimer();
  }

  bool get isInitialLoading => _isInitialLoading;
  bool get isPinLoading => _isPinLoading;
  String get pin => _pin;
  bool get isPinComplete => _pin.length == 4;

  void _startInitialLoadingTimer() async {
    await Future.delayed(const Duration(seconds: 2));
    _isInitialLoading = false;
    notifyListeners();
  }

  void appendNumber(int number) {
    if (_pin.length < 4) {
      _pin += number.toString();
      notifyListeners();
    }
    if (_pin.length == 4) {
      _validatePin();
    }
  }

  void backspace() {
    if (_pin.isNotEmpty) {
      _pin = _pin.substring(0, _pin.length - 1);
      notifyListeners();
    }
  }

  void _validatePin() async {
    _isPinLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2));
    if (_pin == _correctPin) {
      _isPinLoading = false;
      notifyListeners();
    } else {
      _pin = '';
      _isPinLoading = false;
      notifyListeners();
      // Optionally show error message
    }
  }

  void onDoneTap(BuildContext context) {
    Navigator.of(context).pop();
  }

  void onSeeReceiptTap() {
    print('Navigating to receipt screen');
  }
}

class TransferSuccessBottomSheet {
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => const _TransferSuccessBottomSheetContent(),
    );
  }
}

class _TransferSuccessBottomSheetContent
    extends StackedView<TransferSuccessBottomSheetViewModel> {
  const _TransferSuccessBottomSheetContent();

  @override
  Widget builder(
    BuildContext context,
    TransferSuccessBottomSheetViewModel viewModel,
    Widget? child,
  ) {
    double targetHeight = viewModel.isInitialLoading || viewModel.isPinLoading
        ? 200
        : !viewModel.isPinComplete
            ? 500
            : 375;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      height: targetHeight,
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(24),
      ),
      child: viewModel.isInitialLoading
          ? _buildInitialLoadingContent()
          : viewModel.isPinLoading
              ? _buildPinLoadingContent()
              : !viewModel.isPinComplete
                  ? _buildPinEntryContent(viewModel)
                  : _buildSuccessContent(context, viewModel),
    );
  }

  Widget _buildInitialLoadingContent() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
        SizedBox(height: 16),
        Text(
          'Processing transfer...',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildPinLoadingContent() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
        SizedBox(height: 16),
        Text(
          'Verifying PIN...',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildPinEntryContent(TransferSuccessBottomSheetViewModel viewModel) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 16),
        const Text(
          'Enter transaction PIN',
          style: TextStyle(
            fontSize: 22.00,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(4, (index) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: index < viewModel.pin.length
                    ? Colors.white
                    : Colors.white30,
              ),
            );
          }),
        ),
        const SizedBox(height: 32),
        _buildKeypad(viewModel),
      ],
    );
  }

  Widget _buildSuccessContent(
      BuildContext context, TransferSuccessBottomSheetViewModel viewModel) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 16),
        const Text(
          'Success!',
          style: TextStyle(
            fontSize: 22.00,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          '\$50',
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Your \$50 transfer to John is on its way. It should arrive in less than 2 minutes.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 150,
          width: 92,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                left: 0,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.purple,
                    child: Text(
                      '\$50',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.grey,
                    child: Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => viewModel.onDoneTap(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'Done',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: viewModel.onSeeReceiptTap,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'See receipt',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildKeypad(TransferSuccessBottomSheetViewModel viewModel) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      crossAxisSpacing: 5,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      physics: const NeverScrollableScrollPhysics(),
      children: [
        ...List.generate(9, (index) => index + 1).map(
          (number) => _buildKeypadButton(
            label: number.toString(),
            onPressed: () => viewModel.appendNumber(number),
          ),
        ),
        _buildKeypadButton(
          label: '',
          onPressed: () {},
        ),
        _buildKeypadButton(
          label: '0',
          onPressed: () => viewModel.appendNumber(0),
        ),
        _buildKeypadButton(
          label: '×',
          onPressed: viewModel.backspace,
        ),
      ],
    );
  }

  Widget _buildKeypadButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      onTap: onPressed,
      child: Container(
        margin: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: label == '' || label == '×'
              ? Colors.transparent
              : const Color.fromARGB(255, 24, 24, 24),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: RichText(
            text: TextSpan(
              text: label,
              style: TextStyle(
                fontFamily: 'Karla',
                fontSize: 22.00,
                fontWeight: FontWeight.w300,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  TransferSuccessBottomSheetViewModel viewModelBuilder(BuildContext context) =>
      TransferSuccessBottomSheetViewModel();
}

// elizabethhaskins@yellowcard.io
