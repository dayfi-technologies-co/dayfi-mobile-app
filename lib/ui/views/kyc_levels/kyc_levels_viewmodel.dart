import 'package:dayfi/app/app.locator.dart';
import 'package:dayfi/app/app.router.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class KycLevelsViewModel extends BaseViewModel {
  final NavigationService navigationService = locator<NavigationService>();
  int _currentStep = 0;

  int get currentStep => _currentStep;

  void setCurrentStep(int step) {
    _currentStep = step;
    notifyListeners();
  }

  void startProcess() {
    setCurrentStep(0);
    navigationService.navigateToLevelOnePartAView();

    notifyListeners();
  }
}
