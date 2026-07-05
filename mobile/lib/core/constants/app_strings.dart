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

  // Salud / modulo medico
  static const String healthTitle = 'Salud';
  static const String diseasesTab = 'Enfermedades';
  static const String medicationsTab = 'Medicamentos';
  static const String diseasesSectionSubtitle =
      'Registra y administra tus condiciones medicas.';
  static const String medicationsSectionSubtitle =
      'Controla tus dosis del dia y tus tratamientos.';
  static const String medicationsTodaySubtitle =
      'Marca las dosis que ya tomaste hoy.';
  static const String medicationsManageSubtitle =
      'Consulta, edita y agrega tus medicamentos.';
  static const String diseasesEmpty =
      'Aun no tienes enfermedades registradas. Agrega la primera para '
      'completar tu perfil medico.';
  static const String medicationsEmpty =
      'Aun no tienes medicamentos registrados. Crea tu primer tratamiento '
      'con horarios de toma.';
  static const String addDisease = 'Agregar enfermedad';
  static const String editDisease = 'Editar enfermedad';
  static const String addMedication = 'Agregar medicamento';
  static const String addMedicationShort = 'Agregar';
  static const String editMedication = 'Actualizar tratamiento';
  static const String saveChanges = 'Guardar cambios';
  static const String diseaseCatalogLabel = 'Enfermedad del catalogo';
  static const String diseaseCatalogHint = 'Selecciona una enfermedad';
  static const String diseaseNotesLabel = 'Notas (opcional)';
  static const String diseaseNotesHint = 'Ej: Diagnosticada hace 5 anos';
  static const String diseaseDiagnosedLabel = 'Fecha de diagnostico (opcional)';
  static const String medicationTitleLabel = 'Titulo del tratamiento (opcional)';
  static const String medicationNameLabel = 'Nombre del medicamento';
  static const String medicationDoseLabel = 'Dosis';
  static const String medicationUnitLabel = 'Unidad';
  static const String medicationFrequencyLabel = 'Frecuencia';
  static const String medicationObservationsLabel = 'Observaciones (opcional)';
  static const String schedulesLabel = 'Horarios de toma';
  static const String addSchedule = 'Agregar horario';
  static const String scheduleNotesHint = 'Nota del horario (opcional)';
  static const String pendingToday = 'Pendientes de hoy';
  static const String medicationsTodayTab = 'Hoy';
  static const String medicationsManageTab = 'Tratamientos';
  static const String pendingEmpty =
      'No tienes dosis pendientes por ahora. Buen trabajo.';
  static const String markTaken = 'Ya lo tome';
  static const String myMedications = 'Mis medicamentos';
  static const String myDiseases = 'Mis enfermedades';
  static const String consumptionHistory = 'Historial de tomas';
  static const String consumptionHistoryEmpty =
      'Aun no hay registros de consumo en los ultimos 7 dias.';
  static const String recentActivity = 'Actividad reciente';
  static const String markConsumed = 'Tomado';
  static const String markSkipped = 'Omitido';
  static const String markMissed = 'Perdido';
  static const String loadMedicalError =
      'No fue posible cargar tu informacion medica.';
  static const String saveMedicalError =
      'No fue posible guardar los cambios. Intentalo de nuevo.';
  static const String selectDiseaseRequired =
      'Selecciona una enfermedad del catalogo';
  static const String scheduleRequired =
      'Agrega al menos un horario de toma';

  // Ajustes / perfil
  static const String settingsTitle = 'Ajustes';
  static const String settingsAppearance = 'Apariencia';
  static const String settingsProfileSection = 'Perfil';
  static const String settingsAccountSection = 'Cuenta';
  static const String settingsEditProfile = 'Editar datos personales';
  static const String settingsEditEmergencyContact = 'Contacto de emergencia';
  static const String settingsLogout = 'Cerrar sesion';
  static const String settingsLogoutConfirmTitle = 'Cerrar sesion';
  static const String settingsLogoutConfirmBody =
      'Se cerrara tu sesion en este dispositivo. Deberas iniciar '
      'sesion de nuevo para continuar.';
  static const String settingsCancel = 'Cancelar';
  static const String editProfileTitle = 'Editar perfil';
  static const String editProfileSubtitle =
      'Actualiza tu nombre, telefono, correo o contrasena.';
  static const String editProfilePasswordHint =
      'Nueva contrasena (opcional)';
  static const String editEmergencyContactTitle = 'Editar contacto';
  static const String editEmergencyContactSubtitle =
      'Esta persona sera notificada en caso de emergencia.';
  static const String loadProfileError =
      'No fue posible cargar tu perfil. Intentalo de nuevo.';
  static const String saveProfileError =
      'No fue posible guardar los cambios. Intentalo de nuevo.';
  static const String emergencyContactMissing =
      'No tienes un contacto de emergencia registrado.';

  // Emergencias / SOS
  static const String emergencyTabTitle = 'Emergencias';
  static const String emergencyDashboardTitle = 'Centro de emergencias';
  static const String emergencyDashboardSubtitle =
      'Activa ayuda inmediata o envia contexto visual con IA.';
  static const String emergencyDashboardActiveTitle = 'Protocolo activo';
  static const String emergencyDashboardLiveBadge = 'En vivo';
  static const String emergencyDashboardContextBadge = 'Con Vision IA';
  static const String emergencyTrackingStepsTitle = 'Progreso del protocolo';
  static const String emergencyTrackingStepActive = 'Paso en curso';
  static const String emergencyHeroTitle = 'Ayuda cuando la necesites';
  static const String emergencyHeroBadge = 'Proteccion activa';
  static const String emergencyHeroSubtitle =
      'Un toque activa llamada a emergencias, comparte tu ubicacion y '
      'notifica a tu contacto de confianza.';
  static const String emergencyConfigSection = 'Tipo de alerta';
  static const String emergencyModesSection = 'Como activar la ayuda';
  static const String emergencyModesOr = 'o';
  static const String emergencySosModeTitle = 'SOS rapido';
  static const String emergencySosModeSubtitle =
      'Alerta inmediata con ubicacion precisa.';
  static const String emergencyContextModeTitle = 'Con contexto';
  static const String emergencyContextModeSubtitle =
      'Captura escena y rostro; la IA analiza y llama.';
  static const String emergencyContextCaptureShort = 'Fotos';
  static const String emergencyContextCapturingShort = '...';
  static const String emergencyContextCapturing =
      'Abriendo camaras: escena y rostro...';
  static const String emergencyPhaseIdleDual =
      'SOS arriba para alerta rapida. Abajo para emergencia con fotos.';
  static const String emergencyActionTitle = 'Boton de emergencia';
  static const String emergencyActionSubtitle =
      'Disponible las 24 horas. Se pedira confirmacion antes de enviar.';
  static const String emergencyTriggerLabel = 'Activar emergencia ahora';
  static const String emergencyTypeMedical = 'Medica';
  static const String emergencyTypeGeneral = 'General';
  static const String emergencyLocationReady = 'Ubicacion lista';
  static const String emergencyLocationPending = 'Permiso de GPS requerido';
  static const String emergencyConfirmTitle = 'Activar emergencia?';
  static const String emergencyConfirmMedical =
      'Se enviara una alerta medica con tu ubicacion, antecedentes de salud '
      'y se llamara al servicio de emergencias.';
  static const String emergencyConfirmGeneral =
      'Se enviara una alerta general con tu ubicacion y se llamara al '
      'servicio de emergencias.';
  static const String emergencyConfirmAction = 'Confirmar alerta';
  static const String emergencyTrackingTitle = 'Emergencia en curso';
  static const String emergencyFailedTitle = 'Emergencia con error';
  static const String emergencyReset = 'Cerrar seguimiento';
  static const String emergencyPhaseIdle =
      'Toca el boton para iniciar el protocolo de ayuda.';
  static const String emergencyPhaseLocating = 'Obteniendo tu ubicacion...';
  static const String emergencyPhaseSending = 'Enviando alerta de emergencia...';
  static const String emergencyPhaseSendingContextual =
      'Enviando fotos y ubicacion precisa...';
  static const String emergencyPhaseTracking =
      'Procesando en segundo plano. No cierres la app.';
  static const String emergencyPhaseCompleted = 'Protocolo completado.';
  static const String emergencyPhaseFailed =
      'No se pudo completar la emergencia. Intenta de nuevo.';
  static const String emergencyStatusPending = 'Preparando emergencia';
  static const String emergencyStatusAnalyzing = 'Analizando situacion';
  static const String emergencyStatusTriage = 'Generando mensaje';
  static const String emergencyStatusAudio = 'Preparando audio';
  static const String emergencyStatusCall = 'Contactando emergencias';
  static const String emergencyStatusSms = 'Notificando contactos';
  static const String emergencyStatusCompleted = 'Llamada finalizada';
  static const String emergencyStatusFailed = 'Error en la llamada';

  // Emergencia contextual (Vision + fotos)
  static const String emergencyContextCardTitle = 'Emergencia con contexto';
  static const String emergencyContextCardSubtitle =
      'Toma 2 fotos y la IA analiza la situacion antes de llamar al 911.';
  static const String emergencyContextTitle = 'Emergencia con contexto';
  static const String emergencyContextIntro =
      'Captura tu rostro y la escena. OpenAI Vision determinara el tipo de '
      'emergencia y el backend llamara con un resumen generado.';
  static const String emergencyContextFrontTitle = 'Camara frontal';
  static const String emergencyContextFrontSubtitle =
      'Tu rostro y contexto personal para identificarte.';
  static const String emergencyContextBackTitle = 'Camara trasera';
  static const String emergencyContextBackSubtitle =
      'La escena o entorno donde ocurre la emergencia.';
  static const String emergencyContextPhotoTap = 'Tocar para capturar';
  static const String emergencyContextPhotoReady = 'Lista';
  static const String emergencyContextTextLabel = 'Descripcion opcional';
  static const String emergencyContextTextHint =
      'Ej: mi vecino se cayo de las escaleras';
  static const String emergencyContextSubmit = 'Enviar emergencia con contexto';
  static const String emergencyContextSheetTitle = 'Fotos listas';
  static const String emergencyContextSheetSubtitle =
      'Revisa las capturas, agrega contexto opcional y envia la alerta.';
  static const String emergencyContextRetake = 'Volver a tomar fotos';
  static const String emergencyContextConfirmTitle = 'Enviar emergencia?';
  static const String emergencyContextConfirmBody =
      'Se enviaran tus fotos, ubicacion precisa y descripcion. Vision '
      'analizara la situacion y se iniciara la llamada al servicio de '
      'emergencias sin interaccion en tiempo real.';
  static const String emergencyContextConfirmAction = 'Enviar ahora';
  static const String emergencyContextCameraError =
      'No pudimos abrir la camara. Verifica los permisos en Ajustes.';
}
