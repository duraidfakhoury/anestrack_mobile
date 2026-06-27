import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../generated/locale_keys.g.dart';

class AppValidator {
  static AppValidator? _instance;
  AppValidator._();
  factory AppValidator() => _instance ??= AppValidator._();

  // Validates an email address
  String? emailValidator(String? value, {bool canBeEmpty = false}) {
    if (canBeEmpty && (value ?? "").isEmpty) return null;
    if ((value == null || value.isEmpty) && !canBeEmpty) {
      return LocaleKeys.emptyField.tr();
    }

    if (!RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$')
        .hasMatch(value ?? '')) {
      return LocaleKeys.invalidEmailAddress.tr();
    }

    return null; // Return null if the value is a valid email address
  }

// Validates a phone number
  String? phoneValidator(String? value) {
    if (value == null || value.isEmpty) {
      return LocaleKeys.emptyField.tr();
    }

    // Check if the phone number starts with "00963," "09," or "+963"
    final RegExp phoneRegex =
        RegExp(r'^(09[0-9]{8}|009639[0-9]{8}|\+9639[0-9]{8})$');

    if (!phoneRegex.hasMatch(value)) {
      return LocaleKeys.invalidPhoneNumber.tr();
    }

    return null; // Return null if the value is valid
  }


  // Validates a name
  String? nameValidator(String? value,
      {int min = 3, int? max, bool canBeEmpty = false}) {
    if ((value == null || value.isEmpty) && !canBeEmpty) {
      return LocaleKeys.emptyField.tr();
    }
    if ((value?.length ?? -1) < min) {
      if (canBeEmpty && (value?.length ?? -1) == 0) return null;
      return LocaleKeys.invalidLength.tr(args: [min.toString()]);
    }

    if ((value?.length ?? (max ?? 10000) + 1) > (max ?? 10000)) {
      if (canBeEmpty && (value?.length ?? 10000) == 0) return null;
      return LocaleKeys.invalidLength
          .tr(args: ["${min.toString()}${max != null ? ' -> $max' : ''}"]);
    }
    return null; // Return null if the value is valid
  }

  // Validates a name
  String? freeNameValidator(String? value,
      {int? min, int? max, bool canBeEmpty = false}) {
    // Check if the value is null or empty and if it cannot be empty
    if ((value == null || value.isEmpty) && !canBeEmpty) {
      return LocaleKeys.emptyField.tr();
    }
    // If the value is empty and canBeEmpty is true, return null (valid)
    if (canBeEmpty && (value?.isEmpty ?? true)) {
      return null;
    }

    // Check minimum length
    if (min != null && (value?.length ?? 0) < min) {
      return LocaleKeys.invalidLength.tr(args: [min.toString()]);
    }

    // Check maximum length
    if (max != null && (value?.length ?? 0) > max) {
      return LocaleKeys.invalidLength.tr(args: ["${min.toString()} -> $max"]);
    }

    // If all checks pass, return null (valid)
    return null;
  }

  // Validates a password
  String? passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return LocaleKeys.emptyField.tr();
    }

    // Check length
    if (value.length < 8 || value.length > 16) {
      return LocaleKeys.invalidLength.tr(args: ["8 -> 16"]);
    }

    // Check for at least one uppercase letter
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return LocaleKeys.missingUppercase.tr();
    }

    // Check for at least one lowercase letter
    if (!value.contains(RegExp(r'[a-z]'))) {
      return LocaleKeys.missingLowercase.tr();
    }

    // Check for specific symbols
    if (!value.contains(RegExp(r'[!@\$%^&*_\-]'))) {
      return LocaleKeys.missingSymbols.tr();
    }

    return null; // Return null if the value is valid
  }

  // Validates a image picker
  String? imageValidator(String? value) {
    if (value == null) {
      return LocaleKeys.chooseAnImage.tr();
    }
    return null; // Return null if the value is valid
  }

  // check form keys validator
  bool checkValidateFormsKeys({
    required List<GlobalKey<FormState>> forms,
    List<bool> successCases = const [],
  }) {
    for (GlobalKey<FormState> form in forms) {
      if (!form.currentState!.validate()) return false;
    }
    return successCases.isEmpty
        ? true
        : successCases.every((element) => element == true);
  }

  String? dateValidator(String? value) {
    if (value == null || value.isEmpty) {
      return LocaleKeys.emptyField.tr();
    }

    // Check if the value matches the pattern
    if (!RegExp(r'^\d{2}-\d{2}-\d{4}$').hasMatch(value)) {
      return LocaleKeys.invalidDateFormat.tr();
    }

    return null; // Return null if the value is valid
  }

  String? amountValidator(String? value,
      {bool canBeEmpty = false,
      num? maxNumber,
      num? minNumber,
      }) {
    if ((value == null || value.isEmpty) && !canBeEmpty) {
      return LocaleKeys.emptyField.tr(); // Not Allow null or empty values
    }

    if (!RegExp(r'^[0-9\u0660-\u0669]*\.?[0-9\u0660-\u0669]*$')
        .hasMatch(value ?? '')) {
      return LocaleKeys.invalidNumber.tr();
    }

    if (maxNumber != null &&
        num.tryParse(value!) != null &&
        num.parse(value) > maxNumber) {
      return LocaleKeys.youMustEnterANumberLessThan
          .tr(args: [maxNumber.toString()]);
    }

    if (minNumber != null &&
        num.tryParse(value!) != null &&
        num.parse(value) <= minNumber) {
      return LocaleKeys.youMustEnterANumberMoreThan
          .tr(args: [minNumber.toString()]);
    }
    return null; // Return null if the value is a valid number
  }

  String? numberValidator(String? value,
      {bool canBeEmpty = false, num? maxNumber, num? minNumber}) {
    if ((value == null || value.isEmpty) && !canBeEmpty) {
      return LocaleKeys.emptyField.tr(); // Not Allow null or empty values
    }

    if (!RegExp(r'^[0-9\u0660-\u0669]*\.?[0-9\u0660-\u0669]*$')
        .hasMatch(value ?? '')) {
      return LocaleKeys.invalidNumber.tr();
    }

    if (maxNumber != null &&
        num.tryParse(value!) != null &&
        num.parse(value) > maxNumber) {
      return LocaleKeys.youMustEnterANumberLessThan
          .tr(args: [maxNumber.toString()]);
    }

    if (minNumber != null &&
        num.tryParse(value!) != null &&
        num.parse(value) <= minNumber) {
      return LocaleKeys.youMustEnterANumberMoreThan
          .tr(args: [minNumber.toString()]);
    }
    return null; // Return null if the value is a valid number
  }

  String? confirmPasswordValidator(String? value, String password) {
    if (value == null || value.isEmpty) {
      return LocaleKeys.emptyField.tr();
    }
    if ((value.length < 8)) return LocaleKeys.invalidLength.tr(args: ["8"]);
    if (value != password) return LocaleKeys.passwordsDoNotMatch.tr();
    return null; // Return null if the value is valid
  }

  String? pinValidator(String? value, {int length = 6}) {
    if (value == null || value.isEmpty) {
      return LocaleKeys.emptyField.tr();
    }
    if ((value.length != length)) {
      return LocaleKeys.invalidPinCode.tr(args: [length.toString()]);
    }
    return null; // Return null if the value is valid
  }

  String? otpValidator(String? value, {int length = 6}) {
    if (value == null || value.isEmpty) {
      return LocaleKeys.emptyField.tr();
    }
    if ((value.length != length)) {
      return LocaleKeys.invalidOtpCode.tr(args: [length.toString()]);
    }
    return null; // Return null if the value is valid
  }
}
