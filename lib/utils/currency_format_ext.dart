import 'package:intl/intl.dart';

extension CurrencyFormatExt on num {
  String get toCurrency {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: '',
      decimalDigits: 0,
    ).format(this);
  }
}
