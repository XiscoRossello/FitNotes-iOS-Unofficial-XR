# FitNotes-iOS (Fork)

This repository is a fork/adaptation of the original FitNotes iOS project:
- Original repository: https://github.com/mylesverdon/FitNotes-iOS

Maintainer of this fork:
- xiscorossello

The app is inspired by [FitNotes Android](https://www.fitnotesapp.com/) and focused on practical daily training tracking on iPhone.

## Release Status

This fork is currently in **beta**.

- Version: **0.1.0 Beta**
- Stability: **not stable for production use**
- Recommendation: use with caution and keep regular backups before important data changes.

## Main Features

- Import workouts from Android FitNotes backup.
- Track reps, weight, distance and time per set.
- Custom exercises and exercise categories.
- Category-based exercise picker.
- Rest timer linked to exercises (with controls and notifications).
- Personal records (PR) with history/trophy markers.
- Copy workout from previous day.
- Workout templates (save/apply).

## Changes Added In This Fork

- Improved rest timer UX:
	- direct editing of default rest time,
	- live countdown in timer view,
	- pause/resume controls,
	- plus/minus 10s controls when paused.
- Long-press actions on workout exercise cards:
	- replace exercise while preserving sets,
	- delete exercise and sets.
- Calendar improvements:
	- category color dots under each day,
	- removed green number highlight to avoid duplicate visual signals.
- Android import parser updates based on real backup structure.
- Distinct category color palette and migration for existing data.
- Manage Exercises view refactor:
	- grouped/ordered by category.
- Add Exercise flow improvement:
	- "Create Exercise" directly from inside selected category.
- Stability fixes:
	- safer metrics rendering without force unwraps,
	- safer delete flow for groups/sets.

## Build (Simulator)

```bash
cd /FitNotes-iOS
xcodebuild -project FitNotes.xcodeproj -scheme FitNotes -destination "platform=iOS Simulator,name=iPhone 17" build
```

## Build IPA For AltServer / AltStore

AltServer signs the IPA during sideload with your Apple ID. The script below generates an unsigned IPA suitable for AltServer:

```bash
cd /FitNotes-iOS
chmod +x scripts/build_ipa_for_altserver.sh
./scripts/build_ipa_for_altserver.sh
```

Output:
- `build/FitNotesIOS_0.1.0.ipa`

Then in AltServer/AltStore choose this IPA to install on device.


