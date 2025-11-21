import 'package:flutter/material.dart';
import 'package:dayfi/core/theme/app_colors.dart';

class AppSpacings {
  AppSpacings._();
  static const double k1 = 1;

  static const double k2 = 2;
  static const double k4 = 4;
  static const double k6 = 6;
  static const double k7 = 7;

  static const double k8 = 8;
  static const double k10 = 10;
  static const double k12 = 12;
  static const double k13 = 13;

  static const double k14 = 14;
  static const double k15 = 15;

  static const double k16 = 16;
  static const double k18 = 18;

  static const double k20 = 20;
  static const double k21 = 21;
  static const double k22 = 22;
  static const double k23 = 23;

  static const double k24 = 24;
  static const double k25 = 25;

  static const double k28 = 28;
  static const double k30 = 30;
  static const double k35 = 35;
  static const double k32 = 32;
  static const double k36 = 36;
  static const double k38 = 38;
  static const double k40 = 40;
  static const double k43 = 43;
  static const double k44 = 44;

  static const double k45 = 45;

  static const double k50 = 50;
  static const double k55 = 55;
  static const double k60 = 60;
  static const double k70 = 70;
  static const double k80 = 80;
  static const double k90 = 90;
  static const double k95 = 95;

  static const double k100 = 100;
  static const double k105 = 105;
  static const double k110 = 110;
  static const double k120 = 120;
  static const double k130 = 130;
  static const double k140 = 140;
  static const double k145 = 145;
  static const double k150 = 150;
  static const double k155 = 155;
  static const double k160 = 160;
  static const double k165 = 165;
  static const double k180 = 180;
  static const double k185 = 185;
  static const double k190 = 190;
  static const double k200 = 200;
  static const double k220 = 220;
  static const double k225 = 225;
  static const double k230 = 230;
  static const double k240 = 240;
  static const double k250 = 250;
  static const double k260 = 260;
  static const double k270 = 270;
  static const double k275 = 275;

  static const double k280 = 280;
  static const double k285 = 285;
  static const double k290 = 290;
  static const double k300 = 300;
  static const double k310 = 310;
  static const double k320 = 320;
  static const double k330 = 330;
  static const double k340 = 340;
  static const double k350 = 350;
  static const double k360 = 360;
  static const double k370 = 370;
  static const double k380 = 380;
  static const double k390 = 390;
  static const double k400 = 400;
  static const double k420 = 420;
  static const double k450 = 450;
  static const double k500 = 500;
  static const double k600 = 600;
  static const double k620 = 620;
  static const double k650 = 650;
  static const double k700 = 700;

  static const double webWidth = 1080;
  static const double elementSpacing = k20 * 0.5;
  static const double cardOutlineWidth = 0.25;

  static const defaultBorderRadius = BorderRadius.only(
    topLeft: Radius.circular(k12),
    topRight: Radius.circular(k12),
    bottomLeft: Radius.circular(k12),
    bottomRight: Radius.circular(k12),
  );

  static const defaultButtonBorderRadius =
      BorderRadius.all(Radius.circular(10));

  static const borderRadiusk20All =
      BorderRadius.all(Radius.circular(AppSpacings.k20));

  static const borderRadiusk40All =
      BorderRadius.all(Radius.circular(AppSpacings.k40));

  static const borderRadiusk8All =
      BorderRadius.all(Radius.circular(AppSpacings.k8));

  static const defaultBorderRadiusTextField = BorderRadius.only(
    topLeft: Radius.circular(k12 * 0.5),
    topRight: Radius.circular(k12 * 0.5),
    bottomLeft: Radius.circular(k12 * 0.5),
    bottomRight: Radius.circular(k12 * 0.5),
  );

  static const defaultCircularRadius = BorderRadius.only(
    topLeft: Radius.circular(999),
    topRight: Radius.circular(999),
    bottomLeft: Radius.circular(999),
    bottomRight: Radius.circular(999),
  );

  static const OutlineInputBorder outLineBorder = OutlineInputBorder(
    borderRadius: defaultBorderRadiusTextField,
    borderSide: BorderSide(color: AppColors.neutral200, width: 1.2),
  );

  static const OutlineInputBorder disabledOutLineBorder = OutlineInputBorder(
    borderRadius: defaultBorderRadiusTextField,
    borderSide: BorderSide(color: AppColors.neutral400, width: 0.8),
  );
  static const OutlineInputBorder errorBorder = OutlineInputBorder(
    borderRadius: defaultBorderRadiusTextField,
    borderSide: BorderSide(color: AppColors.error400, width: 0.7),
  );

  static const OutlineInputBorder errorFocusedBorder = OutlineInputBorder(
    borderRadius: defaultBorderRadiusTextField,
    borderSide: BorderSide(color: AppColors.error400, width: 1.2),
  );
}
