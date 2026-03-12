String getCourseDescription(String html) {
  if (html.isEmpty) return "";

  final match = RegExp(
    r'<span id="docs-internal[^>]*>(.*?)</span>',
    dotAll: true,
  ).firstMatch(html);

  if (match != null) {
    String text = match.group(1) ?? "";

    // bỏ HTML tag còn sót
    text = text.replaceAll(RegExp(r'<[^>]*>'), '');

    // bỏ &nbsp;
    text = text.replaceAll('&nbsp;', ' ');

    return text.trim();
  }

  return "";
}
