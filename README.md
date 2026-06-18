# MeetGuard

MeetGuard is a native macOS menu bar app that reads local Calendar events and shows a fullscreen alert before online meetings. It runs locally, uses EventKit, has no third-party dependencies, and does not initiate network communication.

## Requirements

- macOS 13 or newer
- Xcode 26 or newer, or the matching Apple Swift toolchain

## Build

```sh
swift build
```

## Test

```sh
swift test
```

## Run as a macOS app

The app needs an app bundle so macOS can apply `LSUIElement` and the Calendar permission usage strings.

```sh
make run
```

This builds `.build/app/MeetGuard.app` and opens it. MeetGuard appears only in the menu bar, requests Calendar access on first launch, and does not show a Dock icon.

To build the bundle without opening it:

```sh
make app
```

## Development

Useful commands:

```sh
make build
make test
make app
make run
make clean
```

The app scans today's events from all calendars visible to Calendar.app. It inspects event URL, notes, location, and title for conferencing links from Google Meet, Zoom, Microsoft Teams, Webex, plus generic `/join` and `/meeting` URLs.

## Architecture

- `CalendarService`: EventKit permission, event fetching, conversion into meetings.
- `MeetingDetector`: regex-based meeting URL extraction.
- `ReminderScheduler`: lead-time checks, duplicate protection, dismiss and postpone state.
- `OverlayManager`: fullscreen overlay windows on all connected displays.
- `SettingsStore`: persisted settings in `UserDefaults`.

## Settings

Open the menu bar item and choose `Settings...`.

Default:

- Notify before meeting: 1 minute
- Launch at startup: enabled

The `Preview` button shows the fullscreen overlay using the first conference-link event found today, then the next 10 days. If none is found, MeetGuard uses sample meeting text and opens `https://example.com` when joining.

## Privacy

MeetGuard requests Calendar access only. It does not use analytics, telemetry, cloud sync, or third-party frameworks.
