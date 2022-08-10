import 'package:flutter/services.dart';
import 'dart:math' as math;

class EnglishDigitsTextInputFormatter extends TextInputFormatter {

  bool decimal;

  EnglishDigitsTextInputFormatter({this.decimal = false}) : super ();

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String truncated =
        _convertToEnglish(newValue.text).replaceAll(RegExp(decimal ? r'[^0-9.]' : r'[^0-9]'), '');
    TextSelection newSelection = newValue.selection.copyWith(
      baseOffset: math.min(truncated.length, truncated.length + 1),
      extentOffset: math.min(truncated.length, truncated.length + 1),
    );

    return TextEditingValue(
      text: truncated,
      selection: newSelection,
      composing: TextRange.empty,
    );
  }
}

String _convertToEnglish(String input) {
  const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
  const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

  for (int i = 0; i < arabic.length; i++) {
    input = input.replaceAll(arabic[i], english[i]);
  }

  return input;
}

class EnglishTextInputFormatter extends TextInputFormatter {

  EnglishTextInputFormatter() : super ();

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String truncated =
    _convertToEnglish(newValue.text);
    TextSelection newSelection = newValue.selection.copyWith(
      baseOffset: math.min(truncated.length, truncated.length + 1),
      extentOffset: math.min(truncated.length, truncated.length + 1),
    );

    return TextEditingValue(
      text: truncated,
      selection: newSelection,
      composing: TextRange.empty,
    );
  }
}

class CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue previousValue,
      TextEditingValue nextValue,
      ) {
    var inputText = nextValue.text;

    if (nextValue.selection.baseOffset == 0) {
      return nextValue;
    }

    var bufferString = StringBuffer();
    for (int i = 0; i < inputText.length; i++) {
      bufferString.write(inputText[i]);
      var nonZeroIndexValue = i + 1;
      if (nonZeroIndexValue % 4 == 0 && nonZeroIndexValue != inputText.length) {
        bufferString.write(' ');
      }
    }

    var string = bufferString.toString();
    return nextValue.copyWith(
      text: string,
      selection: TextSelection.collapsed(
        offset: string.length,
      ),
    );
  }
}