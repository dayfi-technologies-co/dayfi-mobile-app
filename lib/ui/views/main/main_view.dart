import 'package:dayfi/ui/views/coins/coins_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:stacked/stacked.dart';

import 'package:dayfi/ui/views/home/home_view.dart';
import 'package:dayfi/ui/views/settings/settings_view.dart';
import 'package:dayfi/ui/views/wallets/wallets_view.dart';
import 'main_viewmodel.dart';

class MainView extends StackedView<MainViewModel> {
  final int index;
  const MainView({super.key, this.index = 0});

  @override
  Widget builder(BuildContext context, MainViewModel viewModel, Widget? child) {
    Widget getViewForIndex(int index) {
      switch (index) {
        case 0:
          return HomeView(mainModel: viewModel);
        case 1:
          return CoinsView();
        case 2:
          return WalletsView(mainModel: viewModel);
        case 3:
          return SettingsView(mainModel: viewModel);
        default:
          return HomeView(mainModel: viewModel);
      }
    }

    void _onItemTap(int index) => viewModel.setIndex(index);

    return Scaffold(
      backgroundColor: Colors.white,
      body: getViewForIndex(viewModel.currentIndex),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 8.0),
        child: Theme(
          data: ThemeData(
            splashColor: Colors.transparent,
            splashFactory: NoSplash.splashFactory,
            highlightColor: Colors.transparent,
          ),
          child: BottomNavigationBar(
            backgroundColor: Colors.white,
            type: BottomNavigationBarType.fixed,
            currentIndex: viewModel.currentIndex,
            onTap: _onItemTap,
            elevation: 0,
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontFamily: 'Karla',
              letterSpacing: -0.2,
            ),
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontFamily: 'Karla',
              letterSpacing: -0.2,
            ),
            selectedItemColor: const Color(0xff5645F5),
            unselectedItemColor: Theme.of(
              context,
            ).textTheme.bodyLarge!.color!.withOpacity(.4),
            selectedFontSize: 16,
            unselectedFontSize: 16,
            items: [
              BottomNavigationBarItem(
                icon: Padding(
                  padding: const EdgeInsets.only(bottom: 2.0),
                  child: SvgPicture.asset(
                    "assets/svgs/dashboard_24dp_1F1F1F_FILL0_wght400_GRAD0_opsz24.svg",
                    height: 30,
                    color:
                        viewModel.currentIndex == 0
                            ? const Color(0xff5645F5)
                            : Theme.of(
                              context,
                            ).textTheme.bodyLarge!.color!.withOpacity(.4),
                  ),
                ),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: const EdgeInsets.only(bottom: 2.0),
                  child: SvgPicture.asset(
                    "assets/svgs/coins_tab.svg",
                    height: 30,
                    color:
                        viewModel.currentIndex == 1
                            ? const Color(0xff5645F5)
                            : Theme.of(
                              context,
                            ).textTheme.bodyLarge!.color!.withOpacity(.4),
                  ),
                ),
                label: 'Coins',
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: const EdgeInsets.only(bottom: 2.0),
                  child: SvgPicture.asset(
                    "assets/svgs/account_balance_wallet_24dp_1F1F1F_FILL0_wght400_GRAD0_opsz24.svg",
                    height: 30,
                    color:
                        viewModel.currentIndex == 2
                            ? const Color(0xff5645F5)
                            : Theme.of(
                              context,
                            ).textTheme.bodyLarge!.color!.withOpacity(.4),
                  ),
                ),
                label: 'Wallets',
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: const EdgeInsets.only(bottom: 2.0),
                  child: SvgPicture.asset(
                    "assets/svgs/settings_tab.svg",
                    height: 30,
                    color:
                        viewModel.currentIndex == 3
                            ? const Color(0xff5645F5)
                            : Theme.of(
                              context,
                            ).textTheme.bodyLarge!.color!.withOpacity(.4),
                  ),
                ),
                label: 'Settings',
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  MainViewModel viewModelBuilder(BuildContext context) => MainViewModel();

  @override
  void onViewModelReady(MainViewModel viewModel) async {
    await viewModel.loadUser();
    await viewModel.loadWalletDetails();
    super.onViewModelReady(viewModel);
  }
}
