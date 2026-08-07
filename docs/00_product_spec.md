use flutter. for desktop linux and android (state 2026)

------

# CroLingo — Reviewed Product Specification

> This original product specification is refined by `01_plan.md` and
> `03_questions.md`. Those documents are authoritative where this document's
> earlier Android-only or audio-MVP assumptions conflict with the current plan.

## 1. Product Vision

**CroLingo** is a Flutter application for learning Croatian on Android phones
and in a phone-shaped Linux desktop window.

The application is inspired by the effective learning mechanics of products such as Duolingo, particularly:

* Short learning sessions
* A predefined progressive learning path
* Small units of new knowledge
* Frequent repetition
* Multiple exercise formats
* Immediate feedback
* Listening and pronunciation practice
* Experience points
* Daily streaks
* Visible progress
* Unit-completion rewards
* Personalized review

CroLingo must nevertheless have its **own visual identity, mascot, content, implementation, interaction design, terminology, and learning logic**.

The primary goal is effective language learning. Monetization, competition, and artificial engagement restrictions are explicitly secondary.

---

# 2. Initial Platform

CroLingo is initially an **Android-first application with a Linux desktop target**.

The implementation should use:

* Flutter and Dart
* A single shared Android/Linux codebase
* Material 3 with an original CroLingo design system
* A local/offline-first architecture

Browser and iOS versions are not part of the initial scope. Linux runs the same
phone experience in a fixed 412×915 logical-pixel window.

The application should be structured so that future expansion remains technically possible without compromising the Android-first MVP.

---

# 3. Target Audience

The primary target users are:

* German-speaking users
* Complete beginners in Croatian
* Users with only very limited previous Croatian knowledge

The initial course should assume that the learner essentially starts from zero.

Some family members may already know a little Croatian, but the application should not assume that knowledge.

Very early material should therefore include concepts such as:

* Hello
* Goodbye
* How are you?
* I am
* You are
* My name is …
* I am eight years old
* Yes
* No
* Basic people
* Basic objects
* Basic actions

---

# 4. Language Directions

The primary course is:

**German → Croatian**

Exercises should also regularly reverse the direction:

**Croatian → German**

The learner must therefore practise both:

* Recognizing Croatian
* Actively producing Croatian

English → Croatian is a possible future extension, but it is not part of the initial course scope.

---

# 5. Proficiency Goal

The initial complete beginner curriculum should approximately target:

**CEFR A1 Croatian**

The application should eventually provide the vocabulary, grammar, comprehension, and basic communication skills expected around A1 level.

However, the visible learning path should not feel like an academic CEFR textbook.

The course should instead be built around lively, everyday subjects.

CEFR A1 should function as an underlying curriculum reference and later as a means of checking whether important beginner competencies are covered.

The product should ultimately be sufficiently structured that it could help users prepare toward recognized beginner-level language competence.

---

# 6. Curriculum Philosophy

The course should focus heavily on practical everyday language.

Potential topics include:

* Greetings
* Introducing yourself
* Family
* People
* Age
* Numbers
* Animals
* Food
* Drinks
* Kitchen items
* Setting a table
* Household objects
* Rooms
* Cleaning
* Shopping
* Travel
* Directions
* Daily activities
* Questions and answers
* Common social situations

The curriculum should introduce common verbs early.

Examples include:

* to be
* to have
* to go
* to come
* to take
* to give
* to ask
* to say
* to read
* to eat
* to drink
* to clean

Grammar should be introduced through useful language rather than being taught only as isolated theory.

Previously learned material should gradually be composed into larger structures.

The progression should look approximately like:

```text
word
→ short expression
→ simple phrase
→ simple sentence
→ combined sentence
→ everyday scenario
```

Examples of later combinations could include:

```text
I take the apple.
She cleans the kitchen.
I read the book.
He drinks water.
The plate is on the table.
```

---

# 7. Low Cognitive Load

A central CroLingo design principle is:

> Do not overwhelm beginners with too much unknown material at once.

In very early lessons, approximately **two genuinely new words or expressions should be introduced per lesson**.

