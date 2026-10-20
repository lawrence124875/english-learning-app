import 'dart:async';

/// 目前的朗讀擁有者（SPEC §10）。
enum PlaybackOwner { none, v1, v2 }

/// 一次 [PlaybackCoordinator.claim] 的憑證。只有「目前這一張」才能釋放所有權，
/// 所以過期的完成／錯誤 callback、重複的 stop 都不會清掉另一方（或同一方
/// 較新一次播放）的所有權。
class PlaybackLease {
  final PlaybackOwner owner;
  final int generation;

  const PlaybackLease._(this.owner, this.generation);

  @override
  String toString() => 'PlaybackLease($owner, #$generation)';
}

/// V1 巡航與 V2 句子朗讀共用同一個 TTS 引擎，任何時候只能有一個擁有者。
///
/// - [claim]：成為擁有者。若原本是另一方，先呼叫對方登記的停止函式並等它完成，
///   回傳後才可以開始說話（避免對方延遲的 stop 打斷自己）。
/// - 回傳的 [PlaybackLease] 在 await 期間可能已被更新的 claim 取代；
///   呼叫端開始說話前要用 [isCurrent] 確認。
/// - [release]：播放結束、失敗、離開畫面時歸還；只有目前的 lease 有效。
///
/// 不處理音訊本身，也不改 V1 audio_service／鎖定畫面；只管「誰可以說話」。
class PlaybackCoordinator {
  final void Function(Object error, StackTrace stack)? _onError;

  PlaybackCoordinator({void Function(Object, StackTrace)? onError})
      : _onError = onError;

  final Map<PlaybackOwner, Future<void> Function()> _stoppers = {};
  PlaybackLease? _current;
  int _generation = 0;

  PlaybackOwner get owner => _current?.owner ?? PlaybackOwner.none;

  /// 登記某一方的停止函式（另一方 claim 時呼叫）。同一方重複登記以最後一次為準。
  void registerStopper(PlaybackOwner who, Future<void> Function() stop) {
    assert(who != PlaybackOwner.none);
    _stoppers[who] = stop;
  }

  /// 只有登記的是同一個函式才移除（舊畫面晚一步 dispose 時不會移除新畫面的登記）。
  void unregisterStopper(PlaybackOwner who, Future<void> Function() stop) {
    if (_stoppers[who] == stop) _stoppers.remove(who);
  }

  final List<void Function(PlaybackOwner who)> _claimListeners = [];

  /// 每次有人 claim 時通知（例如 V1 開始朗讀時，V2 交還鎖屏）。
  void addClaimListener(void Function(PlaybackOwner who) listener) =>
      _claimListeners.add(listener);

  void removeClaimListener(void Function(PlaybackOwner who) listener) =>
      _claimListeners.remove(listener);

  bool isCurrent(PlaybackLease? lease) =>
      lease != null && identical(lease, _current);

  Future<PlaybackLease> claim(PlaybackOwner who) async {
    assert(who != PlaybackOwner.none);
    final previous = owner;
    final lease = PlaybackLease._(who, ++_generation);
    // 先換擁有者再等待停止：等待期間的其他 claim 會看到最新狀態。
    _current = lease;
    for (final l in List.of(_claimListeners)) {
      try {
        l(who);
      } catch (e, st) {
        _onError?.call(e, st);
      }
    }
    if (previous != PlaybackOwner.none && previous != who) {
      final stop = _stoppers[previous];
      if (stop != null) {
        try {
          await stop();
        } catch (e, st) {
          // 停不下來也不能卡住新的擁有者。
          _onError?.call(e, st);
        }
      }
    }
    return lease;
  }

  /// 歸還所有權；過期或已歸還的 lease 什麼都不做。
  void release(PlaybackLease? lease) {
    if (isCurrent(lease)) _current = null;
  }
}
