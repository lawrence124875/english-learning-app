// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Aprender Inglés Escuchando';

  @override
  String get statsTooltip => 'Estadísticas';

  @override
  String get moreTooltip => 'Más';

  @override
  String get menuPremium => 'Mejorar a Premium';

  @override
  String get menuVoicePreview => 'Vista previa de voces';

  @override
  String get menuImport => 'Importar material propio';

  @override
  String get menuAbout => 'Acerca de / Créditos';

  @override
  String wordNumberLabel(int current, int total) {
    return 'N.º $current / $total';
  }

  @override
  String cycleLabel(int n) {
    return 'Ronda $n';
  }

  @override
  String roundProgressLabel(int heard, int total, int percent) {
    return 'Progreso de esta ronda: $heard / $total ($percent%)';
  }

  @override
  String get playButtonStart => 'Empezar a escuchar';

  @override
  String get playButtonPause => 'Pausar';

  @override
  String get starButton => 'Añadir a palabras difíciles';

  @override
  String get navPrevious => 'Anterior';

  @override
  String get navReplay => 'Repetir';

  @override
  String get navNext => 'Siguiente';

  @override
  String get statsTitle => 'Estadísticas de estudio';

  @override
  String get todayLearnedLabel => 'Estudiadas hoy';

  @override
  String get totalLearnedLabel => 'Total estudiadas';

  @override
  String get unitCount => 'palabras';

  @override
  String get datasetProgressHeader => 'Progreso por material';

  @override
  String itemsCountLabel(int learned, int total) {
    return '$learned / $total elementos';
  }

  @override
  String get dailyReminderHeader => 'Recordatorio diario';

  @override
  String get enableDailyReminder => 'Activar recordatorio diario';

  @override
  String get reminderTimeLabel => 'Hora del recordatorio';

  @override
  String reminderScheduledMessage(String time) {
    return 'Recordatorio programado a las $time';
  }

  @override
  String get reminderFailedMessage =>
      'No se pudo programar. Revisa la optimización de batería o vuelve a activar el recordatorio';

  @override
  String get batteryOptButtonLabel =>
      '¿El recordatorio no llega a tiempo? Toca para quitar la optimización de batería';

  @override
  String get batteryOptSnackbar =>
      'Asegúrate de que el ahorro de batería esté en \"Sin restricciones\"';

  @override
  String get miuiAutostartButtonLabel =>
      'Móviles Xiaomi/Redmi: activa también el \"Inicio automático\"';

  @override
  String get miuiAutostartSnackbar =>
      'En Xiaomi, busca esta app en la lista y activa el inicio automático (en otras marcas puedes ignorar este botón)';

  @override
  String get settingsTitle => 'Ajustes de reproducción';

  @override
  String starredCountLabel(int n) {
    return '$n elementos marcados';
  }

  @override
  String get speakOnManualNavigateLabel =>
      'Pronunciar al cambiar de palabra manualmente';

  @override
  String get showTranslationLabel => 'Mostrar traducción';

  @override
  String intervalSecondsLabel(String seconds) {
    return 'Pausa entre palabras: $seconds s';
  }

  @override
  String speechRateLabel(String rate) {
    return 'Velocidad de lectura: ${rate}x';
  }

  @override
  String get scopeModeLabel => 'Alcance / modo de reproducción';

  @override
  String get scopeAllRandom => 'Toda la lista (aleatorio)';

  @override
  String get scopeAllSequential => 'Toda la lista (en orden)';

  @override
  String get scopeStarredRandom => 'Solo difíciles (aleatorio)';

  @override
  String get scopeStarredSequential => 'Solo difíciles (en orden)';

  @override
  String get readModeLabel => 'Modo de lectura';

  @override
  String get readModeBilingual => 'Bilingüe (inglés + traducción)';

  @override
  String get readModeEnglishOnly => 'Solo inglés';

  @override
  String get repeatCountLabel => 'Repeticiones en inglés';

  @override
  String get repeatOnce => 'Leer 1 vez';

  @override
  String get repeatTwice => 'Leer 2 veces (recomendado)';

  @override
  String get repeatThrice => 'Leer 3 veces';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonDelete => 'Eliminar';

  @override
  String get voicePreviewIntro =>
      'Aquí están las voces en inglés disponibles en tu móvil. Toca el icono de reproducir para escucharlas. Al leer, la app usa siempre la voz predeterminada del sistema (elegida según el idioma); esta pantalla solo sirve para probar las voces que tienes.';

  @override
  String get voicePreviewNoVoices =>
      'No se encontraron voces. Comprueba que tu móvil tenga instalado un paquete de voz en inglés.';

  @override
  String get voicePreviewUnknownVoice => 'Voz desconocida';

  @override
  String get paywallPurchaseSuccess =>
      '¡Suscripción activada! Todo el contenido está desbloqueado y sin anuncios.';

  @override
  String get paywallPurchaseFailed =>
      'La compra no se completó. Inténtalo de nuevo más tarde.';

  @override
  String get paywallRestoreSuccess => '¡Suscripción Premium restaurada!';

  @override
  String get paywallRestoreNotFound =>
      'No se encontraron compras para restaurar.';

  @override
  String get paywallAlreadyPremium => 'Ya eres suscriptor Premium 🎉';

  @override
  String get paywallHeadline => 'Desbloquea todo el contenido';

  @override
  String get paywallBenefitAllContent => 'Los 4 materiales 100 % disponibles';

  @override
  String get paywallBenefitNoAds => 'Sin anuncios';

  @override
  String get paywallBenefitBackground =>
      'Reproducción en segundo plano y en pantalla bloqueada';

  @override
  String get paywallRestoreButton => 'Restaurar compras';

  @override
  String get paywallNoPackages =>
      'No hay planes disponibles por ahora. Inténtalo más tarde.';

  @override
  String get paywallPlanMonthly => 'Plan mensual';

  @override
  String get paywallPlanAnnual => 'Plan anual';

  @override
  String get paywallTermsNote =>
      'La suscripción se renueva automáticamente. Puedes cancelarla cuando quieras en \"Pagos y suscripciones\" de Google Play. Tras cancelar, conservas Premium hasta el final del periodo actual y luego vuelves a la versión gratuita.';

  @override
  String get paywallManageSubscription => 'Gestionar / cancelar suscripción';

  @override
  String get unlockRewardSnackbar => '¡Se desbloquearon 20 elementos más!';

  @override
  String unlockFreeProgress(int unlocked, int total) {
    return 'Versión gratuita: $unlocked / $total elementos desbloqueados';
  }

  @override
  String get unlockAdLoading => 'Cargando anuncio…';

  @override
  String get unlockWatchAd => 'Ver anuncio +20';

  @override
  String get importIntro =>
      'Puedes importar tus propias palabras, frases o ejemplos (por ejemplo, de tu libro). Después se escuchan igual que los materiales incluidos.';

  @override
  String get importFormatTitle => 'Formato de importación (CSV con encabezado)';

  @override
  String get importSampleApple => 'manzana';

  @override
  String get importSampleGiveUp => 'rendirse';

  @override
  String get importSampleHowAreYou => '¿Qué tal tu día?';

  @override
  String get importFormatHint =>
      'La primera columna es el inglés (palabra, frase o una oración completa) y la segunda su traducción. Guárdalo como CSV e impórtalo. También puedes importar otros idiomas además del inglés: solo elige abajo el idioma de la primera columna.';

  @override
  String get importGetTemplate => 'Obtener plantilla';

  @override
  String importTemplateSaved(String path) {
    return 'Plantilla guardada en la carpeta temporal: $path';
  }

  @override
  String get importNameLabel => 'Nombre del material';

  @override
  String get importNameHint => 'Ej.: Frases clave de TOEIC';

  @override
  String get importNameRequired => 'Ponle un nombre a este material primero';

  @override
  String get importTranslationLangLabel =>
      '¿En qué idioma está la columna de traducción?';

  @override
  String get importLangZh => 'Chino';

  @override
  String get importLangJa => 'Japonés';

  @override
  String get importLangKo => 'Coreano';

  @override
  String get importLangVi => 'Vietnamita';

  @override
  String get importLangEn => 'Inglés';

  @override
  String get importButton => 'Elegir archivo CSV e importar';

  @override
  String get importingInProgress => 'Importando…';

  @override
  String importDone(int count) {
    return '¡Importación completa! $count elementos';
  }

  @override
  String importDoneWithSkipped(int count, int skipped) {
    return '¡Importación completa! $count elementos ($skipped filas vacías omitidas)';
  }

  @override
  String importFailedWithReason(String reason) {
    return 'Error al importar: $reason';
  }

  @override
  String get importFailedGeneric =>
      'Error al importar. Revisa el formato del archivo';

  @override
  String get importErrorEncoding =>
      'El archivo no está en UTF-8 y no se puede leer. En Excel, usa \"Guardar como\" y elige \"CSV UTF-8 (delimitado por comas)\", o guárdalo en UTF-8 con un editor de texto.';

  @override
  String get importErrorParse =>
      'No se pudo leer el CSV. Comprueba que use comas como separador.';

  @override
  String get importErrorEmpty => 'El archivo está vacío. Revisa su contenido.';

  @override
  String get importErrorNoRows =>
      'No se encontraron filas válidas. Revisa el formato.';

  @override
  String get importDeleteTitle => 'Eliminar material propio';

  @override
  String importDeleteConfirm(String name) {
    return '¿Seguro que quieres eliminar \"$name\"? Esta acción no se puede deshacer.';
  }

  @override
  String get importedListHeader => 'Materiales importados';

  @override
  String importItemCount(int n) {
    return '$n elementos';
  }

  @override
  String get aboutFeedbackButton => 'Enviar comentarios / Informar un problema';

  @override
  String get aboutAttributionIntro =>
      'Los datos de palabras y frases de esta app provienen de las siguientes investigaciones académicas públicas. Agradecemos y citamos sus fuentes:';

  @override
  String get aboutNgslTitle => 'NGSL 2809 (vocabulario básico)';

  @override
  String get aboutSpokenTitle =>
      'NGSL-Spoken 720 (palabras frecuentes del habla)';

  @override
  String get aboutPhaveTitle => 'PhaVE List (verbos frasales)';

  @override
  String get aboutPhraseTitle => 'PHRASE List (expresiones frecuentes)';

  @override
  String get aboutLicenseCcBySa =>
      'Bajo licencia Creative Commons Atribución-CompartirIgual 4.0 Internacional (CC BY-SA 4.0).';

  @override
  String get aboutLicenseCcBy =>
      'Bajo licencia Creative Commons Atribución 4.0 Internacional (CC BY 4.0).';

  @override
  String get aboutPhraseRights =>
      'Derechos reservados a los autores originales; esta app los usa con fines educativos dentro de lo permitido.';

  @override
  String aboutSourceLabel(String name) {
    return 'Obra original: $name';
  }

  @override
  String aboutLicenseLabel(String name) {
    return 'Licencia: $name';
  }

  @override
  String get aboutTtsNote =>
      'Las voces provienen del motor de texto a voz (TTS) integrado en el dispositivo.';

  @override
  String get feedbackTitle => 'Comentarios';

  @override
  String get feedbackCategoryLabel => 'Tipo';

  @override
  String get feedbackCategoryBug => 'Informar un problema';

  @override
  String get feedbackCategorySuggestion => 'Sugerencia';

  @override
  String get feedbackCategoryOther => 'Otro';

  @override
  String get feedbackMessageLabel => 'Mensaje';

  @override
  String get feedbackMessageHint =>
      'Cuéntanos qué problema tuviste o qué función te gustaría…';

  @override
  String get feedbackEmailLabel => 'Correo de contacto (opcional)';

  @override
  String get feedbackEmailHint => 'Déjanos tu correo si quieres respuesta';

  @override
  String get feedbackSubmit => 'Enviar';

  @override
  String get feedbackEmpty => 'Escribe tu mensaje antes de enviar';

  @override
  String get feedbackThanks =>
      '¡Gracias por tus comentarios! Los revisaremos pronto.';

  @override
  String get feedbackFailed =>
      'No se pudo enviar. Revisa tu conexión e inténtalo de nuevo';

  @override
  String get statsDescNgsl =>
      'Lista del vocabulario básico del inglés basada en estudios públicos de frecuencia. Dominar estas 2.809 palabras permite entender cerca del 92 % de los textos cotidianos en inglés (Fuente: New General Service List Project).';

  @override
  String get statsDescSpoken =>
      '720 palabras muy frecuentes en la conversación diaria, para reaccionar más rápido al escuchar y hablar. Complementa la lista NGSL con palabras comunes al hablar pero poco usadas por escrito.';

  @override
  String get statsDescPhrase =>
      '506 colocaciones y expresiones fijas que los nativos realmente usan (p. ej., \"in order to\", \"as well as\"). No son palabras sueltas sino bloques que se aprenden enteros, para hablar un inglés más natural.';

  @override
  String get statsDescPhave =>
      'Incluye los 150 verbos frasales más usados (p. ej., \"look after\", \"give up\"). Las combinaciones de verbo + preposición son lo más difícil para quien aprende; repasar estos 150 cubre la mayoría de los que encontrarás a diario.';

  @override
  String get summaryReadBilingual => 'Bilingüe';

  @override
  String get summaryReadEnglishOnly => 'Solo inglés';

  @override
  String settingsSummaryLine(String mode, int count, String rate) {
    return '$mode · $count veces · ${rate}x';
  }

  @override
  String get notifChannelName => 'Recordatorios de repaso';

  @override
  String get notifChannelDesc => 'Recordatorio diario para repasar inglés';

  @override
  String get notifDailyTitle => '¡Hora de repasar inglés!';

  @override
  String get notifDailyBody =>
      'Escucha unas palabras para reforzar lo que aprendiste hoy';

  @override
  String get notifInactivityTitle => '¡Cuánto tiempo! 👋';

  @override
  String get notifInactivityBody =>
      'Llevas varios días sin repasar. Escucha unas palabras para no olvidarlas';

  @override
  String get audioChannelName => 'Lectura para aprender inglés';

  @override
  String get importLangId => 'Indonesio';

  @override
  String get datasetNameNgsl => 'NGSL 2809 vocabulario básico';

  @override
  String get datasetShortNgsl => 'NGSL 2809';

  @override
  String get datasetNameSpoken => 'NGSL 720 palabras del habla';

  @override
  String get datasetShortSpoken => 'Habla 720';

  @override
  String get datasetNamePhrase => 'PHRASE List expresiones (506)';

  @override
  String get datasetShortPhrase => 'Expresiones 506';

  @override
  String get datasetNamePhave => 'PhaVE List verbos frasales (150)';

  @override
  String get datasetShortPhave => 'Frasales 150';

  @override
  String get updateDownloadedMessage => 'Nueva versión descargada';

  @override
  String get updateRestartButton => 'Reiniciar';

  @override
  String get importLangEs => 'Español';

  @override
  String get importLangPt => 'Portugués';

  @override
  String get menuIntro => 'Funciones de la app';

  @override
  String get introSkip => 'Omitir';

  @override
  String get introNext => 'Siguiente';

  @override
  String get introStart => 'Empezar a aprender';

  @override
  String get introTitle1 => 'Aprende inglés con la regla 20/80';

  @override
  String get introBody1 =>
      'Con las 2.809 palabras básicas de la NGSL entiendes cerca del 92% del inglés cotidiano. Nada de palabras raras: tu tiempo se concentra en lo que de verdad vas a usar.';

  @override
  String get introTitle2 => 'Pensada para ti';

  @override
  String get introBody2 =>
      '¿Has empezado inglés muchas veces y siempre lo has dejado, sientes que tu memoria ya no es la de antes o no tienes inglés a tu alrededor? Este método está diseñado para ti, para que recuperes la confianza al aprender inglés.';

  @override
  String get introTitle3 =>
      'Escucha en segundo plano y aprovecha los ratos libres';

  @override
  String get introBody3 =>
      'Escucha mientras viajas, paseas, haces tareas del hogar o ejercicio. Aunque bloquees la pantalla o cambies de app, la lectura continúa, sin necesidad de mirar la pantalla.';

  @override
  String get introTitle4 => 'Lectura bilingüe + lista de palabras difíciles';

  @override
  String get introBody4 =>
      'Primero se lee el inglés y luego el significado en español, así lo entiendes sin mirar la pantalla. Marca con una estrella las palabras que aún no dominas y usa el modo \"Solo difíciles\" para repetirlas hasta memorizarlas.';

  @override
  String get introTitle5 => 'Importa tu material: 14 idiomas';

  @override
  String get introBody5 =>
      'Vocabulario del libro, expresiones del trabajo o temas de examen: impórtalos como archivo CSV, escúchalos en segundo plano y marca los difíciles. No solo inglés: francés, alemán, italiano, japonés, coreano, chino, árabe y más, 14 idiomas en total, con la traducción en el idioma que prefieras. (Algunos idiomas requieren descargar primero la voz en el teléfono)';

  @override
  String get introTitle6 => '4 listas académicas, empieza gratis';

  @override
  String get introBody6 =>
      'Palabras básicas NGSL 2809, palabras del inglés hablado 720, expresiones frecuentes 506 y phrasal verbs 150, todas de investigaciones académicas públicas. Cada lista tiene contenido gratis para que la pruebes primero.';

  @override
  String get importWordLangLabel =>
      '¿En qué idioma está la primera columna? (para la voz de lectura)';

  @override
  String importVoiceMissing(String language) {
    return 'Tu teléfono no tiene voz de lectura para \"$language\", así que no se podrá leer en voz alta. Instálala en \"Ajustes → Texto a voz\".';
  }

  @override
  String get menuShare => 'Compartir con amigos';

  @override
  String get shareMessage =>
      'Te recomiendo \"Aprender Inglés Escuchando\": aprende con la regla 20/80 solo las palabras clave que cubren el 92 % del inglés cotidiano, escuchándolas en segundo plano mientras viajas, caminas o haces tareas, en inglés y en español. Descarga gratis:';

  @override
  String get menuAdPrivacy => 'Privacidad de anuncios';

  @override
  String get switchDatasetButton => 'Cambiar material';

  @override
  String get unlockMoreButton => 'Desbloquear más';

  @override
  String get playShortStart => 'Escuchar';

  @override
  String get playShortPause => 'Pausa';

  @override
  String cycleShort(int n) {
    return 'Ronda $n';
  }

  @override
  String get wordSizeLabel => 'Tamaño de la palabra';

  @override
  String get wordSizeSmall => 'Pequeño';

  @override
  String get wordSizeMedium => 'Mediano';

  @override
  String get wordSizeLarge => 'Grande';

  @override
  String get lockScreenCoverLabel =>
      'Portada con letra grande en la pantalla de bloqueo';

  @override
  String get lockScreenCoverDesc =>
      'Si lo desactivas, la pantalla de bloqueo solo muestra la tarjeta normal con letra pequeña';

  @override
  String get appearanceLabel => 'Apariencia';

  @override
  String get appearanceSystem => 'Según el sistema';

  @override
  String get appearanceLight => 'Claro';

  @override
  String get appearanceDark => 'Oscuro';

  @override
  String notifLastHeard(String word) {
    return 'Última palabra: $word';
  }

  @override
  String notifStarredLeft(int count) {
    return 'Te quedan $count palabras difíciles';
  }

  @override
  String get notifActionStart => '▶ Escuchar';

  @override
  String get notifActionSnooze => 'Recordar más tarde';
}