Five entirely unknown items presented simultaneously would create unnecessary guessing and frustration.

Therefore:

* Early lessons introduce around two new learning items.
* Previously introduced material makes up most of the lesson.
* New vocabulary is immediately mixed with known vocabulary.
* The number of new items may gradually increase later.
* Difficulty should increase only as the learner's existing vocabulary grows.

The intention is not to make the course artificially slow, but to ensure that new information is learned rather than guessed.

---

# 8. Predefined Learning Path

CroLingo should use a **preselected learning path**.

The learner should not freely select arbitrary unlearned lessons.

The system determines the normal progression.

A conceptual hierarchy is:

```text
Course
└── Unit
    ├── Lesson
    │   ├── Task
    │   ├── Task
    │   ├── Task
    │   ├── Task
    │   └── Task
    ├── Lesson
    ├── Lesson
    └── ...
```

The learner progresses sequentially through the path.

The next lesson becomes available after the current lesson is completed.

Previously completed lessons remain available for repetition.

Dedicated review activities are available separately from the main learning path.

---

# 9. Units

Multiple lessons form a larger **unit**.

A unit should represent a coherent learning stage or everyday topic.

Examples could be:

```text
Unit: First Words
Unit: At Home
Unit: Food and Drinks
Unit: Family
Unit: Animals
Unit: Around the Kitchen
```

Completing all required lessons in a unit results in a visible completion reward.

The currently preferred concept is a **crown**.

The exact visual design can change, but the unit-completion reward must:

* Be clearly visible
* Feel rewarding
* Remain visible on the learning path
* Give the learner a sense of achievement
* Encourage progression into the next unit

---

# 10. Lessons and Tasks

A lesson consists of several small screens or tasks.

The current default should be approximately:

**5 tasks per lesson**

The exact number may later vary where educationally justified, but five is the initial design target.

Each task focuses on one concrete activity.

For example:

```text
Lesson
├── Task 1 — matching
├── Task 2 — listening
├── Task 3 — translation
├── Task 4 — fill in the blank
└── Task 5 — sentence construction
```

---

# 11. Lesson Completion Rules

A task must eventually be solved correctly.

If the learner makes an incorrect attempt:

1. The answer is marked incorrect.
2. Immediate feedback is presented.
3. The mistake is recorded.
4. The learner gets another attempt.
5. The task eventually has to be answered correctly.

A learner may require multiple attempts.

There is no maximum number of retries.

A lesson is complete once all required tasks have eventually been solved correctly.

Therefore, a lesson cannot permanently fail.

Instead, the distinction is between:

* Completing it efficiently
* Completing it after several mistakes

The difference should affect XP, review scheduling, and mastery data rather than access to future learning.

---

# 12. Repetition Within Learning

A learning concept must not be considered learned simply because the learner answered it correctly once.

New material requires repeated exposure.

The desired rule is that important newly introduced learning items should appear **multiple times, with at least roughly three meaningful exposures during their initial learning cycle**.

These repetitions should preferably use different exercise forms rather than showing exactly the same screen three times.

For example, a new word might first appear in:

1. Vocabulary matching
2. Listening recognition
3. Typed translation

It can then reappear later in:

* Fill-in-the-blank
* Sentence construction
* Spaced review
* A future lesson

The exact algorithm for guaranteeing sufficient initial repetition still needs to be formalized.

---

# 13. Mandatory MVP Exercise Types

## 13.1 Vocabulary Pair Matching

A matching exercise shows two groups of words.

For example:

```text
German                Croatian

[ Haus ]              [ voda ]
[ Wasser ]            [ kuća ]
[ Hund ]               [ stol ]
[ Tisch ]              [ pas ]
```

The learner selects one item from each language.

Interaction rules:

* Only one word on each side can be selected simultaneously.
* Selecting a correct pair confirms it.
* Correct pairs may disappear, become disabled, or otherwise be visibly completed.
* An incorrect pair receives immediate negative feedback.
* A short rejection sound may accompany an incorrect answer.
* The user can immediately try again.

Items should be randomized.

The same words should not always appear in the same order.

---

# 14. Typed Translation

