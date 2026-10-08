# Practical English V2 Specification

## 1. Product Strategy

The existing app remains the single product and application ID.

- V1: launch the current 4,185-item vocabulary product first.
- V2: add Practical English into the same app as an update.
- No second app.
- Keep the current vocabulary system intact.
- Build Practical English as a modular feature area so it can evolve independently.

## 2. V2 Core Goal

Evolve the product from a vocabulary/listening app into a practical language-learning platform:

**Vocabulary → Sentence → Pattern → Scenario → Listening → Speaking → AI**

V2.0 should focus on sentence learning rather than implementing every future feature at once.

## 3. Existing Data Compatibility

Current core datasets:

- NGSL: 2,809
- NGSL-Spoken: 720
- PHRASE List: 506
- PhaVE List: 150
- Total: 4,185 items

Existing WordItem.id must be treated as the stable identity of a vocabulary item.

Do not use list index as the long-term identity for sentence relationships.

## 4. Language Design

The app is intended to become multilingual.

Keep these concepts separate:

- target language being learned
- translation/UI language
- sentence language
- translation language

Existing custom vocabulary import already supports languages other than English. Practical English must preserve this capability.

## 5. Sentence Data Model

Recommended conceptual model:

- id: sentence_000001
- wordIds: ["ngsl_2809_1"]
- sentenceText: "I need some help."
- translations: {"zh-TW": "我需要一些幫助。", "zh-CN": "我需要一些帮助。"}
- level: A1
- category: daily
- patternId: pattern_need_001
- scenarioId: null

Requirements:

- One sentence may reference multiple wordIds.
- One word may have multiple sentences.
- Sentence ID must be globally stable within the content set.
- Avoid coupling sentence relationships to current dataset indexes.
- Future fields such as audio, speaking metadata, or AI provenance should be optional.

## 6. Sentence Import

Support both approaches.

Same-file import:

word,translation,sentence,sentence_translation

Optional advanced fields:

word,translation,pos,sentence,sentence_translation,level,category

Separate sentence import:

word_id,sentence,sentence_translation

Sentence import should link to the stable WordItem.id.

Import must not automatically call AI generation.

If no sentence data exists, vocabulary learning must continue to work normally and Practical English can display a "No sentences yet" state.

## 7. Content and Program Separation

Separate learning content from program logic.

Recommended direction:

- vocabulary data
- sentence data
- pattern data
- scenario data

should be independently maintainable and eventually downloadable as content packs.

Avoid placing large sentence corpora directly into application logic.

## 8. V2 Architecture

Create a parallel Practical English module rather than expanding the existing AppState.

Suggested structure:

lib/
  practical_english/
    domain/
      models/
        learning_sentence.dart
        sentence_pattern.dart
        learning_scenario.dart
      services/
    data/
      sentence_repository.dart
      scenario_repository.dart
    presentation/
      providers/
      screens/
      widgets/

The existing vocabulary architecture should remain stable.

Practical English should have its own state/provider.

## 9. V2.0 Scope

Priority:

1. Sentence model
2. Sentence repository
3. Sentence CSV import
4. Sentence list/detail UI
5. Link sentences to vocabulary WordItem IDs
6. System TTS
7. Basic sentence learning/progress
8. Offline-first operation

Do not implement full AI conversation, advanced speaking assessment, or complex scenario engines in V2.0.

## 10. Future Roadmap

Possible incremental roadmap:

- V2.0: Sentence learning
- V2.1: Patterns
- V2.2: Scenarios and contextual learning
- V2.3: Listening improvements
- V2.4: Speaking/ASR
- V3: AI generation, role-play and adaptive learning

This roadmap is flexible and should be adjusted after real user feedback.

## 11. Offline-first

Core vocabulary and sentence learning should work offline whenever practical.

Use system TTS initially instead of shipping large audio libraries.

Avoid making the initial APK excessively large.

Future downloadable content packs may allow additional languages and sentence sets without requiring a complete application rebuild.

## 12. V1 → V2 Release Strategy

Recommended release sequence:

- V1.0: current vocabulary product, free + Premium subscription
- V1.x: bug fixes, UI/performance/content improvements
- V2.0: Practical English sentence learning
- V2.x: patterns, scenarios, listening and speaking
- V3: AI capabilities

Do not delay the V1 launch solely to complete V2.

## 13. AI Collaboration

Recommended roles:

- ChatGPT: product manager, architecture, requirements integration and final decision synthesis
- Gemini: independent architecture/technical review and challenge
- Claude: primary Flutter/Dart implementation and debugging

Do not have all three systems independently implement the same feature.

Recommended workflow:

1. ChatGPT defines the product/architecture.
2. Gemini reviews and challenges the proposal.
3. ChatGPT integrates the review and finalizes the decision.
4. Claude implements the finalized specification.
5. Gemini may review the implementation when useful.
6. Important final decisions should be synchronized into GitHub documentation.

## 14. Conversation / Token Management

GitHub documentation and source code are the long-term project source of truth.

Chat conversations are working context.

When a conversation becomes too long or a project phase is complete, the AI should independently consider whether a new conversation/thread would improve reliability and token efficiency.

If recommending a new conversation/thread, provide:

1. a clear reminder
2. the reason
3. a short current-phase summary
4. a concise continuation prompt

Claude should prefer Project context and may use separate discussion threads by topic rather than automatically starting a new conversation solely because a thread is long.

## 15. Gemini Review Questions

Before implementation, Gemini should review at least:

1. Is stable WordItem.id sufficient for multilingual and multiple-sentence relationships?
2. Is a minimal extension of CustomDatasetRepository preferable to a major refactor?
3. How should CSV duplicate data and ID collisions be prevented?
4. Should Sentence ID, Dataset ID and target-language constraints be enforced?
5. How can the design remain offline-first without making the APK large?
6. Is the parallel Practical English module compatible with the current presentation/domain/data architecture?
7. How can further growth of AppState be avoided?
8. Is any V1→V2 migration needed for SharedPreferences or existing local data?
9. Will the current data model constrain future Speaking/ASR/AI features?
10. Which decisions are necessary now, and which should deliberately remain deferred?

## 16. Implementation Principle

Do not rebuild the existing V1.

Make the smallest safe architectural additions required for V2 while preserving:

- existing vocabulary datasets
- existing user progress
- existing custom vocabulary
- existing playback functionality
- existing monetization
- existing multilingual foundations

The objective is controlled evolution, not a rewrite.
