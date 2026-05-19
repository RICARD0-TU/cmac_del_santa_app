import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter({this.locale = 'es_PE'});

  final String locale;

  String pen(num value) {
    return NumberFormat.currency(
      locale: locale,
      symbol: 'S/ ',
      decimalDigits: 2,
    ).format(value);
  }
}