The learner receives a word, expression, or sentence and types its translation.

Both directions should occur:

```text
German → Croatian
Croatian → German
```

The direction should vary so the learner cannot rely only on passive recognition.

As the learner progresses, this can evolve from:

```text
Haus → kuća
```

to complete sentences and expressions.

---

# 15. Listening Recognition

The application plays a Croatian recording.

The learner then identifies what was spoken.

Possible response mechanisms include:

* Selecting the corresponding Croatian word
* Selecting the German translation
* Typing the Croatian word
* Typing the translation
* Constructing the corresponding phrase

Native Croatian recordings are preferred.

Listening must be integrated into normal learning rather than being treated only as an optional special mode.

---

# 16. Fill-in-the-Blank Exercises

The learner receives an incomplete word, expression, or sentence.

Example:

```text
Ja ___ vodu.
```

The missing content may be:

* A word
* Several words
* A verb form
* A case form
* A preposition
* A pronoun
* A grammatical ending

Fill-in-the-blank exercises should increasingly be used to practise grammar as the learner progresses.

---

# 17. Sentence Construction

The learner builds a sentence from available words or phrase fragments.

This exercise becomes increasingly important as vocabulary grows.

The progression should begin with very simple structures and later combine previously learned concepts.

The system should use previously learned vocabulary to create increasingly realistic situations.

---

# 18. Exercise Randomization

Exercises should not always present material identically.

Randomization should be used where appropriate for:

* Choice ordering
* Matching positions
* Translation direction
* Exercise type
* Distractor words
* Previously learned vocabulary
* Review selection

However, randomization must remain pedagogically controlled.

It should not create impossible questions or introduce material the learner has never encountered unless the exercise explicitly teaches that new material.

---

# 19. Strict Correctness

CroLingo should teach correct language from the beginning.

The grading philosophy is:

> Correct is correct. Incorrect is incorrect.

Incorrect spelling should not silently pass.

The same applies where appropriate to:

* Croatian diacritics
* Word forms
* Verb forms
* Declensions
* Conjugation
* Grammar
* Required vocabulary
* Sentence construction

The purpose is to avoid teaching learners that approximately correct Croatian is sufficient.

---

# 20. Valid Alternative Answers

Strict grading does **not** mean comparing every answer with exactly one hard-coded string.

Croatian and German can permit multiple genuinely correct formulations.

The content model should therefore ultimately support:

* Multiple accepted translations
* Legitimate alternative word order
* Synonymous valid expressions
* Other grammatically valid answers

An answer should be rejected because it is linguistically incorrect, not merely because it differs from one reference string.

The exact evaluation model still needs to be designed carefully.

---

# 21. Immediate Feedback

Every submitted answer should receive immediate feedback.

For correct answers, feedback may include:

* Positive visual state
* Positive sound
* Short animation
* Haptic feedback
* Crow mascot reaction
* XP indication

For incorrect answers, feedback should include:

* Clear incorrect state
* The learner's answer
* The correct answer where appropriate
* What was wrong
* A concise explanation
* A retry opportunity
* Optional audio replay

The system should help the learner understand the mistake.

It should not merely flash red and continue.

---

# 22. No Hearts, Lives, or Attempt Restrictions

The MVP must explicitly **not implement a hearts/lives system**.

CroLingo should not contain mechanics where incorrect answers eventually prevent the learner from continuing.

Explicitly excluded:

* Hearts
* Lives
* Limited mistakes
* Waiting after too many mistakes
* Paying to restore attempts
* Paying to continue learning
* Artificial learning restrictions

The learner may keep attempting a task until it is understood.

Mistakes influence:

* XP
* Mastery
* Review frequency
* Spaced-repetition scheduling

They should not block access to learning.

---

# 23. XP System

CroLingo should award **experience points (XP)**.

XP provides immediate positive reinforcement and visible long-term progress.

A completed lesson always awards some XP.

The exact XP value should depend on factors such as:

* Lesson content
* Amount of vocabulary involved
* Difficulty
* Number of attempts
* Number of mistakes
* Correctness on the first attempt
* Overall performance

A flawless lesson should receive the maximum available XP.

