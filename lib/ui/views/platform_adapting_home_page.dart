import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:dayfi/data/blocs/bloc.dart';
import 'package:dayfi/data/blocs/provider.dart';
import 'package:dayfi/models.dart';
import 'package:dayfi/ui/views/nfc_scan_view.dart';
import 'package:dayfi/ui/views/payment_setup/payment_setup_view.dart';
import 'package:dayfi/ui/views/pin_entry_view.dart';
import 'package:dayfi/utilities.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PlatformAdaptingHomePage extends StatefulWidget {
  final String selectedPaymentMethod;

  const PlatformAdaptingHomePage({
    super.key,
    required this.selectedPaymentMethod,
  });

  @override
  State<PlatformAdaptingHomePage> createState() =>
      _PlatformAdaptingHomePageState();
}

class _PlatformAdaptingHomePageState extends State<PlatformAdaptingHomePage>
    with SingleTickerProviderStateMixin {
  late PaymentSetupView home;
  var _reading = false;
  Exception? error;
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  PageController? topController;
  WebViewManager webview = WebViewManager();
  StreamSubscription? _webViewListener;
  int currentTop = 1;
  Map<String, dynamic>? _cardDetails;

  DayfiAppBloc get bloc => BlocProvider.provideBloc(context);

  @override
  void initState() {
    super.initState();
    _initSelf();
  }

  @override
  void reassemble() {
    super.reassemble();
    _initSelf();
  }

  void _initSelf() {
    _webViewListener =
        webview.stream(WebViewOwner.Main).listen(_onReceivedMessage);
    topController = PageController(initialPage: currentTop);
  }

  @override
  void dispose() {
    topController?.dispose();
    _webViewListener?.cancel();
    super.dispose();
  }

  void showSnackbar(SnackBar snackBar) {
    if (_scaffoldMessengerKey.currentState != null) {
      _scaffoldMessengerKey.currentState!.showSnackBar(snackBar);
    }
  }

  // void _onListenCard(Map<String, dynamic>? value) {
  //   if (value != null) {
  //     _cardDetails = value;
  //     showSnackbar(const SnackBar(
  //       content: Text("Valid Debit Card"),
  //     ));
  //     _navigateToCardDetails(context);
  //   }
  // }

  void _onReceivedMessage(WebViewEvent ev) async {
    if (ev.reload) return;
    assert(ev.message != null);

    var scriptModel = ScriptDataModel.fromJson(json.decode(ev.message!));
    log('[Main] Received action ${scriptModel.action} from script');
    switch (scriptModel.action) {
      case 'poll':
        error = null;
        try {
          final tag =
              await FlutterNfcKit.poll(iosAlertMessage: S(context).waitForCard);
          final json = tag.toJson();
          try {
            final ndef = await FlutterNfcKit.readNDEFRawRecords();
            json["ndef"] = ndef;
          } on PlatformException catch (e) {
            json["ndef"] = null;
            log('Silent readNDEF error: ${e.toDetailString()}');
          }
          await webview.run("pollCallback(${jsonEncode(json)})");
          FlutterNfcKit.setIosAlertMessage(S(context).cardPolled);
        } on PlatformException catch (e) {
          error = e;
          log('Poll error: ${e.toDetailString()}');
          Navigator.of(context).pop();
          showSnackbar(SnackBar(
              content:
                  Text('${S(context).readFailed}: ${e.toDetailString()}')));
          await webview.run("pollErrorCallback(${e.toJsonString()})");
        }
        break;

      case 'transceive':
        try {
          log('TX: ${scriptModel.data}');
          final rapdu =
              await FlutterNfcKit.transceive(scriptModel.data as String);
          log('RX: $rapdu');
          await webview.run("transceiveCallback('$rapdu')");
        } on PlatformException catch (e) {
          error = e;
          log('Transceive error: ${e.toDetailString()}');
          Navigator.of(context).pop();
          showSnackbar(SnackBar(
              content:
                  Text('${S(context).readFailed}: ${e.toDetailString()}')));
          await webview.run("transceiveErrorCallback(${e.toJsonString()})");
        }
        break;

      case 'report':
        _cardDetails = scriptModel.data["detail"] as Map<String, dynamic>;
        Navigator.of(context).pop();
        _navigateToCardDetails(context);
        break;

      case 'finish':
        if (error != null) {
          await FlutterNfcKit.finish(iosErrorMessage: S(context).readFailed);
          error = null;
        } else {
          await FlutterNfcKit.finish(iosAlertMessage: S(context).readSucceeded);
        }
        break;

      case 'log':
        log('Log from script: ${scriptModel.data.toString()}');
        break;

      default:
        assert(false, 'Unknown action ${scriptModel.action}');
        break;
    }
  }

  final amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final top = _buildTop(context);
    final webviewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel("nfsee",
          onMessageReceived: webview.javaScriptCallback)
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: webview.onWebviewPageLoad,
      ));
    webview.setWebviewCtrl(webviewController);

    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: Scaffold(
        backgroundColor: Color(0xffF7F7F7),
        body: Stack(children: <Widget>[top]),
      ),
    );
  }

  Widget _buildTop(context) {
    home = PaymentSetupView(
      readCard: () {
        return _readTag(this.context);
      },
      selectedPaymentMethod: widget.selectedPaymentMethod,
      amount: amountController,
    );
    return home;
  }

  Future<bool> _readTag(BuildContext context) async {
    if (_reading) return false;
    _reading = true;

    // if (widget.selectedPaymentMethod == "Via Debit Card") {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => NfcScanView(
          onReceivedMessage: _onReceivedMessage,
          amount: amountController.text.trim(),
        ),
      ),
    );
    final script = await rootBundle.loadString('assets/read.js');
    await webview.reload();
    await webview.run(script);
    // } else {

    // }

    _reading = false;
    return true;
  }

  void _navigateToCardDetails(BuildContext context) {
    if (_cardDetails != null && _cardDetails!.containsKey('card_number')) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => PinEntryView(
            cardDetails: _cardDetails,
            onClose: () {
              setState(() {
                _cardDetails = null;
              });
            },
            amount: amountController.text.trim(),
          ),
        ),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => PaymentSetupView(
            readCard: () {
              return _readTag(this.context);
            },
            selectedPaymentMethod: widget.selectedPaymentMethod,
            amount: amountController,
          ),
        ),
      );
    }
  }
}
