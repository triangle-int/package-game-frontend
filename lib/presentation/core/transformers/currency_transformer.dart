extension CurrencyTransformerIntX on int {
  String toCurrency() {
    final suffixes = ['', 'K', 'M', 'B', 'T', 'P', 'E', 'Z', 'Y'];
    double d = toDouble();

    int i = 0;
    while (d >= 1000 && i < suffixes.length - 1) {
      i++;
      d = d / 1000;
    }

    if (i > 0) {
      final result = (d * 10).floor();
      return '${(result / 10.0).toStringAsFixed(1)}${suffixes[i]}';
    }
    return d.floor().toString();
  }
}

extension CurrencyTransformerBigIntX on BigInt {
  String toCurrency() {
    final suffixes = ['', 'K', 'M', 'B', 'T', 'P', 'E', 'Z', 'Y'];
    double d = toDouble();

    String prefix = '';
    if (d.isNegative) {
      prefix = '-';
      d = d.abs();
    }

    int i = 0;
    while (d >= 1000 && i < suffixes.length - 1) {
      i++;
      d = d / 1000;
    }

    if (i > 0) {
      final result = (d * 10).floor();
      return '$prefix${(result / 10.0).toStringAsFixed(1)}${suffixes[i]}';
    }
    return '$prefix${d.floor()}';
  }
}
