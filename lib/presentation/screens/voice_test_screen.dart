import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../../data/sources/tts_service.dart';

/// 語音測試/預覽畫面：讓使用者在正式開始學習前，
/// 先選好語音並聽一段測試句，確認滿意再套用。
class VoiceTestScreen extends StatefulWidget {
  const VoiceTestScreen({super.key});

  @override
  State<VoiceTestScreen> createState() => _VoiceTestScreenState();
}

class _VoiceTestScreenState extends State<VoiceTestScreen> {
  List<Map<String, String>> _voices = [];
  Map<String, String>? _selectedVoice;
  bool _loading = true;

  static const _sampleText = 'This is a preview of your selected voice.';

  @override
  void initState() {
    super.initState();
    _loadVoices();
  }

  Future<void> _loadVoices() async {
    final tts = context.read<TtsService>();
    final voices = await tts.getVoices();
    // 高音質語音（Natural/Enhanced/Neural/Google）優先排前面。
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
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.read<AppState>();

    return Scaffold(
      appBar: AppBar(title: const Text('語音測試/預覽')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _voices.isEmpty
              ? const Center(child: Text('找不到可用的語音，請確認手機已安裝英文語音包。'))
              : ListView.builder(
                  itemCount: _voices.length,
                  itemBuilder: (context, i) {
                    final voice = _voices[i];
                    final selected = voice == _selectedVoice;
                    return ListTile(
                      title: Text(voice['name'] ?? '未知語音'),
                      subtitle: Text(voice['locale'] ?? ''),
                      selected: selected,
                      trailing: IconButton(
                        icon: const Icon(Icons.volume_up),
                        onPressed: () => _preview(voice),
                      ),
                      onTap: () {
                        setState(() => _selectedVoice = voice);
                        _preview(voice);
                      },
                    );
                  },
                ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(
            onPressed: _selectedVoice == null
                ? null
                : () async {
                    await appState.updateSettings(
                        appState.settings.copyWith(
                            voiceId: _selectedVoice!['name']));
                    if (context.mounted) Navigator.pop(context);
                  },
            child: const Text('套用這個語音'),
          ),
        ),
      ),
    );
  }
}