A lesson completed with several errors receives less.

However:

> Completing a lesson always gives a positive reward.

Even a learner who struggles should receive recognition for eventually working through the lesson.

The exact XP formula remains to be defined.

---

# 24. Spaced Repetition — Core Requirement

**Spaced repetition is one of the core features of CroLingo and should be prominently documented in the project README and architecture.**

The system must maintain progress information for individual learning concepts.

This goes beyond vocabulary.

Tracked learning concepts may include:

* Individual words
* Expressions
* Phrases
* Sentences
* Verb forms
* Conjugations
* Declensions
* Grammatical structures
* Listening recognition
* Other recurring language concepts

Correct answers increase confidence and generally lengthen the time before required review.

Incorrect answers:

* Lower confidence
* Shorten the next review interval
* Increase review priority
* Cause the concept to appear more frequently

An item that was once strong must not remain permanently marked as mastered.

If the user later repeatedly answers it incorrectly, its mastery should decline again.

---

# 25. Spaced-Repetition Research

The exact spaced-repetition algorithm is not yet fixed.

Before implementation, established approaches and scientific literature should be reviewed.

The algorithm should determine things such as:

* Initial review interval
* How quickly intervals grow
* Effect of first-attempt correctness
* Effect of repeated mistakes
* How old knowledge decays
* How grammatical concepts are represented
* How vocabulary and phrases interact
* How multiple exercise types affect mastery
* When a previously strong item returns to review

This should be an explicit future design task rather than implementing an arbitrary counter system.

---

# 26. Dedicated Review Area

Review should be a first-class part of the product.

The application should contain a separate **Review** area in addition to lesson replay.

Potential review modes include:

* Recommended review
* Due items
* Weakest words
* Recent mistakes
* Last five learned words
* Recently learned material
* Random review
* Vocabulary review
* Grammar review
* Listening review
* Broad review of everything learned

The exact initial set of review modes can be determined during detailed design.

The primary recommended mode should eventually be driven by spaced repetition.

---

# 27. Vocabulary Tracking

CroLingo should maintain a personal vocabulary record for each learner.

For each vocabulary item, possible stored information includes:

* First encounter
* Last encounter
* Number of presentations
* First-attempt correct count
* Incorrect-attempt count
* Total attempts
* Last correct answer
* Last incorrect answer
* Current mastery estimate
* Current review priority
* Next scheduled review
* Related lesson
* Related unit
* Related expressions
* Audio recording

The vocabulary section should make learning progress visible rather than behaving only as a static dictionary.

---

# 28. Grammar Tracking

Spaced repetition should eventually extend beyond isolated vocabulary.

For example, the system should be able to recognize that a learner repeatedly struggles with:

* A particular declension
* A verb conjugation
* A grammatical case
* A sentence construction
* A preposition
* A particular verb form

These concepts can then receive additional future exercises.

This requires the content schema to identify which learning concepts an exercise tests.

---

# 29. Daily Streak

CroLingo should include a daily learning streak.

A streak represents consecutive calendar days in which at least one lesson was completed.

For the initial product, the day should be based on **Central European local time**.

A learning day runs from:

```text
00:00:00
```

through:

```text
23:59:59
```

local time.

Completing one complete lesson during that period satisfies the daily requirement.

A perfect lesson is not required.

The learner merely has to finish the lesson.

If learning occurs on consecutive days:

```text
currentStreak += 1
```

If an entire required calendar day is missed:

```text
currentStreak = 0
```

---

# 30. No Streak Protection in MVP

Streak protection was considered but explicitly rejected for the initial MVP.

There should initially be no:

* Streak freeze
* Grace day
* Purchased protection
* Automatic recovery
* Seven-day recharge mechanic
* Artificial restoration system

The streak should initially represent a real uninterrupted learning streak.

This can be reconsidered in a later product phase.

---

# 31. Profile and Statistics

The user should have a profile/statistics area containing meaningful local learning information.

It should include at least:

* Date learning started
* Current streak
* Longest streak
* Total XP
* Number of completed lessons
* Number of learned vocabulary items

Potential later statistics include:

