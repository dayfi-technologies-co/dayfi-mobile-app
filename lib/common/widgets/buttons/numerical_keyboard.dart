import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dayfi/core/extensions/gesture_extension.dart';
import 'package:dayfi/core/extensions/widget_extension.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/core/theme/app_typography.dart';
import 'package:dayfi/gen/assets.gen.dart';


class NumericalKeyboard extends StatelessWidget {
  final KeyboardCallback? onKeyPressed;
  final bool showFaceID;
  final Function()? faceIDFunc;

  const NumericalKeyboard(
      {super.key, this.onKeyPressed, this.faceIDFunc, this.showFaceID = false});

  static const backspaceKey = 42;
  static const clearKey = 69;
  static const faceIDKey = 52;

  @override
  Widget build(BuildContext context) {
    return Table(
      defaultColumnWidth: const IntrinsicColumnWidth(flex: 1.0),
      // border: TableBorder.all(),
      children: [
        TableRow(
          children: [
            _buildNumberKey(1, context),
            _buildNumberKey(2, context),
            _buildNumberKey(3, context),
          ],
        ),
        TableRow(
          children: [
            _buildNumberKey(4, context),
            _buildNumberKey(5, context),
            _buildNumberKey(6, context),
          ],
        ),
        TableRow(
          children: [
            _buildNumberKey(7, context),
            _buildNumberKey(8, context),
            _buildNumberKey(9, context),
          ],
        ),
        TableRow(
          children: [
            if (showFaceID) ...[
              CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(.05),
                child: InkWell(
                    onTap: () => onKeyPressed!(faceIDKey),
                    child: Assets.icons.svgs.faceScan.svg(height: 34.h, width: 34.w)),
                )
                  .marginOnly(top: 25)
                  .onTap(onTap: faceIDFunc, tooltip: "Face ID Func"),
            ] else ...[
              Container()
            ],
            _buildNumberKey(0, context),
            _buildKey(const Icon(Icons.backspace), backspaceKey),
          ],
        )
      ],
    );
  }

  Widget _buildNumberKey(int n, BuildContext context) {
    return _buildKey(
        CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(.05),
            child: Text(
              '$n',
              style: AppTypography.bodyLarge.copyWith(
                // color: ,
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
            )),
        n);
  }

  Widget _buildKey(Widget icon, int key) {
    return IconButton(
      icon: icon,
      padding: const EdgeInsets.all(25.0),
      onPressed: () => onKeyPressed!(key),
    );
  }
}

typedef KeyboardCallback = Function(int key);
