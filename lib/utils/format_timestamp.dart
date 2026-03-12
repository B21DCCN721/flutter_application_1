String formatTimestamp(dynamic timestamp) {
  if (timestamp == null || timestamp == 0 || timestamp == "") return "-";
  try {
    int ts = timestamp is String ? int.parse(timestamp) : timestamp;
    if (ts == 0) return "-";
    DateTime date = DateTime.fromMillisecondsSinceEpoch(ts * 1000);
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  } catch (e) {
    return "-";
  }
}
