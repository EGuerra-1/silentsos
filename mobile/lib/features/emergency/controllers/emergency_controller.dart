import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  });

  final EmergencyType selectedType;
  final EmergencyFlowPhase phase;
  final bool locationReady;
  final String? locationLabel;
  final EmergencyModel? emergency;
  final String? errorMessage;

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
    );
  }
}

/// Controlador del flujo SOS: permisos, envio y polling de estado.
class EmergencyController extends StateNotifier<EmergencyFlowState> {
  EmergencyController(this._service) : super(const EmergencyFlowState());

  final EmergencyService _service;
  Timer? _pollTimer;
  bool _disposed = false;

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
      clearError: true,
      clearEmergency: true,
    );

    try {
      final EmergencyLocation location = await _service.getCurrentLocation();
      if (_disposed) return;

      state = state.copyWith(
        phase: EmergencyFlowPhase.sending,
        locationReady: true,
        locationLabel: location.address ??
            '${location.latitude.toStringAsFixed(5)}, '
                '${location.longitude.toStringAsFixed(5)}',
      );

      final EmergencyModel created = await _service.triggerUrgency(
        type: state.selectedType,
        location: location,
      );
      if (_disposed) return;

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

  void reset() {
    _pollTimer?.cancel();
    state = const EmergencyFlowState();
    unawaited(prepareLocation());
  }

  void _startPolling(String emergencyId) {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 2), (_) async {
      try {
        final EmergencyModel latest =
            await _service.pollStatus(emergencyId);
        if (_disposed) return;

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
        AppLogger.error('[Emergency] polling fallo', error: error);
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
}
