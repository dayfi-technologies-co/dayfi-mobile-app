
class StringUtils {

  static bool isNullOrEmpty(String? value) {
    return value == null || value.isEmpty;
  }


  static String toTitleCase(String text) {
    if (isNullOrEmpty(text)) return text;
    return text
        .split(' ')
        .map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }

  static String removeWhitespace(String text) {
    return text.replaceAll(RegExp(r'\s+'), '');
  }
}
