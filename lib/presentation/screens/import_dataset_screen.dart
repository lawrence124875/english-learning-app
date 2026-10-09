import 'dart:io';
import '../../data/sources/ads_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import '../../data/sources/csv_import_service.dart';
import '../../data/sources/tts_service.dart';
import '../../domain/models/word_item.dart';
import '../providers/app_state.dart';
import '../../l10n/app_localizations.dart';

/// 語音提示文字：可用或還沒查完時回傳 null（不顯示）；沒有語音、
/// 無法確認各自顯示不同提醒。只是提醒，不會擋匯入。
String? importVoiceNote(
    TtsLanguageStatus? status, String language, AppLocalizations l) {
  switch (status) {
    case TtsLanguageStatus.unavailable:
      return l.importVoiceMissing(language);
    case TtsLanguageStatus.unknown:
      return l.importVoiceUnknown(language);
    case TtsLanguageStatus.available:
    case null:
      return null;
  }
}

/// 匯入自訂教材畫面：讓使用者上傳自己準備的 CSV 檔（單字、片語，
/// 或常用例句都可以），選擇翻譯欄位對應的語言，加進 App 裡跟
/// 內建的四份教材一起使用。
class ImportDatasetScreen extends StatefulWidget {
  const ImportDatasetScreen({super.key});

  @override
  State<ImportDatasetScreen> createState() => _ImportDatasetScreenState();
}

class _ImportDatasetScreenState extends State<ImportDatasetScreen> {
  final _nameController = TextEditingController();
  String _translationLocale = 'zh-TW';
  String _wordLocale = 'en-US';

  /// 第一欄（要學的文字）語言選項，值為 TTS 語言代碼。名稱用各語言
  /// 自己的寫法（endonym），不需要翻譯，任何介面語言的使用者都認得。
  static const _wordLocaleOptions = <String, String>{
    'en-US': 'English',
    'zh-TW': '中文（繁體）',
    'zh-CN': '中文（简体）',
    'ja-JP': '日本語',
    'ko-KR': '한국어',
    'vi-VN': 'Tiếng Việt',
    'id-ID': 'Bahasa Indonesia',
    'es-ES': 'Español',
    'pt-BR': 'Português',
    'fr-FR': 'Français',
    'de-DE': 'Deutsch',
    'it-IT': 'Italiano',
    'th-TH': 'ไทย',
    'ar-SA': 'العربية',
  };
  bool _translationLocaleInitialized = false;
  bool _importing = false;

  /// v20：選語言當下就查手機有沒有該語言的朗讀語音（key 為語言代碼）。
  /// 還沒查完的語言不在 map 裡，畫面先不顯示提示。
  final Map<String, TtsLanguageStatus> _voiceStatus = {};

  Future<void> _checkVoice(String code) async {
    if (_voiceStatus.containsKey(code)) return;
    final status = await context.read<AppState>().checkTtsLanguage(code);
    if (!mounted) return;
    setState(() => _voiceStatus[code] = status);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 翻譯語言預設跟著 App 介面語言走（日文介面預設「日文」…），
    // 使用者仍可手動改選。只在第一次進入畫面時設定一次。
    if (!_translationLocaleInitialized) {
      final locale = Localizations.localeOf(context);
      final lang = locale.languageCode;
      _translationLocale = lang == 'zh'
          ? (locale.scriptCode == 'Hans' ? 'zh-CN' : 'zh-TW')
          : const {'ja': 'ja', 'ko': 'ko', 'vi': 'vi', 'id': 'id', 'es': 'es', 'pt': 'pt-BR', 'th': 'th', 'ar': 'ar', 'en': 'en'}[lang] ?? 'en';
      // 英文介面（含不支援語言）時，若手機語言是法/德/義，翻譯欄
      // 預設就用手機語言（他們的母語），不是英文。
      if (lang == 'en') {
        final device =
            WidgetsBinding.instance.platformDispatcher.locale.languageCode;
        if (_translationLocaleOptions.containsKey(device)) {
          _translationLocale = device;
        }
      }
      _translationLocaleInitialized = true;
      _checkVoice(_wordLocale);
      _checkVoice(_translationLocale);
    }
  }

