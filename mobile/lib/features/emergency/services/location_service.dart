import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/exceptions/app_exception.dart';
import '../models/emergency_model.dart';

/// Permisos y lectura de GPS para el boton SOS.
class LocationService {
  /// Verifica servicio GPS y solicita permiso when-in-use si hace falta.
  Future<void> ensureReady() async {
    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const AppException(
        'Activa el GPS del dispositivo para enviar tu ubicacion.',
      );
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw const AppException(
        'Necesitamos permiso de ubicacion para activar la emergencia.',
      );
    }

    if (permission == LocationPermission.deniedForever) {
      throw const AppException(
        'Permiso de ubicacion denegado. Habilitalo en Ajustes del telefono.',
      );
    }
  }

  /// Obtiene coordenadas actuales e intenta resolver una direccion legible.
  Future<EmergencyLocation> getCurrentLocation() async {
    await ensureReady();

    final Position position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 15),
      ),
    );

    final String? address = await _resolveAddress(
      position.latitude,
      position.longitude,
    );

    return EmergencyLocation(
      latitude: position.latitude,
      longitude: position.longitude,
      address: address,
    );
  }

  Future<String?> _resolveAddress(double latitude, double longitude) async {
    try {
      final List<Placemark> marks = await Geocoding().placemarkFromCoordinates(
        latitude,
        longitude,
      );
      if (marks.isEmpty) return null;

      final Placemark place = marks.first;
      final List<String> parts = <String>[
        if ((place.locality ?? '').isNotEmpty) place.locality!,
        if ((place.administrativeArea ?? '').isNotEmpty)
          place.administrativeArea!,
        if ((place.country ?? '').isNotEmpty) place.country!,
      ];
      if (parts.isEmpty) return null;
      return parts.join(', ');
    } catch (_) {
      return null;
    }
  }
}
