import 'dart:math';

const String _lettersLowercase = "abcdefghijklmnopqrstuvwxyz"; // cSpell: disable-line
const String _lettersUppercase = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"; // cSpell: disable-line
const String _numbers = "0123456789";
const String _special = "@#=+!£\$%&?[](){}";

/// original source code is
/// [here](https://github.com/imtheguna/random_password_generator/blob/main/lib/random_password_generator.dart)
/// * return random password
String randomPassword({
  bool letters = true,
  bool uppercase = false,
  bool numbers = false,
  bool specialChar = false,
  int passwordLength = 8,
}) {
  assert(letters || uppercase || specialChar || numbers);

  final String sourceChars = (letters ? _lettersLowercase : '') +
      (uppercase ? _lettersUppercase : '') +
      (numbers ? _numbers : '') +
      (specialChar ? _special : '');

  // generate random password
  String result = "";
  while (result.length < passwordLength) {
    final index = Random.secure().nextInt(sourceChars.length);
    result += sourceChars[index];
  }

  return result;
}

/// return random ip address
String randomIp() {
  final a = Random.secure().nextInt(255);
  final b = Random.secure().nextInt(255);
  final c = Random.secure().nextInt(255);
  final d = Random.secure().nextInt(255);
  return "$a.$b.$c.$d";
}
