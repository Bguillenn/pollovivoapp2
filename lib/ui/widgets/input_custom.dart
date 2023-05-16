import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
class InputCustom extends StatelessWidget {

  const InputCustom(@required this.hint, @required this.label,@required this.controller,this.decimal, {this.onChange});

  final String hint, label;
  final TextEditingController controller;
  final bool decimal;
  final Function(String) onChange;


  @override
  Widget build(BuildContext context) {
      if(decimal)
      return Flexible(
      child: TextFormField(
        controller: controller,
        inputFormatters: [DecimalTextInputFormatter(decimalRange: 2)],
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        onChanged: onChange,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          hintText: hint,
          labelText: label,
          counterText: "",
        ),
      ),
    );
      else return Flexible(
        child: TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
          onChanged: onChange,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: hint,
            labelText: label,
            counterText: "",
          ),
        ),
      );
  }
}

class DecimalTextInputFormatter extends TextInputFormatter {
  DecimalTextInputFormatter({this.decimalRange})
      : assert(decimalRange == null || decimalRange > 0);

  final int decimalRange;

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, // unused.
      TextEditingValue newValue,
      ) {
    TextSelection newSelection = newValue.selection;
    String truncated = newValue.text;

    if (decimalRange != null) {
      String value = newValue.text;

      if (value.contains(".") &&
          value.substring(value.indexOf(".") + 1).length > decimalRange) {
        truncated = oldValue.text;
        newSelection = oldValue.selection;
      } else if (value == ".") {
        truncated = "0.";

        newSelection = newValue.selection.copyWith(
          baseOffset: math.min(truncated.length, truncated.length + 1),
          extentOffset: math.min(truncated.length, truncated.length + 1),
        );
      }

      return TextEditingValue(
        text: truncated,
        selection: newSelection,
        composing: TextRange.empty,
      );
    }
    return newValue;
  }
}
