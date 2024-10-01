enum SecurityType {
  pincode("pincode"),
  biometric("biometric");

  const SecurityType(this.value);
  final String value;

  static SecurityType? fromString(String value) {
    return values.firstWhere((type) => type.toString().split(".").last == value);
  }
}
