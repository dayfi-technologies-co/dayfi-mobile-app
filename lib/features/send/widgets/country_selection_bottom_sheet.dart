import 'package:flutter/material.dart';

import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/core/theme/app_typography.dart';
import 'package:dayfi/features/send/vm/send_viewmodel.dart';
import 'package:flutter_svg/svg.dart';

class CountrySelectionBottomSheet extends StatelessWidget {
  final List<CountryOption> countries;
  final String selectedCountryCode;
  final Function(String) onCountrySelected;
  final String title;

  const CountrySelectionBottomSheet({
    super.key,
    required this.countries,
    required this.selectedCountryCode,
    required this.onCountrySelected,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.92,
      decoration: BoxDecoration(
        color: const Color(0xFFF8F6F0), // Light beige background
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.neutral400,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.fromLTRB(24, 24, 16, 20),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: AppTypography.titleLarge.copyWith(
                   fontFamily: 'FunnelDisplay',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.neutral800,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.close,
                    color: AppColors.neutral600,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 20),

          // Countries list with search bar
          Expanded(
            child: ListView(
              children: [
                // Search bar
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 18),
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.neutral200),
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search currency here...',
                        hintStyle: AppTypography.bodyMedium.copyWith(
                          color: AppColors.neutral400,
                          fontSize: 14,
                          fontFamily: 'Chirp',
                        ),
                        prefixIcon: Container(
                          width: 40,
                          alignment: Alignment.centerRight,
                          constraints: BoxConstraints.tightForFinite(),
                          child: Center(
                            child: SvgPicture.asset(
                              'assets/icons/svgs/search-normal.svg',
                              height: 22,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 20),

                // Countries list
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 18),
                  itemCount: countries.length,
                  itemBuilder: (context, index) {
                    final country = countries[index];

                    return Container(
                      margin: EdgeInsets.only(bottom: 4),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            onCountrySelected(country.code);
                            Navigator.pop(context);
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                // Flag - circular container
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.neutral200,
                                      width: 1,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      country.flag,
                                      style: TextStyle(fontSize: 16.55),
                                    ),
                                  ),
                                ),

                                SizedBox(width: 16),

                                // Country name
                                Expanded(
                                  child: Text(
                                    country.name,
                                    style: AppTypography.bodyMedium.copyWith(
                                      fontFamily: 'Chirp',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.neutral800,
                                    ),
                                  ),
                                ),

                                // Currency code
                                Text(
                                  country.currency,
                                  style: AppTypography.bodyMedium.copyWith(
                                    fontFamily: 'Chirp',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.neutral800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
