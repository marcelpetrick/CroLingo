# Grading ideas and open work

Working notes on how CroLingo decides whether a learner was right, what
changed recently, and what is still open. Not committed policy: the
implemented parts are marked as such, everything else is a proposal.

Status date: 2026-08-26. Repository at `39be0fc`, everything pushed.

## Part 1 — Text grading

### What it does today

`AnswerGrader.grade` compares a submission against the authored
`acceptedAnswers` after normalising both sides the same way. Normalisation is
NFC, lowercase, drop punctuation, collapse whitespace, trim.

| Ignored | Significant |
| --- | --- |
| Case | Every letter |
| Leading and trailing whitespace | Diacritics: `č` is not `c` |
| Repeated inner whitespace | `dán` is not `dan` |
| `. , ! ? ; : …` | Hyphens, so German compounds keep meaning |
| Quotes and apostrophes | Word order |

Apostrophes are dropped rather than replaced by a space, so `geht's` and
`gehts` are one answer. An empty submission can never be correct regardless of
what the content says.

`CourseValidator` rejects two content mistakes this tolerance creates:
accepted answers that differ only in punctuation, which are one answer to a
learner and hide that a real variant is still missing, and punctuation-only
answers, which would otherwise grade an empty submission as correct. The
validator calls the grader's own normaliser, because two independent notions
of equality would drift apart and make the check theatre.

### Both directions are graded, and enforced

Content carries five mastery dimensions. Two of them are recall directions,
and the validator fails the build if any concept lacks either, or has fewer
than three exposures.

| Dimension | Count in current content |
| --- | --- |
| `germanToCroatian` | 20 |
| `croatianToGerman` | 20 |
| `recognition` | 10 |
| `grammarApplication` | 10 |
| `sentenceProduction` | 10 |

All 20 concepts have both recall directions. So yes, the learner has to
produce the German as well as the Croatian, and that is a build-time
guarantee rather than an authoring convention.

### Synonyms are authoring, not algorithm

Because grading is exact-after-normalisation, every legitimate wording must be
authored. Six exercises were extended for this reason. Two of the additions
are spellings rather than synonyms: `Ich heiße Mia.` and `Wie heißt du?` were
the only accepted answers for their exercises, and a Swiss keyboard has no
eszett, so a Swiss learner could not type a correct answer at all. Both now
accept the `ss` form.

Two candidates were deliberately rejected. `Ich heiße Ana.` for `Ja sam Ana.`
would blur the distinction between `ja sam` and `zovem se` that the lesson
pair exists to teach, and `Mir geht es gut.` is not a translation of the
single word `Dobro.`. Leniency that teaches something false costs more than
the failure it prevents.

### Open text-grading ideas

Not implemented, in rough order of value:

1. **Typo tolerance.** Accept an edit distance of one on long answers while
   keeping diacritics significant. Risk: `č`/`c` and `š`/`s` confusions are
   exactly the errors the course must correct, so distance must be computed
   after folding case but never after folding diacritics.
2. **Targeted diacritic feedback.** When a submission differs from an accepted
   answer only in diacritics, say so instead of showing a generic correction.
   Cheap, and it addresses the single most common German-speaker error class.
3. **Partial credit on sentence tasks.** Tile ordering currently passes or
   fails whole. Word-level scoring would make long sentences less punishing.
4. **Generated exercises from concepts and templates.** At roughly 1500
   exercises, hand-authored JSON in one file stops being reviewable. Author
   concepts plus templates, generate the four families, keep the validator as
   the gate.

## Part 2 — Review scheduling

Scheduling is a grading question in disguise: it decides what the learner is
asked next.

FSRS state was keyed by exercise ID, so memory belonged to the exercise rather
than to the word. Every newly authored exercise started the learner cold on a
concept they had known for months. It is now keyed by concept and mastery
dimension, so recalling `hvala` from German and recognising it in Croatian are
tracked as the separate abilities they are, and both survive re-authoring.

Only content can say which concept an attempt practised, and the attempts
table stores none, so the course is passed into `loadDueReviews` and mapped at
replay time by `ReviewPlanner` in `domain/review`. That avoids a migration and
lets re-authored content re-map history automatically. It is also the existing
idiom: the schedule was already reconstructed from the attempt log on every
call, never stored.

A due concept is presented through the exercise the learner has seen least
recently, preferring one never attempted, so repetition varies the task
instead of drilling one item.

## Part 3 — Pronunciation grading

### What will not work

Comparing the learner's recording to a native reference with DTW over MFCCs
measures voice similarity, not correctness. Different pitch, gender or
speaking rate is punished; a confidently wrong word with the right rhythm
scores well. Useful only as a "did you speak, loudly enough, long enough"
gate, never as a score. The product specification already warns against
assuming raw audio comparison suffices, and that warning is right.

### What can work, in three shippable stages