* Number of exercises completed
* Total answers
* Accuracy
* Review items completed
* Study days
* Study time
* Units completed
* Pronunciation practice count

No social profile is required for the MVP.

---

# 32. Main Application Navigation

The application should have a clear main structure.

The currently intended top-level areas are:

## Home

The main dashboard.

Potential contents:

* Continue learning
* Current lesson
* Current streak
* XP
* Recent progress
* Quick access to review
* Unit progress

## Learning Path

Contains the predefined sequence of:

* Units
* Lessons
* Completed lessons
* Current lesson
* Locked future lessons
* Unit rewards

## Review

Contains personalized review opportunities.

## Vocabulary

Contains learned words and their progress.

## Grammar

Contains grammar material that has been introduced to the learner.

## Profile / Settings

Contains:

* Learning statistics
* Personal progress
* User preferences
* App settings

The exact navigation implementation should be determined through wireframes before production implementation.

---

# 33. Social Functionality

Social functionality is explicitly **not part of the MVP**.

The initial product does not need:

* Friends
* Followers
* Messaging
* Public profiles
* Leaderboards
* Competitive leagues
* User ranking
* Real-time interaction

These would require additional server infrastructure and are currently considered too far outside the core learning objective.

CroLingo should first prove that the local learning experience works well.

---

# 34. Pronunciation and Native Audio

A native Croatian speaker is available to produce pronunciation material.

Native audio should therefore be an important part of the application.

The application should support recordings for:

* Individual words
* Expressions
* Sentences
* Listening exercises

For pronunciation practice, the learner should initially be able to:

1. Listen to the native recording.
2. Record their own pronunciation.
3. Replay their recording.
4. Compare it with the native speaker.

---

# 35. Automated Pronunciation Evaluation

Automated pronunciation grading is a **high-priority secondary development goal**.

It does not have to block the first working MVP, but the architecture should make its later integration possible.

Potential future functionality includes:

* Speech recognition
* Recognition of whether the intended word was spoken
* Pronunciation score
* Word-level scoring
* Detection of problematic parts
* Targeted pronunciation feedback

The implementation method has **not yet been decided**.

It should not be assumed that comparing raw audio frequencies or waveforms is sufficient.

Pronunciation assessment requires proper research into:

* Speech recognition
* Acoustic models
* Phoneme recognition
* Croatian language support
* On-device versus server-side processing
* Accuracy
* Privacy
* Device compatibility

If implemented well, automated pronunciation feedback could become an important differentiating CroLingo feature.

---

# 36. Content Representation

Initial course content should be maintained in structured **JSON**.

JSON is preferred over YAML.

The content should not be hard-coded directly into individual UI screens.

The JSON model should eventually describe entities such as:

* Course
* Unit
* Lesson
* Task
* Exercise type
* Vocabulary item
* German text
* Croatian text
* Accepted answers
* Distractors
* Grammar concepts
* Audio identifiers
* Learning concepts
* Explanations
* Difficulty
* Review metadata

A conceptual structure might look like:

```json
{
  "course": {},
  "units": [],
  "vocabulary": [],
  "grammarConcepts": [],
  "audio": []
}
```

The exact schema remains to be designed.

---

# 37. Content Validation

Because course material will eventually become substantial, content should be automatically validated.

Validation should detect problems such as:

* Missing identifiers
* Invalid references
* Missing translations
* Missing required accepted answers
* Broken audio references
* Duplicate IDs
* Unknown exercise types
* Invalid unit ordering
* Invalid lesson ordering
* Exercises referring to unknown vocabulary
* New material appearing before introduction
* Malformed JSON

Content validation should eventually become part of CI.

---

# 38. Future Content Editor

Directly maintaining a large course in JSON will eventually become inconvenient.

A later phase should therefore introduce a dedicated authoring environment.

It might be:

* Web based
* Desktop based
* Another dedicated editing application

The exact technology has not been selected.

The editor should eventually support convenient management of:

* Vocabulary
* German translations
* Croatian translations
* Accepted variants
* Sentences
* Exercises
* Units
* Lessons
* Grammar concepts
* Audio
* Native-speaker recordings
* Review metadata

