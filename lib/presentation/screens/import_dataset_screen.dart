import 'dart:io';
import '../../data/sources/ads_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import '../../data/sources/csv_import_service.dart';
import '../../domain/models/word_item.dart';
import '../providers/app_state.dart';
import '../../l10n/app_localizations.dart';

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
  bool _translationLocaleInitialized = false;
  bool _importing = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 翻譯語言預設跟著 App 介面語言走（日文介面預設「日文」…），
    // 使用者仍可手動改選。只在第一次進入畫面時設定一次。
    if (!_translationLocaleInitialized) {
      final lang = Localizations.localeOf(context).languageCode;
      _translationLocale =
          const {'ja': 'ja', 'ko': 'ko', 'vi': 'vi', 'id': 'id', 'es': 'es', 'pt': 'pt-BR'}[lang] ?? 'zh-TW';
      _translationLocaleInitialized = true;
    }
  }

  Map<String, String> _localeOptions(AppLocalizations l) => {
        'zh-TW': l.importLangZh,
        'ja': l.importLangJa,
        'ko': l.importLangKo,
        'vi': l.importLangVi,
        'id': l.importLangId,
        'es': l.importLangEs,
        'pt-BR': l.importLangPt,
        'en': l.importLangEn,
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
      );

      if (!mounted) return;
      await context.read<AppState>().addCustomDataset(dataset);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(parsed.skippedRows > 0
              ? l.importDoneWithSkipped(
                  parsed.items.length, parsed.skippedRows)
              : l.importDone(parsed.items.length)),
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
                    'english,translation\n'
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
            initialValue: _translationLocale,
            decoration: InputDecoration(
              labelText: l.importTranslationLangLabel,
              border: const OutlineInputBorder(),
            ),
            items: _localeOptions(l).entries
                .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                .toList(),
            onChanged: (v) {
              if (v != null) setState(() => _translationLocale = v);
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
