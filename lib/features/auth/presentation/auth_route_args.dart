enum OtpPurpose { confirmEmail, resetPassword }

class OtpArgs {
  const OtpArgs({required this.email, required this.purpose});

  final String email;
  final OtpPurpose purpose;
}

class NewPasswordArgs {
  const NewPasswordArgs({required this.email, required this.code});

  final String email;
  final String code;
}
