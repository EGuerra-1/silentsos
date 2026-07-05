import 'package:flutter/material.dart';

/// Utilidades de formato para fechas/horas del modulo medico.
abstract final class MedicalFormatters {
  static String formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  static String formatTimeOfDay(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}';
  }

  static TimeOfDay parseTime(String value) {
    final List<String> parts = value.split(':');
    final int hour = int.tryParse(parts.first) ?? 0;
    final int minute = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;
    return TimeOfDay(hour: hour, minute: minute);
  }

  static String displayTime(String value) {
    if (value.length >= 5) return value.substring(0, 5);
    return value;
  }

  /// Normaliza hora para API/comparacion (HH:mm).
  static String toApiTime(String value) => displayTime(value);

  static String displayDate(DateTime? date) {
    if (date == null) return 'Sin fecha';
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}
