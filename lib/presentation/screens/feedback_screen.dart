import 'package:flutter/material.dart';
import '../../data/sources/feedback_service.dart';
import '../../l10n/app_localizations.dart';

/// 意見回饋畫面：讓使用者回報問題或提出功能建議，送進 Firestore。
class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _messageController = TextEditingController();
  final _emailController = TextEditingController();
  FeedbackCategory _category = FeedbackCategory.suggestion;
  bool _submitting = false;

  @override
  void dispose() {
    _messageController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  String _categoryLabel(FeedbackCategory c, AppLocalizations l) {
    switch (c) {
      case FeedbackCategory.bug:
        return l.feedbackCategoryBug;
      case FeedbackCategory.suggestion:
        return l.feedbackCategorySuggestion;
      case FeedbackCategory.other:
        return l.feedbackCategoryOther;
    }
  }

  Future<void> _submit() async {
    final l = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final message = _messageController.text.trim();
    if (message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.feedbackEmpty)),
      );
      return;
    }
    setState(() => _submitting = true);
    try {
      await FeedbackService.submit(
        message: message,
        category: _category,
        contactEmail:
            _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        locale: locale,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.feedbackThanks)),
      );
      Navigator.pop(context);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.feedbackFailed)),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l.feedbackTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l.feedbackCategoryLabel, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              children: FeedbackCategory.values.map((c) {
                return ChoiceChip(
                  label: Text(_categoryLabel(c, l)),
                  selected: _category == c,
                  onSelected: (_) => setState(() => _category = c),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            Text(l.feedbackMessageLabel, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _messageController,
              maxLines: 6,
              decoration: InputDecoration(
                hintText: l.feedbackMessageHint,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            Text(l.feedbackEmailLabel, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: l.feedbackEmailHint,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: _submitting ? null : _submit,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: _submitting
                    ? const SizedBox(
                        height: 20, width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(l.feedbackSubmit),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