A database may become the canonical authoring source at that stage.

The editor could then export validated content packages consumed by the Android application.

---

# 39. AI-Assisted Content Creation

Future course-authoring tooling may support AI-assisted creation of:

* Vocabulary lists
* Example sentences
* Exercise variants
* Distractors
* Translation candidates
* Lesson drafts

AI-generated material should **not automatically become approved course content**.

There should eventually be a validation or human approval step before content reaches learners.

This is particularly important for:

* Croatian grammar
* Natural phrasing
* Accepted translations
* Pronunciation material
* Difficulty progression

---

# 40. Offline-First Application

The initial CroLingo application should work primarily locally.

Core learning should not depend on a cloud connection.

Local functionality should include:

* Course content
* Lessons
* Audio included with the app/content package
* User progress
* XP
* Streak
* Vocabulary mastery
* Review scheduling
* Exercise history
* Settings

The application should be usable without an account.

---

# 41. Future Backend

A cloud backend may be introduced later.

Potential purposes include:

* Downloading new course content
* Updating lessons
* Downloading new native-speaker recordings
* Synchronizing progress between devices
* Account management
* Cloud backup
* Future social functionality
* Content distribution
* Pronunciation services

The initial local architecture should therefore have clean boundaries so a backend can later be added without rewriting the entire application.

---

# 42. User Interface Quality

The visual design is a major product requirement.

CroLingo must not become a functionally correct application with an unattractive or improvised interface.

Substantial application development should therefore follow a design-first process.

The intended process is:

1. Define requirements.
2. Define information architecture.
3. Define primary user flows.
4. Define navigation.
5. Produce low-fidelity wireframes.
6. Define mascot direction.
7. Define colors and typography.
8. Produce representative high-fidelity screens.
9. Prototype major interactions.
10. Review the result.
11. Only then commit to the detailed production UI.

---

# 43. CroLingo Identity

The current project name is:

# CroLingo

The name intentionally connects:

* Croatian
* Language learning
* A crow/raven mascot

The application should have an original visual identity rather than copying Duolingo's green owl.

---

# 44. Crow Mascot

CroLingo should use a stylized crow as a recurring mascot.

The crow should be:

* Original
* Friendly
* Clever
* Curious
* Slightly mischievous
* Expressive
* Recognizable
* Suitable for animation
* Readable at small sizes

The preferred design direction is relatively simple and geometric.

This makes the mascot easier to:

* Animate
* Reuse
* Scale
* Turn into an icon
* Place inside lesson feedback
* Use consistently across the UI

---

# 45. Mascot Usage

The crow may appear in:

* Onboarding
* Lesson introductions
* Correct-answer feedback
* Incorrect-answer feedback
* Lesson completion
* Unit completion
* Streak milestones
* Empty states
* Review reminders
* Loading states
* Achievement screens

Small humorous or playful animations are desirable.

The mascot should help make the application entertaining without constantly interrupting the actual learning flow.

---

# 46. Visual Style

A completely black, grey, or gloomy interface should be avoided.

Although the mascot is a crow, the application itself should feel:

* Bright
* Friendly
* Modern
* Colorful
* Clean
* Polished
* Energetic

CroLingo should use Croatian-inspired colors.

Important visual references include:

* Red
* White
* Blue
* Croatian-style checkerboard motifs

The checkerboard should be used as an accent rather than filling every surface.

Possible uses include:

* Unit completion
* Headers
* Badges
* Borders
* Progress elements
* Mascot accessories
* Achievement cards

The goal is to make CroLingo recognizably Croatian without making it look like an official government application or simply reproducing the Croatian flag everywhere.

---

# 47. Animation and Sound

Small animations and sounds should reinforce interactions.

Potential uses include:

* Correct answers
* Incorrect answers
* XP gained
* Lesson completion
* Unit completion
* Crown earned
* Streak updated
* Crow reactions

Animations should remain short and responsive.

They should enhance the learning experience rather than slow down repeated exercises.

Sounds should have appropriate settings so they can be disabled.

---

# 48. Accessibility and Device Usability

