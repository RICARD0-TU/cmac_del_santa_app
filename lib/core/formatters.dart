part of cmac_del_santa_app;

String money(dynamic value) {
  final amount = amountValue(value);
  return 'S/ ${amount.toStringAsFixed(2)}';
}

double amountValue(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse('$value') ?? 0;
}

String dateText(dynamic value) {
  if (value == null) return '-';
  final text = '$value';
  return text.length >= 10 ? text.substring(0, 10) : text;
}

String readableOperation(dynamic value) {
  switch ('$value') {
    case 'pago_cuota':
      return 'Pago de cuota';
    case 'pago_servicio':
      return 'Pago de servicio';
    case 'solicitud_credito':
      return 'Solicitud de credito';
    default:
      return 'Transferencia';
  }
}

Widget dropdownText(String text) {
  return LayoutBuilder(
    builder: (context, constraints) {
      final width = constraints.maxWidth.isFinite ? constraints.maxWidth : 180.0;
      return SizedBox(
        width: width,
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          softWrap: false,
        ),
      );
    },
  );
}

double powSimple(double base, int exponent) {
  var result = 1.0;
  for (var i = 0; i < exponent; i++) {
    result *= base;
  }
  return result;
}
