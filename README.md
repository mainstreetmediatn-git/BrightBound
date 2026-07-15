# BrightBound Roku

BrightBound is a child-safe learning world for Roku. A learner's companion grows from demonstrated understanding, persistence, corrected mistakes, and independent success rather than coins, purchases, streak pressure, or arbitrary XP.

## Implemented vertical slice

- Native Roku SceneGraph bootstrap
- Persistent local learner profile
- Pond home with Spark Tadpole
- Remote-controlled addition activity
- Concept discovery and evidence tracking
- Corrected-mistake recognition
- Deterministic First Ripple milestone
- Tadpole-to-Pathfinder Polliwog evolution
- Persistent learner title and companion stage
- Back-button handling inside the activity

## Repository structure

- `manifest` - Roku package metadata
- `source/main.brs` - channel bootstrap
- `source/SaveService.brs` - versioned registry persistence
- `source/MasteryEngine.brs` - pure evidence and evolution rules
- `components/AppScene.xml` - pond, quiz, and evolution presentation
- `components/AppScene.brs` - state transitions and remote input

## Package and sideload

Zip the repository contents so `manifest`, `source/`, and `components/` are at the archive root. Upload the ZIP through the Roku development installer after enabling Developer Mode.

## Current limitations

- Device compilation and focus behavior still require validation on physical Roku hardware.
- The first activity currently contains six authored questions.
- The visual companion uses native shapes until the original BrightBound art pipeline is added.
- Cloud profile synchronization, multiple profiles, audio, captions narration, and later companion stages are not implemented in this slice.

## Next phase

Add a profile selector, twelve-question content catalog, reduced-motion evolution sequence, companion journal, automated BrightScript tests, XML/reference validation, and packaging workflow.
