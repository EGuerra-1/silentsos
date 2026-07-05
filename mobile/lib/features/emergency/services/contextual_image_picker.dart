import 'package:image_picker/image_picker.dart';

/// Resultado de la captura secuencial trasera + frontal.
class ContextualImageCaptureResult {
  const ContextualImageCaptureResult({
    required this.frontImagePath,
    required this.backImagePath,
  });

  final String frontImagePath;
  final String backImagePath;
}

/// Captura automatica de ambas camaras en secuencia.
class ContextualImagePicker {
  ContextualImagePicker._();

  static final ImagePicker _picker = ImagePicker();

  /// Abre camara trasera y luego frontal. Cancelar en cualquier paso aborta.
  static Future<ContextualImageCaptureResult?> captureBoth() async {
    final String? backPath = await _capture(CameraDevice.rear);
    if (backPath == null) return null;

    final String? frontPath = await _capture(CameraDevice.front);
    if (frontPath == null) return null;

    return ContextualImageCaptureResult(
      frontImagePath: frontPath,
      backImagePath: backPath,
    );
  }

  static Future<String?> _capture(CameraDevice device) async {
    final XFile? file = await _picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: device,
      imageQuality: 85,
      maxWidth: 1920,
    );
    return file?.path;
  }
}
