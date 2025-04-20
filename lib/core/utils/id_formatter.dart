import 'dart:math';

String formatIdToBase36Short(String uuid, {int length = 8}) {
  final cleanUuid = uuid.replaceAll('-', '');
  final bigInt = BigInt.parse(cleanUuid, radix: 16);
  final base36 = bigInt.toRadixString(36).toUpperCase();
  return base36.length > length ? base36.substring(0, length) : base36;
}

String formatOrderId(String uuid, {int length = 8}) {
  final base36 = formatIdToBase36Short(uuid, length: length);
  return 'ODR-$base36';
}

String formatShiftId(String uuid, {int length = 8}) {
  final base36 = formatIdToBase36Short(uuid, length: length);
  return 'SFT-$base36';
}

String formatIdToBase36WithPrefix(String uuid, {int length = 8}) {
  final parts = uuid.split('-');
  if (parts.length > 2) {
    final cleanUuid = parts.sublist(2).join('');
    final bigInt = BigInt.parse(cleanUuid, radix: 16);
    final base36 = bigInt.toRadixString(36).toUpperCase();
    String formattedId = base36.length > length ? base36.substring(0, length) : base36;
    return 'INV-$formattedId';
  } else {
    throw ArgumentError('UUID format is invalid');
  }
}