Because CroLingo is smartphone-first, interaction must work well on touch devices.

Design should account for:

* Comfortable touch targets
* Readable typography
* Clear selected states
* High contrast
* Screen size differences
* Font scaling
* Audio controls
* Silent environments
* Dark and light appearance if implemented
* Accessibility labels

Exercise interactions should remain understandable without relying exclusively on color.

---

# 49. Open-Source Repository

CroLingo will initially be developed in a **public GitHub repository**.

People should be able to:

* Browse the project
* Clone it
* Build it locally
* Inspect its implementation
* Contribute if contribution rules are later established

The currently intended license is:

**GNU GPLv3**

The license decision should be finalized and reviewed before the first public release.

---

# 50. GitHub Actions and Quality Gates

The GitHub repository should contain CI workflows.

Relevant pushes and pull requests should automatically run quality checks.

Expected checks include:

* Flutter/Dart compilation for Android and Linux
* Unit tests
* Android lint
* Formatting verification
* Static analysis
* Content-schema validation
* Course-content validation
* Debug application build

Additional checks can later include:

* UI tests
* Screenshot tests
* Dependency analysis
* Security checks
* Release verification

Code that fails required quality gates should not be considered release-ready.

---

# 51. Release Automation

A separate GitHub Actions release workflow should eventually:

1. Run mandatory quality gates.
2. Build the release application.
3. Apply version information.
4. Sign the application.
5. Produce an APK.
6. Produce an Android App Bundle where required.
7. Generate release artifacts.
8. Attach them to an appropriate GitHub release.

Signing credentials must never be committed to the repository.

---

# 52. Distribution Strategy

The initial distribution model is:

* Public source code on GitHub
* Users may clone and build the application themselves
* APK releases may be distributed through GitHub

The longer-term goal is publication in the:

**Google Play Store**

The project should therefore ultimately support all required Android release and signing processes.

---

# 53. MVP Included Features

The MVP should include:

* Flutter Android application with Linux companion
* Dart
* German → Croatian course
* Croatian → German exercises
* Complete-beginner starting point
* CEFR A1 as the underlying course target
* Everyday-topic curriculum
* Predefined learning path
* Units
* Lessons
* Approximately five tasks per lesson
* Approximately two new items per early lesson
* Multiple initial exposures to new material
* Vocabulary matching
* Typed translation
* Listening recognition
* Fill-in-the-blank exercises
* Sentence construction
* Exercise randomization
* Strict grading
* Useful immediate feedback
* Unlimited retries
* Lesson progression
* XP
* Unit completion rewards
* Crowns or equivalent visible rewards
* Vocabulary tracking
* Grammar/concept tracking foundations
* Spaced repetition
* Dedicated review mode
* Audio-ready content identifiers for a later milestone
* Daily streak
* Current and longest streak statistics
* User profile/statistics
* Offline-first operation
* Local persistence
* No mandatory account
* Original CroLingo mascot
* Croatian-inspired visual identity
* Polished smartphone UI
* JSON-based course content
* Automated content validation
* Public GitHub repository
* GitHub Actions
* GPLv3 as the current intended license
* Automated Android release builds

---

# 54. Explicitly Excluded from the Initial MVP

The MVP should not contain:

* Hearts
* Lives
* Limited attempts
* Pay-to-continue mechanics
* Artificial learning restrictions
* Streak freezes
* Grace days
* Paid streak recovery
* Public leaderboards
* Competitive leagues
* Friends
* Followers
* Messaging
* Social-network functionality
* Mandatory accounts
* Mandatory cloud connectivity
* Cross-device synchronization
* Complex backend infrastructure
* English → Croatian course content
* Advertising
* Aggressive monetization
* Full automated pronunciation grading as an MVP blocker

---

# 55. Secondary High-Priority Features

The following are important but should not prevent the basic learning application from becoming functional:

## Automated Pronunciation Assessment

Research and implement meaningful automated pronunciation feedback.

## Course Authoring Tool

Build a convenient editor backed potentially by a database.

## AI-Assisted Course Authoring

Allow generated course material to enter a human validation workflow.

