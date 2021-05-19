/// convert the input to a string
String toString(input) {
  if (input == null || (input is List && input.isEmpty)) {
    input = '';
  }
  return input.toString();
}

/// convert the input to a date, or null if the input is not a date
DateTime? toDate(String str) {
  try {
    return DateTime.parse(str);
  } catch (e) {
    return null;
  }
}

/// convert the input to a float, or NAN if the input is not a float
double toFloat(String str) {
  try {
    return double.parse(str);
  } catch (e) {
    return double.nan;
  }
}

/// convert the input to a float, or NAN if the input is not a float
double toDouble(String str) {
  return toFloat(str);
}

/// convert the input to an integer, or NAN if the input is not an integer
num toInt(String str, {int radix = 10}) {
  try {
    return int.parse(str, radix: radix);
  } catch (e) {
    try {
      return double.parse(str).toInt();
    } catch (e) {
      return double.nan;
    }
  }
}

/// trim characters (whitespace by default) from both sides of the input
String trim(String str, [String? chars]) {
  RegExp pattern = (chars != null) ? RegExp('^[$chars]+|[$chars]+\$') : RegExp(r'^\s+|\s+$');
  return str.replaceAll(pattern, '');
}

/// trim characters from the left-side of the input
String trimLeft(String str, [String? chars]) {
  var pattern = chars != null ? RegExp('^[$chars]+') : RegExp(r'^\s+');
  return str.replaceAll(pattern, '');
}

/// trim characters from the right-side of the input
String trimRight(String str, [String? chars]) {
  var pattern = chars != null ? RegExp('[$chars]+\$') : RegExp(r'\s+$');
  return str.replaceAll(pattern, '');
}

/// remove characters that do not appear in the whitelist.
///
/// The characters are used in a RegExp and so you will need to escape
/// some chars.
String whitelist(String str, String chars) {
  return str.replaceAll(RegExp('[^' + chars + ']+'), '');
}

/// remove characters that appear in the blacklist.
///
/// The characters are used in a RegExp and so you will need to escape
/// some chars.
String blacklist(String str, String chars) {
  return str.replaceAll(RegExp('[' + chars + ']+'), '');
}

/// remove characters with a numerical value < 32 and 127.
///
/// If `keep_new_lines` is `true`, newline characters are preserved
/// `(\n and \r, hex 0xA and 0xD)`.
String stripLow(String str, [bool? keepNewLines]) {
  String chars = keepNewLines == true ? '\x00-\x09\x0B\x0C\x0E-\x1F\x7F' : '\x00-\x1F\x7F';
  return blacklist(str, chars);
}

/// replace `<`, `>`, `&`, `'` and `"` with HTML entities
String escape(String str) {
  return (str
      .replaceAll(RegExp(r'&'), '&amp;')
      .replaceAll(RegExp(r'"'), '&quot;')
      .replaceAll(RegExp(r"'"), '&#x27;')
      .replaceAll(RegExp(r'<'), '&lt;')
      .replaceAll(RegExp(r'>'), '&gt;'));
}
