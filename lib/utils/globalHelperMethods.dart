bool isNullOrBlank(String? string) {
  if (string == null) return true;
  string = string.trim();
  // if (string == null) return true;
  if (string.isEmpty) return true;
  return false;
}

String? squeezeNumbers(int? number) {
  if (number == null) return null;
  if (number < 1000) return number.toString();
  if (number < 1000000) return (number / 1000).toString() + "K";
  if (number < 1000000000) return (number / 1000000).toString() + "M";
  if (number < 1000000000000) return (number / 1000000000).toString() + "B";
  return number.toString();
}
