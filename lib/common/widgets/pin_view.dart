import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dayfi/common/utils/key_pressed_util.dart';
import 'package:dayfi/common/widgets/buttons/numerical_keyboard.dart';
import 'package:dayfi/common/widgets/pin_text_field.dart';
import 'package:dayfi/core/extensions/context_extension.dart';

class PinView extends ConsumerStatefulWidget {
  const PinView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PinViewState();
}

class _PinViewState extends ConsumerState<PinView> {
  TextEditingController pin = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Pin View'),
        SizedBox(height: 32),
        SizedBox(
          width: context.deviceWidth(1),
          child: PinTextField(
            obscureText: true,
            fieldCount: 4,
            boxSize: 30,
            isTransactionPin: true,
            controller: pin,
            onChange: (value) {},
            validation: (val) {
              return null;
            },
          ),
        ),
        SizedBox(height: 32),
        NumericalKeyboard(
          showFaceID: false,
          onKeyPressed: (key) {
            onKeyPressed(key, pin, 4);
          },
        ),
      ],
    );
  }
}
