/// Parentescos disponibles para contacto de emergencia.
abstract final class EmergencyRelationshipOptions {
  static const List<String> values = <String>[
    'Madre',
    'Padre',
    'Hermano/a',
    'Pareja',
    'Amigo/a',
    'Otro',
  ];

  static const Map<String, String> _englishToSpanish = <String, String>{
    'mother': 'Madre',
    'father': 'Padre',
    'brother': 'Hermano/a',
    'sister': 'Hermano/a',
    'sibling': 'Hermano/a',
    'partner': 'Pareja',
    'spouse': 'Pareja',
    'friend': 'Amigo/a',
    'other': 'Otro',
  };

  /// Convierte valores del API (ingles o espanol) al valor del selector UI.
  static String normalize(String raw) {
    final String trimmed = raw.trim();
    if (trimmed.isEmpty) return values.last;

    if (values.contains(trimmed)) return trimmed;

    final String? mapped = _englishToSpanish[trimmed.toLowerCase()];
    if (mapped != null) return mapped;

    return trimmed;
  }

  /// Opciones del dropdown incluyendo un valor legacy/custom si no esta en la lista.
  static List<String> dropdownItems(String? selected) {
    if (selected == null ||
        selected.isEmpty ||
        values.contains(selected)) {
      return values;
    }
    return <String>[...values, selected];
  }
}
