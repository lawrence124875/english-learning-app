import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../providers/app_state.dart';

/// 訂閱付費頁面：顯示方案、目前訂閱狀態、恢復購買按鈕。
class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  Offerings? _offerings;
  bool _loading = true;
  bool _purchasing = false;

  @override
  void initState() {
    super.initState();
    _loadOfferings();
  }

  Future<void> _loadOfferings() async {
    final offerings = await Purchases.getOfferings();
    setState(() {
      _offerings = offerings;
      _loading = false;
    });
  }

  Future<void> _purchase(Package package) async {
    setState(() => _purchasing = true);
    final appState = context.read<AppState>();
    final success = await appState.purchasePremiumPackage(package);
    if (!mounted) return;
    setState(() => _purchasing = false);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('訂閱成功！已解鎖完整內容並移除廣告。')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('購買未完成，請稍後再試一次。')),
      );
    }
  }

  Future<void> _restore() async {
    final appState = context.read<AppState>();
    final restored = await appState.restorePremium();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(restored ? '已恢復 Premium 訂閱！' : '找不到可恢復的購買紀錄。')),
    );
    if (restored) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(title: const Text('升級 Premium')),
      body: appState.isPremium
          ? const Center(child: Text('您已經是 Premium 訂閱戶 🎉'))
          : _loading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    const Text(
                      '解鎖完整學習內容',
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    const _BenefitRow(text: '四份教材 100% 完整開放'),
                    const _BenefitRow(text: '完全移除廣告'),
                    const _BenefitRow(text: '背景播放、鎖屏顯示'),
                    const SizedBox(height: 24),
                    ..._buildPackages(),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: _restore,
                      child: const Text('恢復先前購買'),
                    ),
                  ],
                ),
    );
  }

  List<Widget> _buildPackages() {
    final packages = _offerings?.current?.availablePackages ?? [];
    if (packages.isEmpty) {
      return [const Text('目前沒有可用的訂閱方案，請稍後再試。')];
    }
    return packages
        .map(
          (p) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: FilledButton(
              onPressed: _purchasing ? null : () => _purchase(p),
              child: Text(
                  '${p.storeProduct.title} - ${p.storeProduct.priceString}'),
            ),
          ),
        )
        .toList();
  }
}

class _BenefitRow extends StatelessWidget {
  final String text;
  const _BenefitRow({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.teal, size: 20),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }
}
