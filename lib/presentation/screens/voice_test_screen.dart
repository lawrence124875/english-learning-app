import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/sources/tts_service.dart';

/// 語音預覽畫面：單純讓使用者聽聽看手機裡有哪些英文語音可以選。
///
/// 不提供「套用/持久保存」功能——Android 系統的 TTS 引擎在連續多次
/// 朗讀時，沒辦法可靠地一直保留住手動指定的語音（部分裝置測試會在
/// 播完第一句後自動跳回系統預設語音），與其提供一個效果不穩定的
/// 功能，不如直接統一使用系統依語言自動選擇的預設語音，改成單純的
/// 試聽功能就好。
class VoiceTestScreen extends StatefulWidget {
  const VoiceTestScreen({super.key});

  @override
  State<VoiceTestScreen> createState() => _VoiceTestScreenState();
}

class _VoiceTestScreenState extends State<VoiceTestScreen> {
  List<Map<String, String>> _voices = [];
  bool _loading = true;

  static const _sampleText = 'This is a preview of this voice.';

  @override
  void initState() {
    super.initState();
    _loadVoices();
  }

  Future<void> _loadVoices() async {
    final tts = context.read<TtsService>();
    final voices = await tts.getVoices();
    voices.sort((a, b) {
      bool isHq(Map<String, String> v) {
        final name = (v['name'] ?? '').toLowerCase();
        return name.contains('natural') ||
            name.contains('enhanced') ||
            name.contains('neural') ||
            name.contains('google');
      }

      final aHq = isHq(a) ? 0 : 1;
      final bHq = isHq(b) ? 0 : 1;
      return aHq.compareTo(bHq);
    });
    setState(() {
      _voices = voices;
      _loading = false;
    });
  }

  Future<void> _preview(Map<String, String> voice) async {
    final tts = context.read<TtsService>();
    await tts.setVoice(voice);
    await tts.speak(_sampleText, languageCode: 'en-US');
    // 試聽完立刻清掉，確保不會殘留影響到正式巡航朗讀時使用的語音。
    tts.clearPinnedVoice();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('語音預覽')),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              '這裡列出手機裡可用的英文語音，點播放圖示試聽即可。'
              '正式朗讀時 App 會統一使用系統預設語音（依語言自動選擇），'
              '這裡純粹讓你先聽聽看手機裡有哪些語音可以選。',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _voices.isEmpty
                    ? const Center(child: Text('找不到可用的語音，請確認手機已安裝英文語音包。'))
                    : ListView.builder(
                        itemCount: _voices.length,
                        itemBuilder: (context, i) {
                          final voice = _voices[i];
                          return ListTile(
                            title: Text(voice['name'] ?? '未知語音'),
                            subtitle: Text(voice['locale'] ?? ''),
                            trailing: IconButton(
                              icon: const Icon(Icons.volume_up),
                              onPressed: () => _preview(voice),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
