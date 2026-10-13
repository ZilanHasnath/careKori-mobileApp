String asString(dynamic value, [String fallback = '']) =>
    value == null ? fallback : value.toString();

String? asNullableString(dynamic value) {
  final text = value?.toString().trim();
  return (text == null || text.isEmpty) ? null : text;
}

int asInt(dynamic value, [int fallback = 0]) {
  if (value is num) return value.toInt();
  return int.tryParse(asString(value)) ?? fallback;
}

double asDouble(dynamic value, [double fallback = 0]) {
  if (value is num) return value.toDouble();
  return double.tryParse(asString(value)) ?? fallback;
}

DateTime? asDate(dynamic value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString())?.toLocal();
}

List<String> asStringList(dynamic value) =>
    value is List ? value.map((e) => e.toString()).toList() : const [];

Map<String, dynamic>? asMap(dynamic value) =>
    value is Map ? Map<String, dynamic>.from(value) : null;

List<Map<String, dynamic>> asMapList(dynamic value) => value is List
    ? value.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList()
    : const [];

String idOf(dynamic value) =>
    value is Map ? asString(value['_id']) : asString(value);
