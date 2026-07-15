# BrightBound Roku

BrightBound is a child-safe learning world for Roku. A learner's companion grows from demonstrated understanding, persistence, corrected mistakes, independent success, and completed knowledge journeys rather than coins, purchases, streak pressure, or arbitrary XP.

## Implemented vertical slice

- Native Roku SceneGraph bootstrap
- Startup profile selection with up to five independent learners
- Automatic migration of the original single-profile save into profile slot 1
- Separate companion, mastery, journey, beacon, galaxy, spacecraft, checkpoint, and settings data per profile
- Pond home with Spark Tadpole
- Remote-controlled addition activity
- Concept discovery and evidence tracking
- Corrected-mistake recognition
- Deterministic First Ripple milestone
- Tadpole-to-Pathfinder Polliwog evolution
- Launch terminal with two original spacecraft
- Milky Way and fictional Astraea Prime maps
- Upcoming event catalog filtered by device date
- Playable three-lane flight mission
- Three knowledge-beacon challenges
- Persistent journey, beacon, galaxy, and spacecraft history
- Safe abort and return navigation

## Controls

### Profile selection

- `UP` / `DOWN` chooses one of five profile slots
- `OK` enters an existing learner or creates a new Explorer in an empty slot

### Pond

- `OK` begins a learning activity
- `DOWN` opens the launch terminal
- `BACK` returns to profile selection

### Launch terminal

- `LEFT` / `RIGHT` changes spacecraft
- `UP` / `DOWN` changes galaxy
- `OK` launches the selected mission
- `BACK` returns to the pond

### Flight mission

- `LEFT` / `RIGHT` steers between beacon lanes
- `OK` scans the selected beacon
- `LEFT` / `RIGHT` answers a beacon challenge
- `BACK` cancels a scan or safely aborts the mission

## Repository structure

- `manifest` - Roku package metadata
- `source/main.brs` - channel bootstrap
- `source/SaveService.brs` - five-profile registry persistence and migration
- `source/MasteryEngine.brs` - evidence and evolution rules
- `source/ContentService.brs` - validated JSON content loading
- `data/` - spacecraft and galaxy catalogs
- `components/ProfileSelectionScreen.*` - five-slot learner selection and creation
- `components/AppScene.*` - application state coordination
- `components/LaunchTerminalScreen.*` - craft and galaxy selection
- `components/FlightScreen.*` - knowledge-beacon flight gameplay

## Package and sideload

Zip the repository contents so `manifest`, `source/`, `components/`, and `data/` are at the archive root. Upload the ZIP through the Roku development installer after enabling Developer Mode.

## Current limitations

- Device compilation and focus behavior still require validation on physical Roku hardware.
- New profiles receive automatic names such as `Explorer 2`; profile renaming is not implemented yet.
- Profile deletion and parent PIN protection are not implemented yet.
- Flight currently uses discrete lane steering rather than continuous movement.
- The first learning activity contains six authored questions.
- Companion and spacecraft visuals use native shapes until the original art pipeline is added.
- Cloud synchronization, audio narration, and later companion stages are not implemented yet.

## Next phase

Add profile naming and parent controls, moving hazards and collectibles, destination-specific missions, companion co-pilot behavior, reduced-motion handling, authored content catalogs, automated BrightScript tests, XML/reference validation, and packaging automation.
