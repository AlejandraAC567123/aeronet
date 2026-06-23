import 'package:flutter/material.dart';

Map<String, dynamic> asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return value.map((key, val) => MapEntry('$key', val));
  return <String, dynamic>{};
}

List<dynamic> asList(dynamic value) {
  if (value is List) return value;
  if (value is Map && value['data'] is List) return value['data'] as List;
  if (value is Map && value['items'] is List) return value['items'] as List;
  return [];
}

String money(dynamic value) {
  final number = num.tryParse('$value');
  if (number == null) return 'S/ --';
  return 'S/ ${number.toStringAsFixed(2)}';
}

String shortId(dynamic value) {
  final text = '$value';
  if (text.length <= 8) return text;
  return text.substring(0, 8);
}

void showMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  );
}
