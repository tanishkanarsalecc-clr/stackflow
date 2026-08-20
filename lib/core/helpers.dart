String formatCurrency(double value) {
  final rounded = value.round().toString();

  if (rounded.length <= 3) {
    return '₹$rounded';
  }

  String result = '';

  int firstLength = rounded.length % 3;

  if (firstLength == 0) {
    firstLength = 3;
  }

  result = rounded.substring(0, firstLength);

  for (int i = firstLength; i < rounded.length; i += 2) {
    final end = i + 2;

    if (end <= rounded.length) {
      result += ',${rounded.substring(i, end)}';
    } else {
      result += ',${rounded.substring(i)}';
    }

    if (end >= rounded.length) {
      break;
    }
  }

  return '₹$result';
}