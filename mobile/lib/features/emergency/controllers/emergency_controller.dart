import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/exceptions/app_exception.dart';
import '../../../core/services/app_logger.dart';
import '../models/emergency_model.dart';
import '../services/emergency_service.dart';

/// Fases visibles del flujo SOS en la UI.
enum EmergencyFlowPhase {
  idle,
  locating,
  sending,
  tracking,
  completed,
  failed,
}

/// Estado consolidado del boton de emergencia.
class EmergencyFlowState {
  const EmergencyFlowState({
    this.selectedType = EmergencyType.medical,
    this.phase = EmergencyFlowPhase.idle,
    this.locationReady = false,
    this.locationLabel,
    this.emergency,
    this.errorMessage,
    this.isContextual = false,
  });

  final EmergencyType selectedType;
  final EmergencyFlowPhase phase;
  final bool locationReady;
  final String? locationLabel;
  final EmergencyModel? emergency;
  final String? errorMessage;
  final bool isContextual;

  bool get isBusy =>
      phase == EmergencyFlowPhase.locating ||
      phase == EmergencyFlowPhase.sending ||
      phase == EmergencyFlowPhase.tracking;

  EmergencyFlowState copyWith({
    EmergencyType? selectedType,
    EmergencyFlowPhase? phase,
    bool? locationReady,
    String? locationLabel,
    EmergencyModel? emergency,
    String? errorMessage,
    bool? isContextual,
    bool clearError = false,
    bool clearEmergency = false,
  }) {
    return EmergencyFlowState(
      selectedType: selectedType ?? this.selectedType,
      phase: phase ?? this.phase,
      locationReady: locationReady ?? this.locationReady,
      locationLabel: locationLabel ?? this.locationLabel,
      emergency: clearEmergency ? null : emergency ?? this.emergency,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      isContextual: isContextual ?? this.isContextual,
    );
  }
}

/// Controlador del flujo SOS: permisos, envio y polling de estado.
class EmergencyController extends StateNotifier<EmergencyFlowState> {
  EmergencyController(this._service) : super(const EmergencyFlowState());

  final EmergencyService _service;
  Timer? _pollTimer;
  bool _disposed = false;
  int _pollFailures = 0;
  static const int _maxPollFailures = 5;

  @override
  void dispose() {
    _disposed = true;
    _pollTimer?.cancel();
    super.dispose();
  }

  void selectType(EmergencyType type) {
    if (state.isBusy) return;
    state = state.copyWith(selectedType: type, clearError: true);
  }

  /// Pre-calienta permisos al abrir la pestana Emergencias.
  Future<void> prepareLocation() async {
    if (state.isBusy) return;

    try {
      await _service.ensureLocationPermission();
      if (_disposed) return;
      state = state.copyWith(locationReady: true, clearError: true);
    } catch (error) {
      AppLogger.error('[Emergency] permiso GPS', error: error);
      if (_disposed) return;
      state = state.copyWith(
        locationReady: false,
        errorMessage: _messageFrom(error),
      );
    }
  }

  /// Flujo completo: GPS -> POST urgency -> polling GET /emergencies/:id.
  Future<void> triggerSos() async {
    if (state.isBusy) return;

    state = state.copyWith(
      phase: EmergencyFlowPhase.locating,
      isContextual: false,
      clearError: true,
      clearEmergency: true,
    );

    try {
      final EmergencyLocation location = await _service.getCurrentLocation();
      if (_disposed) return;

      state = state.copyWith(
        phase: EmergencyFlowPhase.sending,
        locationReady: true,
        locationLabel: _locationLabel(location),
      );

      final EmergencyModel created = await _service.triggerUrgency(
        type: state.selectedType,
        location: location,
      );
      if (_disposed) return;
      if (created.id.isEmpty) {
        throw const AppException(
          'El servidor no devolvio el identificador de la emergencia.',
        );
      }

      state = state.copyWith(
        phase: EmergencyFlowPhase.tracking,
        emergency: created,
      );
      _startPolling(created.id);
    } catch (error) {
      AppLogger.error('[Emergency] trigger SOS fallo', error: error);
      if (_disposed) return;
      state = state.copyWith(
        phase: EmergencyFlowPhase.failed,
        errorMessage: _messageFrom(error),
      );
    }
  }

  /// Flujo contextual: GPS preciso -> fotos + texto -> POST contextual -> polling.
  Future<void> triggerContextual(ContextualEmergencyPayload payload) async {
    if (state.isBusy) return;

    state = state.copyWith(
      phase: EmergencyFlowPhase.locating,
      isContextual: true,
      clearError: true,
      clearEmergency: true,
    );

    try {
      final EmergencyLocation location = await _service.getCurrentLocation();
      if (_disposed) return;

      state = state.copyWith(
        phase: EmergencyFlowPhase.sending,
        locationReady: true,
        locationLabel: _locationLabel(location),
      );

      final EmergencyModel created = await _service.triggerContextual(
        payload: payload,
        location: location,
      );
      if (_disposed) return;
      if (created.id.isEmpty) {
        throw const AppException(
          'El servidor no devolvio el identificador de la emergencia.',
        );
      }

      state = state.copyWith(
        phase: EmergencyFlowPhase.tracking,
        emergency: created,
      );
      _startPolling(created.id);
    } catch (error) {
      AppLogger.error('[Emergency] trigger contextual fallo', error: error);
      if (_disposed) return;
      state = state.copyWith(
        phase: EmergencyFlowPhase.failed,
        errorMessage: _messageFrom(error),
      );
    }
  }

  void reset() {
    _pollTimer?.cancel();
    state = const EmergencyFlowState();
    unawaited(prepareLocation());
  }

  void _startPolling(String emergencyId) {
    _pollTimer?.cancel();
    _pollFailures = 0;
    _pollTimer = Timer.periodic(const Duration(seconds: 2), (_) async {
      try {
        final EmergencyModel latest =
            await _service.pollStatus(emergencyId);
        if (_disposed) return;

        _pollFailures = 0;

        final EmergencyFlowPhase nextPhase = latest.status.isTerminal
            ? (latest.status == EmergencyStatus.completed
                ? EmergencyFlowPhase.completed
                : EmergencyFlowPhase.failed)
            : EmergencyFlowPhase.tracking;

        state = state.copyWith(
          emergency: latest,
          phase: nextPhase,
        );

        if (latest.status.isTerminal) {
          _pollTimer?.cancel();
        }
      } catch (error) {
        _pollFailures++;
        AppLogger.error(
          '[Emergency] polling fallo ($_pollFailures/$_maxPollFailures)',
          error: error,
        );
        if (_disposed) return;
        if (_pollFailures >= _maxPollFailures) {
          _pollTimer?.cancel();
          state = state.copyWith(
            phase: EmergencyFlowPhase.failed,
            errorMessage: _messageFrom(error),
          );
        }
      }
    });
  }

  String _messageFrom(Object error) {
    final String raw = error.toString();
    const String prefix = 'AppException(';
    if (raw.startsWith(prefix) && raw.endsWith(')')) {
      return raw.substring(prefix.length, raw.length - 1);
    }
    return 'No fue posible activar la emergencia.';
  }

  String _locationLabel(EmergencyLocation location) {
    final String coords =
        '${location.latitude.toStringAsFixed(6)}, '
        '${location.longitude.toStringAsFixed(6)}';
    final String? accuracy = location.accuracyMeters == null
        ? null
        : '±${location.accuracyMeters!.round()} m';
    final String base = location.address ?? coords;
    if (accuracy == null) return base;
    return '$base ($accuracy)';
  }
}
