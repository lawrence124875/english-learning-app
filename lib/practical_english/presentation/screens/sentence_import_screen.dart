import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../l10n/app_localizations.dart';
import '../../data/sentence_csv_importer.dart';
import '../providers/practical_english_state.dart';

/// 基本的句子 CSV 匯入畫面：選檔 → 呼叫 Phase 3 importer → 顯示結果。
class SentenceImportScreen extends StatefulWidget {
  /// 測試用：取代檔案選擇器，回傳 CSV 內容（null＝取消）。
  final Future<String?> Function()? pickContent;

  const SentenceImportScreen({super.key, this.pickContent});

  @override
  State<SentenceImportScreen> createState() => _SentenceImportScreenState();
}

class _SentenceImportScreenState extends State<SentenceImportScreen> {
  bool _busy = false;
  SentenceImportResult? _result;
  String? _error;

  Future<String?> _pickFromDevice() async {
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );
    final path = picked?.files.single.path;
    if (path == null) return null;
    return File(path).readAsString();
  }

  Future<void> _choose() async {
    final l10n = AppLocalizations.of(context)!;
    final state = context.read<PracticalEnglishState>();
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final content = await (widget.pickContent ?? _pickFromDevice)();
      if (content == null) return;
      final result = await state.importCsv(content);
      if (mounted) setState(() => _result = result);
    } on SentenceCsvFileException catch (e) {
      final msg = switch (e.error) {
        SentenceCsvFileError.empty => l10n.peImportFileEmpty,
        SentenceCsvFileError.parseFailed => l10n.peImportFileUnreadable,
        SentenceCsvFileError.missingRequiredColumns =>
          l10n.peImportMissingColumns(e.missingColumns.join(', ')),
      };
      if (mounted) setState(() => _error = msg);
    } on FormatException {
      if (mounted) setState(() => _error = l10n.peImportFileUnreadable);
    } on FileSystemException {
      if (mounted) setState(() => _error = l10n.peImportFileUnreadable);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final result = _result;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.peImportTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(l10n.peImportHint),
            const SizedBox(height: 12),
            FilledButton.icon(
              key: const Key('pe_import_choose'),
              onPressed: _busy ? null : _choose,
              icon: _busy
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.upload_file),
              label: Text(l10n.peImportChoose),
            ),
            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(_error!,
                  key: const Key('pe_import_error'),
                  style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ],
            if (result != null) ...[
              const SizedBox(height: 16),
              if (!result.hasChanges) Text(l10n.peImportNoChanges),
              _count(l10n.peImportAdded, result.added, 'added'),
              _count(l10n.peImportUpdated, result.updated, 'updated'),
              _count(l10n.peImportDuplicate, result.duplicate, 'duplicate'),
              _count(l10n.peImportInvalidWordId, result.invalidWordIds.length,
                  'invalidWordId'),
              for (final r in result.invalidWordIds)
                _detail('${l10n.peImportRowLabel(r.row)}: ${r.wordIds.join(', ')}'),
              _count(l10n.peImportInvalidRow, result.invalidRows.length,
                  'invalidRow'),
              for (final r in result.invalidRows)
                _detail('${l10n.peImportRowLabel(r.row)}: ${switch (r.reason) {
                  InvalidRowReason.missingWordId => l10n.peImportMissingWordId,
                  InvalidRowReason.missingSentence =>
                    l10n.peImportMissingSentence,
                }}'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _count(String label, int value, String key) => ListTile(
        dense: true,
        contentPadding: EdgeInsets.zero,
        title: Text(label),
        trailing: Text('$value', key: Key('pe_import_$key')),
      );

  Widget _detail(String text) => Padding(
        padding: const EdgeInsetsDirectional.only(start: 16, bottom: 2),
        child: Text(text, style: Theme.of(context).textTheme.bodySmall),
      );
}
