mixin FormValidationMixin {
  String? phoneNumberValidation(String? value) {
    if (value == null || value.toString().isEmpty) {
      return 'This field is required';
    }
    final regx = RegExp(r'(^(?:[+0]9)?[0-9]{10,12}$)');
    if (!regx.hasMatch(value.toString())) {
      return 'Please enter a valid Phone Number';
    }
    return null;
  }

  String? nameValidation(String? value) {
    if (value == null || value.toString().isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  String? emptyValidation(String? value) {
    if (value == null || value.toString().isEmpty) {
      return 'can not send empty messages';
    }
    return null;
  }
}
