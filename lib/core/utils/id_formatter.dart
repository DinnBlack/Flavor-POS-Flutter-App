String formatIdToBase36Short(String uuid, {int length = 8}) {
  final cleanUuid = uuid.replaceAll('-', '');
  final bigInt = BigInt.parse(cleanUuid, radix: 16);
  final base36 = bigInt.toRadixString(36).toUpperCase();
  return base36.length > length ? base36.substring(0, length) : base36;
}