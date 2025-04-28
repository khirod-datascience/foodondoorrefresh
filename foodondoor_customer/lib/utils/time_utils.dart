import 'package:intl/intl.dart';

class TimeUtils {
  static String formatLocalTime(DateTime utcTime) {
    final localTime = utcTime.toLocal();
    final formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    return formatter.format(localTime);
  }
}