  /// 翻譯欄（第二欄）語言選項，值為存進教材的翻譯語言代碼，也是朗讀
  /// 翻譯用的 TTS 語言。第 10 版起擴充為與第一欄相同的 13 種，名稱一樣
  /// 用 endonym（原本 8 種用介面語言翻譯的 importLangXx 字串，已不使用）。
  static const _translationLocaleOptions = <String, String>{
    'zh-TW': '中文（繁體）',
    'zh-CN': '中文（简体）',
    'ja': '日本語',
    'ko': '한국어',
    'vi': 'Tiếng Việt',
    'id': 'Bahasa Indonesia',
    'es': 'Español',
    'pt-BR': 'Português',
    'en': 'English',
    'fr': 'Français',
    'de': 'Deutsch',
    'it': 'Italiano',
    'th': 'ไทย',
    'ar': 'العربية',
  };
  String _errorMessage(CsvImportError e, AppLocalizations l) {
    switch (e) {
      case CsvImportError.encoding:
        return l.importErrorEncoding;
      case CsvImportError.parseFailed:
        return l.importErrorParse;
      case CsvImportError.empty:
        return l.importErrorEmpty;
      case CsvImportError.noValidRows:
        return l.importErrorNoRows;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _shareTemplate() async {
    final l = AppLocalizations.of(context)!;
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/import_template.csv');
    await file.writeAsString(CsvImportService.templateCsv(
      apple: l.importSampleApple,
      giveUp: l.importSampleGiveUp,
      howAreYou: l.importSampleHowAreYou,
    ));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l.importTemplateSaved(file.path))),
    );
  }

  Future<void> _pickAndImport() async {
    final l = AppLocalizations.of(context)!;
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l.importNameRequired)));
      return;
    }

    // 選檔案會暫時離開 App，回來時不要跳開啟應用程式廣告。
    AdsService.skipNextAppOpenAd();
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );
    if (result == null || result.files.single.path == null) return;

    setState(() => _importing = true);
    try {
      final file = File(result.files.single.path!);
      String content;
      try {
        content = await file.readAsString();
      } on FormatException {
        throw CsvImportException(CsvImportError.encoding);
      }
      final parsed = CsvImportService.parse(content, _translationLocale);

      final dataset = WordDataset(
        id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        shortName: name.length > 6 ? name.substring(0, 6) : name,
        items: parsed.items,
        primaryLocale: _translationLocale,
        wordLocale: _wordLocale,
      );

      if (!mounted) return;
      final appState = context.read<AppState>();
      await appState.addCustomDataset(dataset);
      // 第一欄或翻譯欄的語言在手機上沒有朗讀語音時，提醒使用者去安裝
      // （例如英文介面的人匯入泰文或德文教材，手機沒有該語音就會念不出來）。
      // v20：查詢失敗（無法確認）不當成「有語音」，另外提醒。
      final missing = <String>[];
      final unknown = <String>[];
      for (final (code, name) in [
        (_wordLocale, _wordLocaleOptions[_wordLocale] ?? _wordLocale),
        (_translationLocale,
            _translationLocaleOptions[_translationLocale] ?? _translationLocale),
      ]) {
        switch (await appState.checkTtsLanguage(code)) {
          case TtsLanguageStatus.unavailable:
            missing.add(name);
          case TtsLanguageStatus.unknown:
            unknown.add(name);
          case TtsLanguageStatus.available:
            break;
        }
      }
      if (!mounted) return;
      final done = parsed.skippedRows > 0
          ? l.importDoneWithSkipped(parsed.items.length, parsed.skippedRows)
          : l.importDone(parsed.items.length);
      final notes = [
        if (missing.isNotEmpty) l.importVoiceMissing(missing.join(' / ')),
        if (unknown.isNotEmpty) l.importVoiceUnknown(unknown.join(' / ')),
      ];
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(seconds: notes.isEmpty ? 4 : 10),
          content: Text([done, ...notes].join('\n')),
        ),
      );
      Navigator.pop(context);
    } on CsvImportException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(
              content: Text(
                  l.importFailedWithReason(_errorMessage(e.error, l)))));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l.importFailedGeneric)));
    } finally {
      if (mounted) setState(() => _importing = false);
    }
  }

  Future<void> _confirmDelete(BuildContext context, String id, String name) async {
    final l = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.importDeleteTitle),
        content: Text(l.importDeleteConfirm(name)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false), child: Text(l.commonCancel)),
          TextButton(
              onPressed: () => Navigator.pop(context, true), child: Text(l.commonDelete)),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<AppState>().removeCustomDataset(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final l = AppLocalizations.of(context)!;
    final customDatasets =
        appState.datasets.where((d) => d.id.startsWith('custom_')).toList();

    return Scaffold(
      appBar: AppBar(title: Text(l.menuImport)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            l.importIntro,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.importFormatTitle,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    '${CsvImportService.templateHeader.join(',')}\n'
                    'apple,${l.importSampleApple}\n'
                    'give up,${l.importSampleGiveUp}\n'
                    'How are you doing today?,${l.importSampleHowAreYou}',
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l.importFormatHint,
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _shareTemplate,
                    icon: const Icon(Icons.download, size: 18),
                    label: Text(l.importGetTemplate),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: l.importNameLabel,
              hintText: l.importNameHint,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _wordLocale,
            decoration: InputDecoration(
              labelText: l.importWordLangLabel,
              border: const OutlineInputBorder(),
              helperText: importVoiceNote(_voiceStatus[_wordLocale],
                  _wordLocaleOptions[_wordLocale] ?? _wordLocale, l),
              helperMaxLines: 4,
            ),
            items: _wordLocaleOptions.entries
                .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                .toList(),
            onChanged: (v) {
              if (v == null) return;
              setState(() => _wordLocale = v);
              _checkVoice(v);
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _translationLocale,
            decoration: InputDecoration(
              labelText: l.importTranslationLangLabel,
              border: const OutlineInputBorder(),
              helperText: importVoiceNote(
                  _voiceStatus[_translationLocale],
                  _translationLocaleOptions[_translationLocale] ??
                      _translationLocale,
                  l),
              helperMaxLines: 4,
            ),
            items: _translationLocaleOptions.entries
                .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                .toList(),
            onChanged: (v) {
              if (v == null) return;
              setState(() => _translationLocale = v);
              _checkVoice(v);
            },
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: _importing ? null : _pickAndImport,
            icon: _importing
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.upload_file),
            label: Text(_importing ? l.importingInProgress : l.importButton),
          ),
          if (customDatasets.isNotEmpty) ...[
            const SizedBox(height: 32),
            Text(l.importedListHeader, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            for (final d in customDatasets)
              Card(
                child: ListTile(
                  title: Text(d.name),
                  subtitle: Text(l.importItemCount(d.items.length)),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _confirmDelete(context, d.id, d.name),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
