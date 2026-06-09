import 'package:dayfi/features/pay/models/bill_models.dart';

/// Shared bill categories for Pay and Budget flows.
const billCategoryPresets = [
  BillCategory(
    name: 'Airtime',
    code: 'AIRTIME',
    description: 'Top up any network',
  ),
  BillCategory(
    name: 'Mobile Data',
    code: 'MOBILEDATA',
    description: 'Data bundles',
  ),
  BillCategory(
    name: 'Cable TV',
    code: 'CABLEBILLS',
    description: 'DSTV, GOtv & more',
  ),
  BillCategory(
    name: 'Internet',
    code: 'INTSERVICE',
    description: 'Broadband & Wi‑Fi',
  ),
  BillCategory(
    name: 'Utilities',
    code: 'UTILITYBILLS',
    description: 'Electricity & utilities',
  ),
];