| Stage | What it does | Cost |
| --- | --- | --- |
| 0 | Record, replay, A/B against the native recording | No ML, no model |
| 1 | Verify the intended word was spoken | On-device ASR |
| 2 | Per-phoneme score and targeted feedback | Phoneme model plus lexicon |

Stage 1 is closed-vocabulary verification, not open dictation, because the
target phrase is known. Caveat: ASR language models snap to plausible words,
so a mispronounced word often still transcribes correctly. It answers "did you
say the right thing", not "did you say it well".

Stage 2 is the differentiating feature: Goodness of Pronunciation scoring from
a wav2vec2-CTC phoneme model. Croatian helps here, because its near-phonemic
orthography makes grapheme-to-phoneme close to a lookup table, far more
tractable than English.

### Latency, for a 1.5 second utterance

| Approach | Estimate | Fits a 2 s budget |
| --- | --- | --- |
| Stage 0 energy and duration checks | under 20 ms | Trivially |
| Stage 2 wav2vec2-CTC phonemes | 200 to 600 ms | Yes |
| Stage 1 Whisper tiny, quantized | 0.5 to 1.5 s | Borderline |
| Stage 1 Whisper base | 2 to 4 s | No |

The non-obvious result: the phoneme model is faster than the ASR, because CTC
is a single forward pass while Whisper decodes token by token. The more
valuable feature is also the more feasible one on latency.

These are architectural estimates, not measurements on the target device. This
repository decides from evidence, so a benchmark must come before any design
commitment.

### Costs to accept before starting

- A quantized model near 40 MB roughly doubles the 20.3 MB ARM64 APK.
- `RECORD_AUDIO` changes the privacy story the specification currently states
  as "no microphone is used", including the store data-safety declaration.
- A new native runtime enters the pinning, SBOM and vulnerability-scan
  surface.

### German-speaker error inventory

Worth authoring alongside Stage 2, because it is what targeted feedback would
point at:

- `č` against `ć`, and `dž` against `đ`
- Syllabic `r`, as in `prst`
- Aspirated `p`, `t`, `k`, which German does and Croatian does not
- Final devoicing: German turns `grad` into `grat` automatically

## Part 4 — Content, the actual gap

| | Now | A1 target | A2 target |
| --- | --- | --- | --- |
| Concepts | 20 | about 600 | about 1400 |
| Units and lessons | 2 and 10 | 12 and 60 | 28 and 140 |
| Exercises | 70 | about 1500 | about 3500 |
| Themes | Greetings, introductions | 12 everyday domains | Plus past, future, opinions |

About three percent of A1 by vocabulary. The machinery is proven; the content
is a pilot.

Proposed spine, situation-first with CEFR as a hidden checklist. The
sequencing decision that actually determines difficulty is cases: introduce
them lexically first, as fixed phrases such as `u Zagrebu` and `idem u grad`,
and surface the paradigm only in late A1. The case system taught as a table is
where German-speaking beginners quit.

- **A1**, roughly ten more units: numbers and prices, food and ordering,
  shopping, directions, time and days, family, accommodation, weather,
  `biti` and `imati` plus the top thirty verbs, noun gender, accusative
  objects, questions.
- **A2**, roughly sixteen units: perfekt, future, locative and genitive,
  verbal aspect as the real wall, comparatives, health, travel and tickets,
  opinions and small talk.

Cheap format gaps worth closing, none needing new assets: listening to typed
answer using the existing text-to-speech, multiple choice for a much lower
typing burden on a phone, dictation, and gender tagging for Croatian nouns.

## Part 5 — Open work

### Blocked on a decision

The pronunciation Stage 2 benchmark. Three routes:

1. Throwaway spike outside the repository, committing only a findings
   document. Cheapest way to learn whether the feature is feasible before
   paying for it. Recommended.
2. In-repository behind a flag. Realistic integration, but the model size and
   native runtime land now.
3. Ship Stage 0 first instead. No ML, uses the native speaker immediately, but
   adds the microphone permission.

### Not started

- A1 content units, in the thematic order above.
- Integration suite on real hardware. `integration_test/` and
  `scripts/run_integration_tests.sh` exist and found a real disposal bug when
  written, but have never run on either ARM64 phone. The application has never
  been verified on the hardware it targets.

### Blocked upstream

Both wait on the same fact, that `flutter_test` pins `test_api` and `matcher`
below analyzer 13. The weekly `upstream-watch` workflow tracks it, so neither
needs attention until it goes red.

- No Riverpod lint rule runs, review item 0.
- `riverpod_lint` 3.1.8, `drift_dev` 2.34.1 and later, and `build_runner`
  2.16.0 are unreachable, review item 1.

### Low severity, no urgency

Items 3 to 8 of `docs/review20260809.md`: local-flavoured Drift timestamps,
the size of `lesson_screen.dart`, a few lines that cannot be covered
headlessly, the untested database provider, two untested error branches, and
the specification being excluded from linting. Items 9 to 11 are marked
Accepted and need no action.
