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
}
