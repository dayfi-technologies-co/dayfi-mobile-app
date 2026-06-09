import 'package:dayfi/app_locator.dart';
import 'package:dayfi/common/widgets/dayfi_screen_app_bar.dart';
import 'package:dayfi/features/pay/constants/flutterwave_bill_presets.dart';
import 'package:dayfi/features/pay/models/bill_models.dart';
import 'package:dayfi/features/pay/views/bill_pay_view.dart';
import 'package:dayfi/features/pay/widgets/pay_bill_grid_tile.dart';
import 'package:dayfi/services/remote/bills_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BillBillersView extends StatefulWidget {
  final BillCategory category;

  const BillBillersView({super.key, required this.category});

  @override
  State<BillBillersView> createState() => _BillBillersViewState();
}

class _BillBillersViewState extends State<BillBillersView> {
  final _billsService = locator<BillsService>();
  late List<BillBiller> _billers;
  bool _usingPreview = true;
  bool _refreshing = false;

  @override
  void initState() {
    super.initState();
    final saved = billBillersFromRows(
      _billsService.getPersistedBillers(widget.category.code),
    );
    if (saved.isNotEmpty) {
      _billers = saved;
      _usingPreview = false;
    } else {
      _billers = flutterwavePreviewBillersFor(widget.category.code);
      _usingPreview = true;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _refreshBillers());
  }

  Future<void> _refreshBillers({bool forceRefresh = false}) async {
    if (mounted) setState(() => _refreshing = forceRefresh);
    try {
      final rows = await _billsService.fetchBillers(
        widget.category.code,
        forceRefresh: forceRefresh,
      );
      final fromApi = billBillersFromRows(rows);
      if (!mounted) return;
      if (fromApi.isNotEmpty) {
        setState(() {
          _billers = fromApi;
          _usingPreview = false;
          _refreshing = false;
        });
        return;
      }
    } catch (_) {
      /* keep current list */
    }
    if (mounted) {
      setState(() {
        if (_billers.isEmpty) {
          _billers = flutterwavePreviewBillersFor(widget.category.code);
          _usingPreview = true;
        }
        _refreshing = false;
      });
    }
  }

  void _openBiller(BillBiller biller) {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => BillPayView(
              category: widget.category,
              biller: biller,
              usePreviewFlow:
                  _usingPreview || isFlutterwavePreviewBiller(biller),
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DayfiFeatureScaffold(
      title: widget.category.name,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(0, 12, 0, 0),
        child:
            _billers.isEmpty
                ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'No providers available for ${widget.category.name}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Chirp',
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                )
                : CustomScrollView(
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(18, 0, 18, 32),
                      sliver: SliverGrid(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                              childAspectRatio: 1.5,
                            ),
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final biller = _billers[index];
                          return PayBillGridTile(
                            title: biller.shortName ?? biller.name,
                            innerIconAsset: billerInnerIconAsset(
                              biller,
                              widget.category.code,
                            ),
                            brandImageAsset: billerBrandImageAsset(biller),
                            plainBillerBrandIcon: true,
                            onTap: () => _openBiller(biller),
                          );
                        }, childCount: _billers.length),
                      ),
                    ),
                    if (_refreshing)
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 16),
                          child: Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
      ),
    );
  }
}
