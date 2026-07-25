# CaliStrack (Flutter)

App mobile per il tracking degli allenamenti di **calisthenics** e **palestra**, riscritta in **Flutter/Dart** (port dalla versione originale Expo/React Native v2.6.0).

## Funzionalità

- 📓 **Diario allenamenti** – registra e rivedi le tue sessioni
- 🤸🏋️ **Due discipline** – Calisthenics e Palestra con switch dedicato
- ➕ **Nuovo allenamento** – set per esercizio con reps, secondi o peso
- 📋 **Routine predefinite** – avviabili con un tap
- 📚 **Libreria esercizi** – ~150 esercizi con ricerca, media e tutorial
- 📊 **Progressi** – grafici (fl_chart), top esercizi, export CSV/JSON
- 🏅 **Ranghi e medaglie** – da Legno ad Antimateria con overlay level-up
- ⏱️ **Timer** – countdown con preset e vibrazione
- 🎨 **Temi** – 6 skin free + 4 skin neon premium (Neon Store)
- 🔒 **Sicurezza** – PIN (SHA-256), biometria, blocco dispositivo, cifratura AES-256
- 🔔 **Promemoria** – notifiche locali settimanali

## Stack

- Flutter 3.44 / Dart 3.12
- provider (state management)
- shared_preferences + flutter_secure_storage (persistenza)
- encrypt / crypto (AES-256 + SHA-256)
- local_auth, flutter_local_notifications
- fl_chart, cached_network_image, webview_flutter, video_player
- share_plus, path_provider, image_picker

## Avvio

```bash
flutter pub get
flutter run            # dispositivo/emulatore collegato
flutter build apk      # Android (richiede Android SDK)
flutter build web      # browser
```

## Struttura

```
lib/
  main.dart              entry point + provider
  app.dart               gate: loading / lock / onboarding / app
  theme/app_theme.dart   10 skin, spacing, glow
  models/                Exercise, Workout
  data/                  exercises, gym, ranks, routines, media, icons
  services/              storage, crypto, security, notifications, export
  state/                 provider ChangeNotifier
  screens/               tutte le schermate
  widgets/               Medal, charts, DisciplineSwitch, level-up overlay
```

Il codice originale Expo è conservato in `legacy_expo/` come riferimento.
