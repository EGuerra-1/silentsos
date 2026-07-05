import 'dart:async';

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/exceptions/app_exception.dart';
import '../models/emergency_model.dart';

/// Permisos y lectura de GPS para el boton SOS.
class LocationService {
  static const Duration _initialFixTimeout = Duration(seconds: 20);
  static const Duration _refineTimeout = Duration(seconds: 12);
  static const double _goodAccuracyMeters = 8;

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

  /// Obtiene la ubicacion mas precisa posible e intenta resolver direccion.
  Future<EmergencyLocation> getCurrentLocation() async {
    await ensureReady();

    final Position position = await _resolveBestPosition();
    final String? address = await _resolveAddress(
      position.latitude,
      position.longitude,
    );

    return EmergencyLocation(
      latitude: position.latitude,
      longitude: position.longitude,
      address: address,
      accuracyMeters: position.accuracy,
    );
  }

  Future<Position> _resolveBestPosition() async {
    Position? best;

    try {
      best = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.bestForNavigation,
          timeLimit: _initialFixTimeout,
        ),
      );
    } catch (_) {
      best = await Geolocator.getLastKnownPosition();
    }

    if (best == null) {
      throw const AppException(
        'No pudimos obtener tu ubicacion. Intenta de nuevo al aire libre.',
      );
    }

    if (best.accuracy <= _goodAccuracyMeters) {
      return best;
    }

    return _refineWithStream(best);
  }

  /// Escucha fixes GPS brevemente y conserva la lectura mas precisa.
  Future<Position> _refineWithStream(Position initial) async {
    Position best = initial;
    final Completer<Position> completer = Completer<Position>();
    StreamSubscription<Position>? subscription;
    Timer? timeout;

    timeout = Timer(_refineTimeout, () {
      subscription?.cancel();
      if (!completer.isCompleted) completer.complete(best);
    });

    subscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 0,
      ),
    ).listen((Position position) {
      if (position.accuracy < best.accuracy) {
        best = position;
      }
      if (position.accuracy <= _goodAccuracyMeters) {
        timeout?.cancel();
        subscription?.cancel();
        if (!completer.isCompleted) completer.complete(best);
      }
    });

    return completer.future.whenComplete(() {
      timeout?.cancel();
      subscription?.cancel();
    });
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
        if ((place.street ?? '').isNotEmpty) place.street!,
        if ((place.subLocality ?? '').isNotEmpty) place.subLocality!,
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
