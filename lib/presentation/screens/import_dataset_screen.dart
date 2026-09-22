import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import '../../data/sources/csv_import_service.dart';
import '../../domain/models/word_item.dart';
import '../providers/app_state.dart';

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
  bool _importing = false;

  static const _localeOptions = {
    'zh-TW': '中文',
    'ja': '日文',
    'ko': '韓文',
    'vi': '越南文',
    'en': '英文（例如額外附註/同義說明）',
  };

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _shareTemplate() async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/匯入範本.csv');
    await file.writeAsString(CsvImportService.templateCsv());
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('範本已存到暫存資料夾：${file.path}')),
    );
  }

  Future<void> _pickAndImport() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('請先幫這份教材取個名字')));
      return;
    }

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );
    if (result == null || result.files.single.path == null) return;

    setState(() => _importing = true);
    try {
      final file = File(result.files.single.path!);
      final content = await file.readAsString();
      final parsed = CsvImportService.parse(content, _translationLocale);

      final dataset = WordDataset(
        id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        shortName: name.length > 6 ? name.substring(0, 6) : name,
        items: parsed.items,
      );

      if (!mounted) return;
      await context.read<AppState>().addCustomDataset(dataset);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(parsed.skippedRows > 0
              ? '匯入完成！共 ${parsed.items.length} 筆（略過 ${parsed.skippedRows} 筆空白列）'
              : '匯入完成！共 ${parsed.items.length} 筆'),
        ),
      );
      Navigator.pop(context);
    } on CsvImportException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('匯入失敗：${e.message}')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('匯入失敗，請確認檔案格式是否正確')));
    } finally {
      if (mounted) setState(() => _importing = false);
    }
  }

  Future<void> _confirmDelete(BuildContext context, String id, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('刪除自訂教材'),
        content: Text('確定要刪除「$name」嗎？這個動作無法復原。'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false), child: const Text('取消')),
          TextButton(
              onPressed: () => Navigator.pop(context, true), child: const Text('刪除')),
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
    final customDatasets =
        appState.datasets.where((d) => d.id.startsWith('custom_')).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('匯入自訂教材')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            '可以匯入自己準備的單字、片語，或常用例句（例如自己書上的內容），'
            '匯入後會跟內建教材一樣可以切換朗讀。',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('匯入格式（CSV，含表頭）',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text(
                    'english,translation\n'
                    'apple,蘋果\n'
                    'give up,放棄\n'
                    'How are you doing today?,你今天過得怎麼樣？',
                    style: TextStyle(fontFamily: 'monospace', fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '第一欄放英文（單字/片語/整句例句都可以），第二欄放對應翻譯，'
                    '存成 CSV 檔即可匯入。',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _shareTemplate,
                    icon: const Icon(Icons.download, size: 18),
                    label: const Text('取得範本檔案'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: '這份教材的名稱',
              hintText: '例如：多益核心例句',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _translationLocale,
            decoration: const InputDecoration(
              labelText: '翻譯欄位是什麼語言？',
              border: OutlineInputBorder(),
            ),
            items: _localeOptions.entries
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
            label: Text(_importing ? '匯入中…' : '選擇 CSV 檔並匯入'),
          ),
          if (customDatasets.isNotEmpty) ...[
            const SizedBox(height: 32),
            const Text('已匯入的自訂教材', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            for (final d in customDatasets)
              Card(
                child: ListTile(
                  title: Text(d.name),
                  subtitle: Text('${d.items.length} 個項目'),
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