## Backend Content Distribution

Allow new course and audio packages to be downloaded.

## Cloud Synchronization

Synchronize progress between devices.

## Additional Source Languages

Especially English → Croatian.

---

# 56. Core Product Principles

## Learning Comes First

Every major product decision should improve language learning before engagement metrics or monetization.

## Correct Croatian Matters

CroLingo should teach correct language from the beginning.

## Low Frustration Does Not Mean Low Standards

The application should grade strictly but allow unlimited learning attempts.

## Small Steps

Introduce very little completely new information at once.

## Repetition Is Essential

A correct answer once does not equal mastery.

## Weak Knowledge Gets More Attention

Mistakes should increase future review frequency.

## Previously Learned Material Is Reused

Old vocabulary should continuously be combined with new vocabulary.

## Active Recall Matters

The learner should not only select answers but also type, listen, construct, and eventually speak.

## Positive Reinforcement

Every completed lesson should provide some reward even when many mistakes occurred.

## No Artificial Punishment

The application should never intentionally stop users from studying because they made mistakes.

## Offline First

The essential learning experience should work locally.

## Design Before Production UI

Major screens and workflows should be designed and reviewed before substantial UI implementation.

## Original Product Identity

CroLingo can borrow general educational ideas from successful language applications but must remain an independent product.

---

# 57. Data That Must Be Captured Per Attempt

Because XP, mastery, spaced repetition, and review all depend on learner history, individual task attempts should eventually record at least:

* User/profile identifier
* Lesson identifier
* Task identifier
* Learning-concept identifiers
* Exercise type
* Timestamp
* Presented prompt
* Submitted answer where appropriate
* Whether the attempt was correct
* Attempt number
* Time spent if useful
* Whether the final task was eventually completed
* XP contribution
* Resulting mastery changes

The exact privacy and storage model can be refined later.

---

# 58. Important Terminology to Standardize

The specification currently uses several levels that must remain distinct during implementation.

Recommended terminology:

**Course**
The complete German-to-Croatian learning program.

**Unit**
A larger thematic stage containing multiple lessons.

**Lesson**
One short learning session that normally contains approximately five tasks.

**Task**
One screen/question that the learner must eventually answer correctly.

**Attempt**
One submitted answer to a task.

**Learning Item / Learning Concept**
A vocabulary item, phrase, grammar construction, form, or other concept whose mastery can be tracked.

**Review Session**
A generated session containing previously encountered learning concepts.

This terminology should be used consistently in code, content schemas, documentation, and UI specifications.

---

# 59. Decisions Still Requiring Detailed Design

The broad product direction is now substantially defined, but several implementation-level questions remain intentionally open:

* Exact A1 curriculum and ordering
* Exact unit boundaries
* Exact vocabulary list
* Exact grammar progression
* Exact lesson generation rules
* Exact rule for three or more initial exposures
* Exact XP formula
* Exact mastery model
* Exact spaced-repetition algorithm
* Exact review modes for MVP
* Exact accepted-answer representation
* Exact handling of valid linguistic alternatives
* Exact JSON schema
* Exact audio file/package format
* Exact pronunciation architecture
* Exact navigation layout
* Exact visual design system
* Exact mascot design
* Exact GitHub project structure
* Exact Android minimum SDK
* Exact release/versioning strategy

These should be resolved progressively during curriculum design, UX design, and technical architecture work rather than guessed during implementation.

---

# 60. Consolidated Product Definition

> **CroLingo is an open-source Flutter application for Android and Linux that teaches complete German-speaking beginners Croatian toward approximately CEFR A1 through a predefined path of very small, everyday lessons. The first text-focused milestone reinforces new items through matching, typed translation, fill-in-the-blank, and sentence construction. Every task must eventually be solved correctly, retries are unlimited, and mistakes influence XP, mastery, and spaced review rather than blocking learning. The offline-first application stores validated JSON content and local progress, uses an original crow mascot and bright Croatian-inspired identity, and is developed under GPLv3 with strict local and online quality gates. Listening, native recordings, learner recording, and pronunciation assessment follow in a later milestone.**
