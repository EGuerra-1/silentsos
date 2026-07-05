/// Textos centralizados de la app (es-SV), fieles a las pantallas de Stitch.
abstract final class AppStrings {
  static const String appName = 'SilentSOS';

  // Splash
  static const String splashSubtitle =
      'Coordinacion de emergencias segura y discreta.';

  // Login
  static const String loginTitle = 'Hola, estamos aqui para ayudarte';
  static const String loginSubtitle =
      'Inicia sesion en SilentSOS para continuar de forma segura.';
  static const String loginEmailLabel = 'Correo electronico';
  static const String loginPasswordLabel = 'Contrasena';
  static const String loginSubmit = 'Entrar';
  static const String loginLegalPrefix = 'Al continuar, aceptas nuestros ';
  static const String loginError =
      'Contrasena incorrecta. Intentalo de nuevo.';
  static const String loginCreateAccount = 'Crear cuenta nueva';

  // Registro paso 1
  static const String registerStepOneBadge = 'PASO 1 DE 2';
  static const String registerStepOneTitle = 'Your Data';
  static const String registerStepOneTitleEs = 'Tus datos';
  static const String registerStepOneSubtitle =
      'Proporciona tus datos esenciales para configurar tu perfil seguro. '
      'Esta informacion permanece cifrada.';
  static const String registerFullName = 'Nombre completo';
  static const String registerPhone = 'Numero de telefono';
  static const String registerEmail = 'Correo electronico';
  static const String registerPassword = 'Contrasena';
  static const String registerNextStep = 'Siguiente paso';
  static const String registerEncrypted = 'Cifrado de extremo a extremo';

  // Registro paso 2
  static const String registerStepTwoBadge = 'PASO 2 DE 2';
  static const String registerStepTwoTitle = 'Alguien que te cuide';
  static const String registerStepTwoSubtitle =
      'En caso de emergencia, notificaremos automaticamente a esta persona '
      'con tu ubicacion y un resumen de la situacion.';
  static const String contactNameLabel = 'Nombre completo del contacto';
  static const String contactNameHint = 'Ej: Maria Garcia';
  static const String contactPhoneLabel = 'Telefono del contacto';
  static const String contactPhoneHint = '+503 7000 0000';
  static const String contactRelationshipLabel = 'Relacion contigo';
  static const String contactRelationshipHint = 'Selecciona el parentesco';
  static const String contactPrivacyNote =
      'Tus contactos estan cifrados de extremo a extremo. Solo se contactara '
      'con ellos si tu activas una alerta de SOS.';
  static const String registerFinish = 'Finalizar Registro';

  // Validaciones
  static const String validationRequired = 'Este campo es obligatorio';
  static const String validationEmail = 'Ingresa un correo electronico valido';
  static const String validationPasswordLength =
      'Debe tener al menos 8 caracteres';
  static const String validationPasswordMatch =
      'Las contrasenas no coinciden';
}
