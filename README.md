# CaliStrack (Flutter) — v4.0.0

App mobile per il tracking degli allenamenti di **calisthenics** e **palestra**, riscritta in **Flutter/Dart** (port dalla versione originale Expo/React Native v2.6.0).

La **v4.0.0** introduce: **sezione Salute** con dati da wearable (Health Connect /
Apple Health: Garmin, Samsung Health, Honor Health, Google) e sinusoidi/grafici
spettacolari, **Home a widget personalizzabile** (riordina/aggiungi/rimuovi),
**personalizzazione spinta** (densità, colore d'accento, stile card), **temi
epici** (Spartacus, Kratos, Ulisse, Zeus, Cyberpunk), **icona app cambiabile**
con stili diversi (Android + iOS) e **widget da schermata home del telefono** con
deep-link.

## Funzionalità

- 🏠 **Home a widget** – dashboard personalizzabile: riordina, aggiungi e rimuovi widget
- ❤️ **Salute** – battiti (sinusoide ECG live), pressione, SpO2, HRV, passi, calorie, sonno
- 🔗 **Wearable** – dati reali da Health Connect (Android) / Apple Health (iOS) + login Google + modalità demo
- 📱 **Widget home telefono** – battiti e passi sulla home del telefono, con deep-link alla sezione
- 📓 **Diario allenamenti** – registra e rivedi le tue sessioni
- 🤸🏋️ **Due discipline** – Calisthenics e Palestra con switch dedicato
- ➕ **Nuovo allenamento** – set per esercizio con reps, secondi o peso
- 📋 **Routine predefinite** – avviabili con un tap
- 📚 **Libreria esercizi** – ~150 esercizi con ricerca, media e tutorial
- 📊 **Progressi** – grafici (fl_chart), top esercizi, export CSV/JSON
- 🏅 **Ranghi e medaglie** – da Legno ad Antimateria con overlay level-up
- ⏱️ **Timer** – countdown con preset e vibrazione
- 🎨 **Temi & aspetto** – 17 skin free + neon premium, densità, accento, stile card
- 🖼️ **Icona app** – 5 stili (Ulisse, Zeus, Cyberpunk, Spartacus, Kratos)
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
- health (Health Connect / Apple Health), google_sign_in, home_widget

## Avvio

```bash
flutter pub get
flutter run            # dispositivo/emulatore collegato
flutter build apk      # Android (richiede Android SDK)
flutter build web      # browser
```

## Configurazione Google Sign-In (google-services.json)

Il file `android/app/google-services.json` **non è versionato** (contiene chiavi
del progetto Firebase) ed è escluso via `.gitignore`. Su una nuova macchina va
ricreato, altrimenti l'app compila ma il login Google fallisce.

1. [console.firebase.google.com](https://console.firebase.google.com) → progetto **CaliStrack**.
2. ⚙️ **Impostazioni progetto** → scheda **Generali** → app Android
   `com.calistrack.calistrack`.
3. Aggiungi la **SHA-1** della chiave con cui firmi la build. Per la chiave di
   debug (usata anche dalla release attuale):
   ```bash
   keytool -list -v -keystore ~/.android/debug.keystore \
     -alias androiddebugkey -storepass android | grep SHA1
   ```
   Se `keytool` va in errore per la locale, aggiungi
   `-J-Duser.language=en -J-Duser.country=US`.
4. **Authentication** → *Sign-in method* → abilita **Google**.
5. Scarica `google-services.json` e mettilo in **`android/app/`**.

> Nota: un keystore di release diverso (o la firma del Play Store) ha una SHA-1
> differente, da aggiungere anch'essa in Firebase.

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
