import 'package:flutter/widgets.dart';

import '../../l10n/app_localizations.dart';

// Form rules, in the same wording and limits as the API (so a form that passes here passes there).
class Validators {
  const Validators(this.l10n);

  final AppLocalizations l10n;

  static final _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  static final _phone = RegExp(r'^(\+20|0020|0)?1[0125][0-9]{8}$');
  static final _password = RegExp(
    r'(?=.*[0-9])(?=.*[!@#$%^&*()\\\\\[\]{}\-_+=~`|:;"<>,./?\x27])(?=.*[a-z])(?=.*[A-Z]).{8,}',
  );

  FormFieldValidator<String> get required =>
      (value) => (value == null || value.trim().isEmpty) ? l10n.fieldRequired : null;

  FormFieldValidator<String> get email => (value) {
    if (required(value) case final error?) return error;
    return _email.hasMatch(value!.trim()) ? null : l10n.invalidEmail;
  };

  FormFieldValidator<String> get password => (value) {
    if (required(value) case final error?) return error;
    return _password.hasMatch(value!) ? null : l10n.passwordRule;
  };

  FormFieldValidator<String> get name => (value) {
    if (required(value) case final error?) return error;
    return value!.trim().length >= 3 ? null : l10n.nameTooShort;
  };

  FormFieldValidator<String> get phone => (value) {
    if (required(value) case final error?) return error;
    return _phone.hasMatch(value!.trim()) ? null : l10n.invalidPhone;
  };

  FormFieldValidator<String> matches(TextEditingController other) =>
      (value) => value == other.text ? null : l10n.passwordsDontMatch;
}
