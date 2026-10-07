# Lock In App

A minimalist black & white Flutter app with three pages:

- **Home** — daily water-intake tracking saved on the device, a focus-session card, and four daily exercise instructions from the free wger API
- **Tasks** — tappable checklist with live progress and a dialog for adding tasks
- **Profile** — create a local account, log in/out, and view the saved account details

## Run

```bash
flutter pub get
flutter run
```

Account details and water intake are stored locally on the device. Daily workout instructions require an internet connection and are provided by [wger](https://wger.de), licensed under CC BY-SA 4.0.

Tweak the palette in `LockInColors` and the typography in `dot()` to adjust the look.
