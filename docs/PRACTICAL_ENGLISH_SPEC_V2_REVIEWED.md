# Practical English V2 Reviewed Specification

## 1. Final architecture direction

The existing app remains the single product and application ID.

- V1 launches first with the current 4,185-item vocabulary product.
- V2 adds Practical English into the same app.
- No second app.
- Existing V1 vocabulary architecture remains intact.
- Practical English is an independent feature module.

Learning path:

Vocabulary -> Sentence -> Pattern -> Scenario -> Listening -> Speaking -> AI

V2.0 focuses on Sentence Learning.

## 2. Vocabulary-to-Sentence relationship

WordItem.id is the stable identity of a vocabulary item, but it is NOT the Sentence primary key.

Rules:

- Every Sentence has its own stable Sentence.id.
- Sentence.wordIds is a list of WordItem.id values.
- One sentence may contain multiple target words.
- One word may have many sentences.
- Persistent relationships must never depend on list indexes.
- Sentence IDs must not collide across built-in and imported content.

This corrects an important ambiguity in the original specification: WordItem.id is a foreign/reference identity, not the Sentence ID.

## 3. Sentence data model

Recommended V2.0 model:

- id
- wordIds
- datasetId
- targetLanguage
- translationLocale
- sentenceText
- translationText or translations
- level
- category
- patternId (nullable)
- scenarioId (nullable)
- metadata (optional)

Example:

{
  "id": "sentence_000001",
  "wordIds": ["ngsl_2809_1", "ngsl_2809_2"],
  "datasetId": "practical_en_v2_core",
  "targetLanguage": "en",
  "translationLocale": "zh-TW",
  "sentenceText": "I need some help.",
  "translationText": "我需要一些幫助。",
  "level": "A1",
  "category": "daily",
  "patternId": null,
  "scenarioId": null,
  "metadata": {}
}

The model should be multilingual-ready now, even if the first content release is English + Traditional Chinese.

## 4. SentenceRepository

Use an independent SentenceRepository.

Do not extend CustomDatasetRepository into a combined vocabulary/sentence repository.

Reasons:

- Vocabulary and Sentence have different lifecycles.
- Sentence search/filtering and progress will evolve independently.
- Future Pattern/Scenario relationships should not be coupled to vocabulary storage.
- A separate repository keeps V1 stable and makes future migration easier.

## 5. Sentence CSV import

Support:

word,translation,sentence,sentence_translation

and separate sentence import:

word_id,sentence,sentence_translation

A future multilingual form may include:

word_id,sentence,sentence_translation,target_language,translation_locale,level,category

Import rules:

1. Resolve word_id against existing stable WordItem.id.
2. Reject or report unresolved Word IDs.
3. Generate a stable Sentence ID if the source does not provide one.
4. Deduplicate using normalized sentence content plus relevant identity fields.
5. Re-importing the same content must be idempotent.
6. Prevent Sentence ID collisions.
7. File-level hash may be used as an optimization, but sentence-level deduplication remains authoritative.
8. Show import results: added, duplicate/skipped, invalid Word ID, invalid row.
9. Do not call AI automatically during import.

## 6. Storage decision for V2.0

Final decision: DO NOT introduce SQLite, Drift or Sqflite solely for V2.0.

Use the existing lightweight repository/local-storage direction:

- Built-in sentence content: JSON/assets or equivalent read-only content files.
- Imported sentences: local application storage managed by SentenceRepository.
- Sentence learning progress: lightweight local persistence using a separate Practical English namespace.
- Persistent relationships use stable IDs, never list indexes.

Rationale:

- V2.0 sentence content is manageable as local content.
- SQLite would increase implementation and migration risk.
- Offline-first does not require SQLite.
- Database migration can be introduced later if actual scale requires full-text search, large content packs, advanced querying, analytics or complex spaced repetition.

## 7. Module and State isolation

Use:

lib/practical_english/

with internal domain, data and presentation areas.

Example:

lib/
  practical_english/
    domain/
      models/
      services/
    data/
      sentence_repository.dart
    presentation/
      providers/
      screens/
      widgets/

Practical English must use its own State/Provider.

Do not add sentence-learning state, sentence playback state, sentence filters or sentence progress to the existing AppState.

Do not introduce Riverpod/Bloc solely for V2.0 if the current project dependencies and conventions provide a simpler suitable approach. Select the state mechanism during implementation based on the existing codebase.

## 8. Offline-first and TTS

V2.0 remains offline-first.

- Keep vocabulary and sentence content locally available.
- Use system TTS through the existing flutter_tts approach.
- Do not package large MP3/WAV libraries in the APK.
- Future downloadable content packs may expand the content without requiring the entire app to be rebuilt.

## 9. V1 -> V2 migration safety

V2 must preserve:

- existing vocabulary progress
- favorites
- custom datasets
- playback settings
- monetization state where applicable

Before changing any existing SharedPreferences key or value type:

- inventory the existing V1 key/value structure;
- never reuse an existing key for an incompatible type;
- use new namespaced keys for Practical English;
- add migration only when an existing persisted structure actually changes.

Because V2.0 does not introduce SQLite, no database migration is required.

## 10. Future-proofing without over-engineering

Supported now:

- patternId nullable
- scenarioId nullable
- level optional
- category optional
- metadata optional

Do not make metadata the primary storage mechanism for concepts that later require reliable querying.

Defer:

- audio storage
- ASR scoring
- AI conversation
- AI sentence generation
- cloud TTS
- advanced spaced repetition
- cloud sync/authentication

These can be added with dedicated models/services when actually implemented.

## 11. V2.0 implementation scope

Implement only:

1. Sentence model
2. SentenceRepository
3. Sentence local storage
4. Sentence CSV import
5. Validation and deduplication
6. Sentence list/detail UI
7. Word-to-sentence linking
8. System TTS
9. Basic sentence learning/progress
10. Independent Practical English state/provider
11. Backward compatibility with V1 data

Do not rebuild V1.

## 12. Roadmap

- V2.0: Sentence learning
- V2.1: Patterns
- V2.2: Scenarios/context
- V2.3: Listening improvements
- V2.4: Speaking/ASR
- V3: AI generation, role-play and adaptive learning

## 13. AI collaboration

- ChatGPT: product management, architecture and final decision synthesis.
- Gemini: independent technical review and challenge.
- Claude: primary Flutter/Dart implementation and debugging.

Workflow:

1. ChatGPT defines requirements.
2. Gemini reviews.
3. ChatGPT integrates and finalizes.
4. Claude implements.
5. Gemini may review implementation.
6. Final decisions are synchronized to GitHub.

## 14. Final decision classification

### Must decide now

1. Independent Sentence.id.
2. Sentence.wordIds list referencing WordItem.id.
3. Independent SentenceRepository.
4. Independent Practical English State/Provider.
5. Multilingual-ready core fields: datasetId, targetLanguage, translationLocale.
6. CSV validation and sentence-level deduplication.
7. Offline-first.
8. No SQLite for V2.0 unless actual implementation evidence proves it necessary.
9. V1 persistence backward compatibility.

### Can remain simple in V2.0

- system TTS
- basic learning/progress state
- Traditional Chinese translation as the first content release
- simple local content repository
- existing project-compatible State management

### Deliberately defer

- SQLite/Drift migration
- cloud sync/authentication
- advanced spaced repetition
- ASR scoring
- AI conversation
- AI sentence generation
- cloud TTS
- complex Pattern/Scenario engines

## 15. Implementation principle

Make the smallest safe architectural additions required for V2.0 while preserving the current V1.

The goal is controlled evolution, not a rewrite.
