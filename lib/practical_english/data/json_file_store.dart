import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// 讀取失敗（主檔與備份都損毀）時的回報，用來記 Crashlytics non-fatal。
typedef JsonStoreErrorReporter = void Function(Object error, StackTrace stack);

/// Practical English 共用的 JSON 檔案存取（SPEC §7.3、§7.4）。
///
/// 寫入：先寫 `<file>.tmp` 並 flush → 原檔改名為 `<file>.bak` →
/// `.tmp` 改名為 `<file>`。任何一步失敗，原本的資料都還在。
///
/// 讀取：主檔 → `.bak` → 兩者都壞就把壞檔改名為 `<file>.corrupt-<時間>`
/// 保留供診斷，回傳 null（呼叫端從空狀態開始）。檔案不存在屬正常，不算錯誤。
///
/// 寫入可延遲合併（debounce）：[scheduleWrite] 2 秒內多次呼叫只寫最後一次；
/// App 進背景或離開 Practical English 時呼叫 [flush] 立即寫出。
class JsonFileStore {
  final File file;
  final Duration debounce;
  final JsonStoreErrorReporter? onError;

  Timer? _timer;
  Object? _pending;
  bool _hasPending = false;
  Future<void> _writing = Future.value();

  JsonFileStore(
    this.file, {
    this.debounce = const Duration(seconds: 2),
    this.onError,
  });

  File get _tmp => File('${file.path}.tmp');
  File get _bak => File('${file.path}.bak');

  /// 讀取 JSON。回傳 null 代表沒有檔案，或主檔與備份都無法解析。
  Future<Object?> read() async {
    final mainExists = await file.exists();
    final bakExists = await _bak.exists();
    if (!mainExists && !bakExists) return null;

    Object? firstError;
    StackTrace? firstStack;
    if (mainExists) {
      try {
        return jsonDecode(await file.readAsString());
      } catch (e, st) {
        firstError = e;
        firstStack = st;
      }
    }
    if (bakExists) {
      try {
        return jsonDecode(await _bak.readAsString());
      } catch (e, st) {
        firstError ??= e;
        firstStack ??= st;
      }
    }

    // 主檔與備份都壞了：保留壞檔供診斷，回報錯誤，從空狀態開始。
    final stamp = DateTime.now().millisecondsSinceEpoch;
    try {
      if (mainExists) await file.rename('${file.path}.corrupt-$stamp');
      if (bakExists) await _bak.rename('${file.path}.bak.corrupt-$stamp');
    } catch (_) {
      // 改名失敗不影響回傳空狀態。
    }
    if (firstError != null) {
      onError?.call(firstError, firstStack ?? StackTrace.current);
    }
    return null;
  }

  /// 立即以原子方式寫入（會排在前一次寫入之後，不會交錯）。
  Future<void> write(Object? json) {
    _writing = _writing.then((_) => _writeNow(json), onError: (_) {
      return _writeNow(json);
    });
    return _writing;
  }

  Future<void> _writeNow(Object? json) async {
    await file.parent.create(recursive: true);
    final tmp = _tmp;
    await tmp.writeAsString(jsonEncode(json), flush: true);
    if (await file.exists()) {
      await file.rename(_bak.path);
    }
    await tmp.rename(file.path);
  }

  /// 延遲寫入：[debounce] 期間內多次呼叫只寫最後一份資料。
  void scheduleWrite(Object? json) {
    _pending = json;
    _hasPending = true;
    _timer?.cancel();
    _timer = Timer(debounce, () {
      unawaitedFlush();
    });
  }

  void unawaitedFlush() {
    flush().catchError((Object e, StackTrace st) => onError?.call(e, st));
  }

  /// 立刻寫出尚未寫入的資料（沒有待寫資料時只等待進行中的寫入）。
  Future<void> flush() async {
    _timer?.cancel();
    _timer = null;
    if (_hasPending) {
      final data = _pending;
      _pending = null;
      _hasPending = false;
      await write(data);
    } else {
      await _writing;
    }
  }

  bool get hasPendingWrite => _hasPending;
}
