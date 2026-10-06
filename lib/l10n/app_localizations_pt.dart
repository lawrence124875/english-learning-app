// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Aprender Inglês Ouvindo';

  @override
  String get statsTooltip => 'Estatísticas';

  @override
  String get moreTooltip => 'Mais';

  @override
  String get menuPremium => 'Assinar Premium';

  @override
  String get menuVoicePreview => 'Prévia das vozes';

  @override
  String get menuImport => 'Importar material próprio';

  @override
  String get menuAbout => 'Sobre / Créditos';

  @override
  String wordNumberLabel(int current, int total) {
    return 'N.º $current / $total';
  }

  @override
  String cycleLabel(int n) {
    return 'Rodada $n';
  }

  @override
  String roundProgressLabel(int heard, int total, int percent) {
    return 'Progresso desta rodada: $heard / $total ($percent%)';
  }

  @override
  String get playButtonStart => 'Começar a ouvir';

  @override
  String get playButtonPause => 'Pausar';

  @override
  String get starButton => 'Adicionar às palavras difíceis';

  @override
  String get navPrevious => 'Anterior';

  @override
  String get navReplay => 'Repetir';

  @override
  String get navNext => 'Próxima';

  @override
  String get statsTitle => 'Estatísticas de estudo';

  @override
  String get todayLearnedLabel => 'Estudadas hoje';

  @override
  String get totalLearnedLabel => 'Total estudado';

  @override
  String get unitCount => 'palavras';

  @override
  String get datasetProgressHeader => 'Progresso por material';

  @override
  String itemsCountLabel(int learned, int total) {
    return '$learned / $total itens';
  }

  @override
  String get dailyReminderHeader => 'Lembrete diário';

  @override
  String get enableDailyReminder => 'Ativar lembrete diário';

  @override
  String get reminderTimeLabel => 'Horário do lembrete';

  @override
  String reminderScheduledMessage(String time) {
    return 'Lembrete agendado para $time';
  }

  @override
  String get reminderFailedMessage =>
      'Não foi possível agendar. Verifique a otimização de bateria ou reative o lembrete';

  @override
  String get batteryOptButtonLabel =>
      'O lembrete não chega na hora? Toque para remover a otimização de bateria';

  @override
  String get batteryOptSnackbar =>
      'Verifique se a economia de bateria está como \"Sem restrições\"';

  @override
  String get miuiAutostartButtonLabel =>
      'Celulares Xiaomi/Redmi: ative também a \"Inicialização automática\"';

  @override
  String get miuiAutostartSnackbar =>
      'No Xiaomi, encontre este app na lista e ative a inicialização automática (em outras marcas, ignore este botão)';

  @override
  String get settingsTitle => 'Configurações de reprodução';

  @override
  String starredCountLabel(int n) {
    return '$n itens marcados';
  }

  @override
  String get speakOnManualNavigateLabel =>
      'Pronunciar ao trocar de palavra manualmente';

  @override
  String get showTranslationLabel => 'Mostrar tradução';

  @override
  String intervalSecondsLabel(String seconds) {
    return 'Pausa entre palavras: $seconds s';
  }

  @override
  String speechRateLabel(String rate) {
    return 'Velocidade de leitura: ${rate}x';
  }

  @override
  String get scopeModeLabel => 'Alcance / modo de reprodução';

  @override
  String get scopeAllRandom => 'Lista completa (aleatório)';

  @override
  String get scopeAllSequential => 'Lista completa (em ordem)';

  @override
  String get scopeStarredRandom => 'Só difíceis (aleatório)';

  @override
  String get scopeStarredSequential => 'Só difíceis (em ordem)';

  @override
  String get readModeLabel => 'Modo de leitura';

  @override
  String get readModeBilingual => 'Bilíngue (inglês + tradução)';

  @override
  String get readModeEnglishOnly => 'Só inglês';

  @override
  String get repeatCountLabel => 'Repetições em inglês';

  @override
  String get repeatOnce => 'Ler 1 vez';

  @override
  String get repeatTwice => 'Ler 2 vezes (recomendado)';

  @override
  String get repeatThrice => 'Ler 3 vezes';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonDelete => 'Excluir';

  @override
  String get voicePreviewIntro =>
      'Aqui estão as vozes em inglês disponíveis no seu celular. Toque no ícone de reproduzir para ouvi-las. Na leitura, o app usa sempre a voz padrão do sistema (escolhida conforme o idioma); esta tela serve só para testar as vozes disponíveis.';

  @override
  String get voicePreviewNoVoices =>
      'Nenhuma voz encontrada. Verifique se o celular tem um pacote de voz em inglês instalado.';

  @override
  String get voicePreviewUnknownVoice => 'Voz desconhecida';

  @override
  String get paywallPurchaseSuccess =>
      'Assinatura ativada! Todo o conteúdo foi liberado e sem anúncios.';

  @override
  String get paywallPurchaseFailed =>
      'A compra não foi concluída. Tente novamente mais tarde.';

  @override
  String get paywallRestoreSuccess => 'Assinatura Premium restaurada!';

  @override
  String get paywallRestoreNotFound =>
      'Nenhuma compra encontrada para restaurar.';

  @override
  String get paywallAlreadyPremium => 'Você já é assinante Premium 🎉';

  @override
  String get paywallHeadline => 'Libere todo o conteúdo';

  @override
  String get paywallBenefitAllContent => 'Os 4 materiais 100% liberados';

  @override
  String get paywallBenefitNoAds => 'Sem anúncios';

  @override
  String get paywallBenefitBackground =>
      'Reprodução em segundo plano e na tela de bloqueio';

  @override
  String get paywallRestoreButton => 'Restaurar compras';

  @override
  String get paywallNoPackages =>
      'Nenhum plano disponível no momento. Tente mais tarde.';

  @override
  String get paywallPlanMonthly => 'Plano mensal';

  @override
  String get paywallPlanAnnual => 'Plano anual';

  @override
  String get paywallTermsNote =>
      'A assinatura é renovada automaticamente. Você pode cancelar quando quiser em \"Pagamentos e assinaturas\" no Google Play. Após cancelar, o Premium continua até o fim do período atual e depois volta para a versão gratuita.';

  @override
  String get paywallManageSubscription => 'Gerenciar / cancelar assinatura';

  @override
  String get unlockRewardSnackbar => 'Mais 20 itens liberados!';

  @override
  String unlockFreeProgress(int unlocked, int total) {
    return 'Versão gratuita: $unlocked / $total itens liberados';
  }

  @override
  String get unlockAdLoading => 'Carregando anúncio…';

  @override
  String get unlockWatchAd => 'Ver anúncio +20';

  @override
  String get importIntro =>
      'Você pode importar suas próprias palavras, expressões ou frases (por exemplo, do seu livro). Depois, elas tocam como os materiais incluídos.';

  @override
  String get importFormatTitle => 'Formato de importação (CSV com cabeçalho)';

  @override
  String get importSampleApple => 'maçã';

  @override
  String get importSampleGiveUp => 'desistir';

  @override
  String get importSampleHowAreYou => 'Como foi o seu dia?';

  @override
  String get importFormatHint =>
      'A primeira coluna é o inglês (palavra, expressão ou frase completa) e a segunda, a tradução. Salve como CSV e importe. Também é possível importar outros idiomas além do inglês: basta escolher abaixo o idioma da primeira coluna.';

  @override
  String get importGetTemplate => 'Baixar modelo';

  @override
  String importTemplateSaved(String path) {
    return 'Modelo salvo na pasta temporária: $path';
  }

  @override
  String get importNameLabel => 'Nome do material';

  @override
  String get importNameHint => 'Ex.: Frases essenciais do TOEIC';

  @override
  String get importNameRequired => 'Dê um nome a este material primeiro';

  @override
  String get importTranslationLangLabel =>
      'Em que idioma está a coluna de tradução?';

  @override
  String get importLangZh => 'Chinês';

  @override
  String get importLangJa => 'Japonês';

  @override
  String get importLangKo => 'Coreano';

  @override
  String get importLangVi => 'Vietnamita';

  @override
  String get importLangEn => 'Inglês';

  @override
  String get importButton => 'Escolher arquivo CSV e importar';

  @override
  String get importingInProgress => 'Importando…';

  @override
  String importDone(int count) {
    return 'Importação concluída! $count itens';
  }

  @override
  String importDoneWithSkipped(int count, int skipped) {
    return 'Importação concluída! $count itens ($skipped linhas vazias ignoradas)';
  }

  @override
  String importFailedWithReason(String reason) {
    return 'Falha na importação: $reason';
  }

  @override
  String get importFailedGeneric =>
      'Falha na importação. Verifique o formato do arquivo';

  @override
  String get importErrorEncoding =>
      'O arquivo não está em UTF-8 e não pode ser lido. No Excel, use \"Salvar como\" e escolha \"CSV UTF-8 (delimitado por vírgulas)\", ou salve em UTF-8 com um editor de texto.';

  @override
  String get importErrorParse =>
      'Não foi possível ler o CSV. Verifique se usa vírgulas como separador.';

  @override
  String get importErrorEmpty => 'O arquivo está vazio. Verifique o conteúdo.';

  @override
  String get importErrorNoRows =>
      'Nenhuma linha válida encontrada. Verifique o formato.';

  @override
  String get importDeleteTitle => 'Excluir material próprio';

  @override
  String importDeleteConfirm(String name) {
    return 'Tem certeza de que deseja excluir \"$name\"? Esta ação não pode ser desfeita.';
  }

  @override
  String get importedListHeader => 'Materiais importados';

  @override
  String importItemCount(int n) {
    return '$n itens';
  }

  @override
  String get aboutFeedbackButton => 'Enviar feedback / Relatar problema';

  @override
  String get aboutAttributionIntro =>
      'Os dados de palavras e expressões deste app vêm das seguintes pesquisas acadêmicas públicas. Agradecemos e citamos as fontes:';

  @override
  String get aboutNgslTitle => 'NGSL 2809 (vocabulário essencial)';

  @override
  String get aboutSpokenTitle =>
      'NGSL-Spoken 720 (palavras frequentes da fala)';

  @override
  String get aboutPhaveTitle => 'PhaVE List (phrasal verbs)';

  @override
  String get aboutPhraseTitle => 'PHRASE List (expressões frequentes)';

  @override
  String get aboutLicenseCcBySa =>
      'Sob a licença Creative Commons Atribuição-CompartilhaIgual 4.0 Internacional (CC BY-SA 4.0).';

  @override
  String get aboutLicenseCcBy =>
      'Sob a licença Creative Commons Atribuição 4.0 Internacional (CC BY 4.0).';

  @override
  String get aboutPhraseRights =>
      'Direitos reservados aos autores originais; este app os usa para fins educacionais dentro do permitido.';

  @override
  String aboutSourceLabel(String name) {
    return 'Obra original: $name';
  }

  @override
  String aboutLicenseLabel(String name) {
    return 'Licença: $name';
  }

  @override
  String get aboutTtsNote =>
      'As vozes vêm do mecanismo de texto para fala (TTS) do próprio aparelho.';

  @override
  String get feedbackTitle => 'Feedback';

  @override
  String get feedbackCategoryLabel => 'Tipo';

  @override
  String get feedbackCategoryBug => 'Relatar problema';

  @override
  String get feedbackCategorySuggestion => 'Sugestão';

  @override
  String get feedbackCategoryOther => 'Outro';

  @override
  String get feedbackMessageLabel => 'Mensagem';

  @override
  String get feedbackMessageHint =>
      'Conte qual problema você teve ou que recurso gostaria de ter…';

  @override
  String get feedbackEmailLabel => 'E-mail para contato (opcional)';

  @override
  String get feedbackEmailHint => 'Deixe seu e-mail se quiser uma resposta';

  @override
  String get feedbackSubmit => 'Enviar';

  @override
  String get feedbackEmpty => 'Escreva sua mensagem antes de enviar';

  @override
  String get feedbackThanks =>
      'Obrigado pelo feedback! Vamos analisar em breve.';

  @override
  String get feedbackFailed =>
      'Não foi possível enviar. Verifique sua conexão e tente novamente';

  @override
  String get statsDescNgsl =>
      'Lista do vocabulário essencial do inglês baseada em estudos públicos de frequência. Dominar estas 2.809 palavras permite entender cerca de 92% dos textos cotidianos em inglês (Fonte: New General Service List Project).';

  @override
  String get statsDescSpoken =>
      '720 palavras muito frequentes na conversa do dia a dia, para reagir mais rápido ao ouvir e falar. Complementa a lista NGSL com palavras comuns na fala, mas pouco usadas na escrita.';

  @override
  String get statsDescPhrase =>
      '506 colocações e expressões fixas que os nativos realmente usam (ex.: \"in order to\", \"as well as\"). Não são palavras soltas, mas blocos aprendidos por inteiro, para falar um inglês mais natural.';

  @override
  String get statsDescPhave =>
      'Inclui os 150 phrasal verbs mais usados (ex.: \"look after\", \"give up\"). As combinações de verbo + preposição são a parte mais difícil para quem aprende; revisar estes 150 cobre a maioria dos que você encontra no dia a dia.';

  @override
  String get summaryReadBilingual => 'Bilíngue';

  @override
  String get summaryReadEnglishOnly => 'Só inglês';

  @override
  String settingsSummaryLine(String mode, int count, String rate) {
    return '$mode · $count vezes · ${rate}x';
  }

  @override
  String get notifChannelName => 'Lembretes de revisão';

  @override
  String get notifChannelDesc => 'Lembrete diário para revisar inglês';

  @override
  String get notifDailyTitle => 'Hora de revisar inglês!';

  @override
  String get notifDailyBody =>
      'Ouça algumas palavras para fixar o que aprendeu hoje';

  @override
  String get notifInactivityTitle => 'Quanto tempo! 👋';

  @override
  String get notifInactivityBody =>
      'Faz alguns dias que você não revisa. Ouça algumas palavras para não esquecer';

  @override
  String get audioChannelName => 'Leitura para aprender inglês';

  @override
  String get importLangId => 'Indonésio';

  @override
  String get datasetNameNgsl => 'NGSL 2809 vocabulário essencial';

  @override
  String get datasetShortNgsl => 'NGSL 2809';

  @override
  String get datasetNameSpoken => 'NGSL 720 palavras da fala';

  @override
  String get datasetShortSpoken => 'Fala 720';

  @override
  String get datasetNamePhrase => 'PHRASE List expressões (506)';

  @override
  String get datasetShortPhrase => 'Expressões 506';

  @override
  String get datasetNamePhave => 'PhaVE List phrasal verbs (150)';

  @override
  String get datasetShortPhave => 'Phrasal 150';

  @override
  String get updateDownloadedMessage => 'Nova versão baixada';

  @override
  String get updateRestartButton => 'Reiniciar';

  @override
  String get importLangEs => 'Espanhol';

  @override
  String get importLangPt => 'Português';

  @override
  String get menuIntro => 'Recursos do app';

  @override
  String get introSkip => 'Pular';

  @override
  String get introNext => 'Próximo';

  @override
  String get introStart => 'Começar a aprender';

  @override
  String get introTitle1 => 'Aprenda inglês com a regra 20/80';

  @override
  String get introBody1 =>
      'Com as 2.809 palavras essenciais da NGSL você entende cerca de 92% do inglês do dia a dia. Nada de palavras raras: seu tempo vai para o que você realmente vai usar.';

  @override
  String get introTitle2 => 'Feito para você';

  @override
  String get introBody2 =>
      'Já começou o inglês várias vezes e sempre desistiu no meio, sente que a memória não é mais a mesma ou não tem inglês à sua volta? Este método foi pensado para você recuperar a confiança para aprender inglês.';

  @override
  String get introTitle3 => 'Ouça em segundo plano e aproveite o tempo livre';

  @override
  String get introBody3 =>
      'Ouça no trajeto, na caminhada, fazendo tarefas de casa ou exercícios. Mesmo com a tela bloqueada ou em outro app, a leitura continua, sem precisar olhar a tela.';

  @override
  String get introTitle4 => 'Leitura bilíngue + lista de palavras difíceis';

  @override
  String get introBody4 =>
      'Primeiro vem o inglês e depois o significado em português, para você entender sem olhar a tela. Marque com estrela as palavras que ainda não sabe e use o modo \"Só difíceis\" para repeti-las até memorizar.';

  @override
  String get introTitle5 => 'Importe seu material: 14 idiomas';

  @override
  String get introBody5 =>
      'Vocabulário do livro, expressões do trabalho, conteúdo de provas: importe como arquivo CSV, ouça em segundo plano e marque as difíceis. Não só inglês: espanhol, francês, alemão, italiano, japonês, coreano, chinês, árabe e mais, 14 idiomas no total, com a tradução no idioma que preferir. (Alguns idiomas exigem baixar a voz no celular primeiro)';

  @override
  String get introTitle6 => '4 listas acadêmicas, comece grátis';

  @override
  String get introBody6 =>
      'Palavras essenciais NGSL 2809, palavras do inglês falado 720, expressões frequentes 506 e phrasal verbs 150, todas de pesquisas acadêmicas públicas. Cada lista tem conteúdo grátis para você experimentar antes.';

  @override
  String get importWordLangLabel =>
      'Qual é o idioma da primeira coluna? (para a voz de leitura)';

  @override
  String importVoiceMissing(String language) {
    return 'Seu celular não tem voz de leitura para \"$language\", então não será lido em voz alta. Instale-a em \"Configurações → Conversão de texto em voz\".';
  }

  @override
  String get menuShare => 'Compartilhar com amigos';

  @override
  String get shareMessage =>
      'Recomendo o \"Aprender Inglês Ouvindo\": aprenda com a regra 20/80 só as palavras essenciais que cobrem 92% do inglês do dia a dia, ouvindo em segundo plano enquanto se desloca, caminha ou faz tarefas, em inglês e em português. Baixe grátis:';

  @override
  String get menuAdPrivacy => 'Privacidade de anúncios';

  @override
  String get switchDatasetButton => 'Trocar material';

  @override
  String get unlockMoreButton => 'Desbloquear mais';

  @override
  String get playShortStart => 'Ouvir';

  @override
  String get playShortPause => 'Pausar';

  @override
  String cycleShort(int n) {
    return 'Rodada $n';
  }

  @override
  String get wordSizeLabel => 'Tamanho da palavra';

  @override
  String get wordSizeSmall => 'Pequeno';

  @override
  String get wordSizeMedium => 'Médio';

  @override
  String get wordSizeLarge => 'Grande';

  @override
  String get lockScreenCoverLabel =>
      'Capa com letra grande na tela de bloqueio';

  @override
  String get lockScreenCoverDesc =>
      'Se desativar, a tela de bloqueio mostra só o cartão normal com letra pequena';

  @override
  String get appearanceLabel => 'Aparência';

  @override
  String get appearanceSystem => 'Seguir o sistema';

  @override
  String get appearanceLight => 'Claro';

  @override
  String get appearanceDark => 'Escuro';

  @override
  String notifLastHeard(String word) {
    return 'Última palavra: $word';
  }

  @override
  String notifStarredLeft(int count) {
    return 'Ainda faltam $count palavras difíceis';
  }

  @override
  String get notifActionStart => '▶ Ouvir';

  @override
  String get notifActionSnooze => 'Lembrar mais tarde';
}
