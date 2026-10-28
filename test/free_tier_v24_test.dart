import 'package:english_learning_app/data/repositories/progress_repository.dart';
import 'package:english_learning_app/data/repositories/word_repository.dart';
import 'package:english_learning_app/data/sources/paywall_offer.dart';
import 'package:english_learning_app/data/sources/tts_service.dart';
import 'package:english_learning_app/domain/models/word_item.dart';
import 'package:english_learning_app/domain/services/free_tier.dart';
import 'package:english_learning_app/presentation/providers/app_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Tts implements TtsService {
  @override
  dynamic noSuchMethod(Invocation invocation) => Future.value();
}

class _Words implements WordRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => Future.value();
}

WordDataset _ds(String id, int n) => WordDataset(
      id: id,
      name: id,
      shortName: id,
      builtIn: true,
      wordLocale: 'en-US',
      items: [
        for (var i = 0; i < n; i++)
          WordItem(id: '$i', word: 'w$i', translations: const {})
      ],
    );

StoreProduct _product(String priceString, double price, String currency,
        {SubscriptionOption? option, IntroductoryPrice? intro}) =>
    StoreProduct('p', 'd', 't', price, priceString, currency,
        defaultOption: option, introductoryPrice: intro);

SubscriptionOption _optionWithFreePhase(Period? free) => SubscriptionOption(
      'o',
      'p:base',
      'p',
      const [],
      const [],
      true,
      const Period(PeriodUnit.year, 1, 'P1Y'),
      false,
      null,
      free == null
          ? null
          : PricingPhase(free, null, 1, const Price('Free', 0, 'TWD'), null),
      null,
      null,
      null,
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FreeDailyState', () {
    test('rewarded: 3 per day, +20 each to that list', () {
      var s = const FreeDailyState(day: '2026-10-28');
      for (var i = 0; i < 3; i++) {
        s = s.withRewardedUnlock('ngsl')!;
      }
      expect(s.rewardedUses, 3);
      expect(s.rewardedLeft, 0);
      expect(s.extraUnlocked['ngsl'], 60);
      expect(s.withRewardedUnlock('ngsl'), isNull);
    });

    test('new local day resets everything, no carry-over', () {
      final s = const FreeDailyState(day: '2026-10-28')
          .withRewardedUnlock('ngsl')!
          .withPeSentence('a');
      final next = s.forDay('2026-10-29');
      expect(next.rewardedUses, 0);
      expect(next.extraUnlocked, isEmpty);
      expect(next.peSentenceIds, isEmpty);
      expect(identical(s.forDay('2026-10-28'), s), isTrue);
    });

    test('PE: 5 distinct sentences per day, re-opening is free', () {
      var s = const FreeDailyState(day: 'd');
      for (final id in ['a', 'b', 'c', 'd', 'e']) {
        expect(s.canUsePeSentence(id), isTrue);
        s = s.withPeSentence(id);
      }
      s = s.withPeSentence('a');
      expect(s.peSentenceIds.length, 5);
      expect(s.canUsePeSentence('c'), isTrue);
      expect(s.canUsePeSentence('f'), isFalse);
    });

    test('json round trip; corrupt or stale data becomes a fresh day', () {
      final s = const FreeDailyState(day: '2026-10-28')
          .withRewardedUnlock('x')!
          .withPeSentence('s1');
      final back =
          FreeDailyState.fromJsonString(s.toJsonString(), '2026-10-28');
      expect(back.rewardedUses, 1);
      expect(back.extraUnlocked, {'x': 20});
      expect(back.peSentenceIds, {'s1'});
      expect(
          FreeDailyState.fromJsonString(s.toJsonString(), '2026-10-29')
              .rewardedUses,
          0);
      expect(FreeDailyState.fromJsonString('{oops', 'd').day, 'd');
      expect(FreeDailyState.fromJsonString(null, 'd').rewardedUses, 0);
    });

    test('day key uses local date with zero padding', () {
      expect(freeTierDayKey(DateTime(2026, 3, 5, 23, 59)), '2026-03-05');
    });
  });

  group('AppState free tier', () {
    late DateTime now;
    AppState make() => AppState(
        wordRepository: _Words(),
        progressRepository: ProgressRepository(),
        ttsService: _Tts(),
        now: () => now);

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      now = DateTime(2026, 10, 28, 9);
    });

    test('rewarded unlock: +20 x3, kept after restart, gone next day',
        () async {
      final app = make()..debugPreview(data: [_ds('ngsl', 300)]);
      expect(app.unlockedCount(app.currentDataset), 100);
      for (var i = 0; i < 3; i++) {
        expect(await app.unlockMoreViaRewardedAd(), isTrue);
      }
      expect(await app.unlockMoreViaRewardedAd(), isFalse);
      expect(app.unlockedCount(app.currentDataset), 160);
      expect(app.rewardedUsesLeft, 0);

      final restarted = make()..debugPreview(data: [_ds('ngsl', 300)]);
      await restarted.loadFreeDaily();
      expect(restarted.unlockedCount(restarted.currentDataset), 160);
      expect(restarted.rewardedUsesLeft, 0);

      now = DateTime(2026, 10, 29, 0, 1);
      expect(restarted.unlockedCount(restarted.currentDataset), 100);
      expect(restarted.rewardedUsesLeft, 3);
    });

    test('starred: 30 total across lists, legacy >30 kept but no new adds',
        () async {
      final app = make()
        ..debugPreview(data: [_ds('ngsl', 100), _ds('spoken', 100)]);
      await app.replaceStarredFromPracticalEnglish(
          'ngsl', {for (var i = 1; i <= 20; i++) i});
      await app.replaceStarredFromPracticalEnglish(
          'spoken', {for (var i = 0; i < 9; i++) i});
      expect(app.totalStarredCount, 29);
      expect(await app.toggleStarCurrent(), StarToggleResult.added); // idx 0
      expect(app.totalStarredCount, 30);
      expect(app.canAddStar, isFalse);
      expect(await app.toggleStarCurrent(), StarToggleResult.removed);
      expect(await app.toggleStarCurrent(), StarToggleResult.added);

      // 舊使用者已有 31 個：保留、可移除，但不能新增。
      await app.replaceStarredFromPracticalEnglish(
          'spoken', {for (var i = 0; i < 10; i++) i});
      await app.replaceStarredFromPracticalEnglish(
          'ngsl', {for (var i = 1; i <= 21; i++) i});
      expect(app.totalStarredCount, 31);
      expect(await app.toggleStarCurrent(), StarToggleResult.limitReached);
      expect(app.totalStarredCount, 31);

      app.isPremium = true;
      expect(await app.toggleStarCurrent(), StarToggleResult.added);
    });

    test('PE: 5 sentences a day for free users, unlimited for premium',
        () async {
      final app = make()..debugPreview(data: [_ds('ngsl', 10)]);
      for (final id in ['1', '2', '3', '4', '5']) {
        expect(app.canUsePeSentence(id), isTrue);
        await app.recordPeSentence(id);
      }
      expect(app.canUsePeSentence('1'), isTrue);
      expect(app.canUsePeSentence('6'), isFalse);
      app.isPremium = true;
      expect(app.canUsePeSentence('6'), isTrue);
      app.isPremium = false;
      now = now.add(const Duration(days: 1));
      expect(app.canUsePeSentence('6'), isTrue);
    });
  });

  group('PaywallOffer', () {
    test('trial days from Android free phase', () {
      expect(
          PaywallOffer.trialDays(_product('NT\$999.00', 999, 'TWD',
              option: _optionWithFreePhase(
                  const Period(PeriodUnit.day, 7, 'P7D')))),
          7);
      expect(
          PaywallOffer.trialDays(_product('NT\$999.00', 999, 'TWD',
              option: _optionWithFreePhase(
                  const Period(PeriodUnit.week, 1, 'P1W')))),
          7);
      expect(
          PaywallOffer.trialDays(_product('NT\$999.00', 999, 'TWD',
              option: _optionWithFreePhase(null))),
          isNull);
      expect(PaywallOffer.trialDays(_product('NT\$999.00', 999, 'TWD')),
          isNull);
    });

    test('trial days from iOS free intro price', () {
      const intro =
          IntroductoryPrice(0, 'Free', 'P1W', 1, PeriodUnit.week, 1);
      expect(
          PaywallOffer.trialDays(
              _product('\$39.99', 39.99, 'USD', intro: intro)),
          7);
    });

    test('annual price per month', () {
      expect(PaywallOffer.monthlyOfAnnual(_product('NT\$999.00', 999, 'TWD')),
          'NT\$83');
      expect(PaywallOffer.monthlyOfAnnual(_product('NT\$999', 999, 'TWD')),
          'NT\$83');
      expect(PaywallOffer.monthlyOfAnnual(_product('\$39.99', 39.99, 'USD')),
          '\$3.33');
      expect(PaywallOffer.monthlyOfAnnual(_product('¥4,800', 4800, 'JPY')),
          '¥400');
    });
  });
}
