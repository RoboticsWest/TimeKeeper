import 'package:fixnum/fixnum.dart';
import 'package:time_keeper/generated/common/common.pb.dart';

extension TimestampConversion on Timestamp {
  DateTime toDateTime() {
    return DateTime.fromMillisecondsSinceEpoch(
      seconds.toInt() * 1000,
      isUtc: true,
    ).toLocal();
  }
}

extension DateTimeToTimestamp on DateTime {
  Timestamp toTimestamp() {
    return Timestamp(seconds: Int64(toUtc().millisecondsSinceEpoch ~/ 1000));
  }
}
