import 'package:dayfi/app_locator.dart';
import 'package:dayfi/common/widgets/dayfi_screen_app_bar.dart';
import 'package:dayfi/common/widgets/dayfi_screen_description.dart';
// import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/features/pay/constants/bill_category_presets.dart';
import 'package:dayfi/features/pay/constants/pay_copy.dart';
import 'package:dayfi/features/pay/constants/flutterwave_bill_presets.dart';
import 'package:dayfi/features/pay/models/bill_models.dart';
import 'package:dayfi/features/pay/views/bill_billers_view.dart';
import 'package:dayfi/features/pay/widgets/pay_bill_grid_tile.dart';
import 'package:dayfi/services/remote/bills_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_svg/flutter_svg.dart';

class PayView extends ConsumerStatefulWidget {
  const PayView({super.key});

  @override
  ConsumerState<PayView> createState() => _PayViewState();
}

class _PayViewState extends ConsumerState<PayView> {
  final _billsService = locator<BillsService>();
  late List<BillCategory> _categories;
  bool _refreshing = false;

  @override
  void initState() {
    super.initState();
    _categories = _initialCategories();
    WidgetsBinding.instance.addPostFrameCallback((_) => _refreshCategories());
  }

  List<BillCategory> _initialCategories() {
    final saved = billCategoriesFromRows(_billsService.getPersistedCategories());
    return saved.isNotEmpty ? saved : billCategoryPresets;
  }

  Future<void> _refreshCategories({bool forceRefresh = false}) async {
    if (mounted) setState(() => _refreshing = forceRefresh);
    try {
      final rows = await _billsService.fetchCategories(
        forceRefresh: forceRefresh,
      );
      if (!mounted) return;
      final fromApi = billCategoriesFromRows(rows);
      if (fromApi.isNotEmpty) {
        setState(() {
          _categories = fromApi;
          _refreshing = false;
        });
        return;
      }
    } catch (_) {
      /* keep presets */
    }
    if (mounted) setState(() => _refreshing = false);
  }

  @override
  Widget build(BuildContext context) {
    return DayfiFeatureScaffold(
      title: kPayBillsLocalTitle,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          CupertinoSliverRefreshControl(
            onRefresh: () => _refreshCategories(forceRefresh: true),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(18, 4, 18, 32),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                DayfiScreenDescription(text: kPayBillsLocalDescription),
                _PayCategoryGroup(
                  categories: _categories,
                  onCategoryTap: (cat) {
                      HapticFeedback.lightImpact();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BillBillersView(category: cat),
                        ),
                      );
                    },
                  ),
                if (_refreshing)
                  const Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _PayCategoryGroup extends StatelessWidget {
  final List<BillCategory> categories;
  final ValueChanged<BillCategory> onCategoryTap;

  const _PayCategoryGroup({
    required this.categories,
    required this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1.5,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final cat = categories[index];
        return PayBillGridTile(
          title: cat.name,
          innerIconAsset: categoryInnerIconAsset(cat.code),
          onTap: () => onCategoryTap(cat),
        );
      },
    );
  }
}
