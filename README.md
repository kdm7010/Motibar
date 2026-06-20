# Motibar

Motibar is a small macOS menu bar Pomodoro timer. It lets you choose separate completion images and alarm sounds for work and break sessions so each transition can end with a personalized prompt.

## Features

- Menu bar resident Pomodoro timer
- Work and break duration controls
- Custom image popup for work and break completions
- Custom audio alarm for work and break completions
- Settings are stored locally with `UserDefaults`
- SwiftPM-based build with no third-party dependencies

## Requirements

- macOS 13 or later
- Xcode command line tools or Xcode with Swift 5.9+

## Build and Run

```bash
./script/build_and_run.sh
```

The script builds the SwiftPM executable, stages a local app bundle at `dist/Motibar.app`, and launches it as a menu bar app.

Useful modes:

```bash
./script/build_and_run.sh --verify
./script/build_and_run.sh --logs
./script/build_and_run.sh --debug
```

## Usage

1. Launch Motibar.
2. Open the menu bar item.
3. Set work and break durations.
4. Open Settings to choose separate image and audio files for work completion and break completion.
5. Start the timer.

When a work or break timer finishes, Motibar plays the audio file and shows the image configured for that specific phase. If no media is selected or playback fails, the app falls back to the system beep and a simple completion view.

## Open Source Notes

This repository intentionally avoids bundling personal media files. User-selected image and audio paths are stored only in local macOS preferences and should not be committed.

## License

MIT
