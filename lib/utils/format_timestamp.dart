String formatTimestamp(dynamic timestamp, {bool showTime = false}) {
  if (timestamp == null || timestamp == 0 || timestamp == "") return "-";
  try {
    int ts = timestamp is String ? int.parse(timestamp) : timestamp;
    if (ts == 0) return "-";
    DateTime date = DateTime.fromMillisecondsSinceEpoch(ts * 1000);
    String day = date.day.toString().padLeft(2, '0');
    String month = date.month.toString().padLeft(2, '0');
    String dateStr = "$day/$month/${date.year}";

    if (showTime) {
      String hour = date.hour.toString().padLeft(2, '0');
      String minute = date.minute.toString().padLeft(2, '0');
      return "$hour:$minute - $dateStr";
    }
    return dateStr;
  } catch (e) {
    return "-";
  }
}
