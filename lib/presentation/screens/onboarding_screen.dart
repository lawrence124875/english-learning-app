import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../l10n/app_localizations.dart';
import '../../practical_english/practical_english_release.dart';

/// 特色介紹（滑動導覽）。
/// - 第一次開啟 App 時自動顯示一次（舊使用者更新後也會看到一次）。
/// - 之後可從右上角選單「功能介紹」再次查看。
/// 內容比照 Google Play 商店說明：20/80 法則、目標族群的痛點、
/// 背景朗讀、雙語朗讀與不熟悉單字庫、匯入自訂教材、四大教材與免費體驗。
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  /// 版本號放在 key 裡：日後介紹內容大改時改成 _v2，
  /// 所有使用者就會再看到一次新的介紹。
  static const _seenKey = 'onboarding_seen_v1';

  /// 還沒看過介紹就顯示，看過（或略過）就不再自動出現。
  static Future<void> showIfFirstTime(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getBool(_seenKey) ?? false) return;
      await prefs.setBool(_seenKey, true);
    } catch (_) {
      return; // 讀不到設定就不打擾使用者
    }
    if (!context.mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => const OnboardingScreen(),
      ),
    );
  }

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _IntroPage {
  final IconData icon;
  final String title;
  final String body;
  const _IntroPage(this.icon, this.title, this.body);
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<_IntroPage> _pages(AppLocalizations l) => [
        _IntroPage(Icons.insights, l.introTitle1, l.introBody1),
        _IntroPage(Icons.favorite_outline, l.introTitle2, l.introBody2),
        _IntroPage(Icons.headphones, l.introTitle3, l.introBody3),
        _IntroPage(Icons.star_outline, l.introTitle4, l.introBody4),
        _IntroPage(Icons.upload_file, l.introTitle5, l.introBody5),
        _IntroPage(Icons.menu_book_outlined, l.introTitle6, l.introBody6),
        // V2：實用英文介紹頁，只在就緒開關打開時出現；關閉時跟原本 6 頁完全一樣。
        if (PracticalEnglishRelease.enabled)
          _IntroPage(Icons.chat_bubble_outline, l.introTitle7, l.introBody7),
      ];

  void _close() => Navigator.of(context).pop();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final pages = _pages(l);
    final isLast = _page == pages.length - 1;
    // 橫向時可用高度只剩約 200dp，直向版面（圖示在上、文字在下）會把
    // 文字擠出畫面外、只看得到圖示。橫向改成左右排版並縮小間距。
    final landscape =
        MediaQuery.orientationOf(context) == Orientation.landscape;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
                child: isLast
                    ? const SizedBox(height: 48)
                    : TextButton(onPressed: _close, child: Text(l.introSkip)),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: pages.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (context, i) {
                  final p = pages[i];
                  if (landscape) {
                    return Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 48, vertical: 8),
                        child: Row(
                          children: [
                            Container(
                              width: 88,
                              height: 88,
                              decoration: BoxDecoration(
                                color: scheme.primaryContainer,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(p.icon,
                                  size: 44, color: scheme.onPrimaryContainer),
                            ),
                            const SizedBox(width: 32),
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    p.title,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    p.body,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.copyWith(height: 1.5),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 24),
                    child: Column(
                      children: [
                        const SizedBox(height: 24),
                        Container(
                          width: 112,
                          height: 112,
                          decoration: BoxDecoration(
                            color: scheme.primaryContainer,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(p.icon,
                              size: 56, color: scheme.onPrimaryContainer),
                        ),
                        const SizedBox(height: 36),
                        Text(
                          p.title,
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          p.body,
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(height: 1.7),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < pages.length; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: i == _page ? 20 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: i == _page
                          ? scheme.primary
                          : scheme.primary.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: landscape
                  ? const EdgeInsets.fromLTRB(24, 10, 24, 10)
                  : const EdgeInsets.fromLTRB(24, 20, 24, 24),
              child: SizedBox(
                width: double.infinity,
                height: landscape ? 44 : 52,
                child: FilledButton(
                  onPressed: isLast
                      ? _close
                      : () => _controller.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                          ),
                  child: Text(isLast ? l.introStart : l.introNext,
                      style: const TextStyle(fontSize: 17)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
