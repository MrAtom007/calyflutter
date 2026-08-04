# CaliStrack — Roadmap

Stato attuale: **v4.1.7** (Flutter/Dart, port dalla versione originale Expo/RN v2.6.0).
Tutto consolidato su `main`.

## Completato

### Core allenamenti
- [x] Diario allenamenti (registra e rivedi sessioni)
- [x] Due discipline (Calisthenics / Palestra) con switch dedicato
- [x] Nuovo allenamento con set per esercizio (reps, secondi o peso)
- [x] Routine predefinite avviabili con un tap
- [x] Libreria esercizi (~150) con ricerca, media e tutorial
- [x] Timer countdown con preset e vibrazione

### Salute & wearable (v4.0.0)
- [x] Sezione Salute: battiti (sinusoide ECG live), pressione, SpO2, HRV,
      passi, calorie, sonno
- [x] Dati reali da Health Connect (Android) / Apple Health (iOS) + login
      Google + modalità demo
- [x] Onboarding salute e obiettivi salute
- [x] Widget da schermata home del telefono (battiti/passi) con deep-link

### Home & personalizzazione
- [x] Home a widget personalizzabile (riordina/aggiungi/rimuovi)
- [x] Personalizzazione: densità, colore d'accento, stile card
- [x] Temi epici (Spartacus, Kratos, Ulisse, Zeus, Cyberpunk) — 17 skin free
      + neon premium
- [x] Icona app cambiabile: 5 stili con emblemi tematici (Android + iOS) e
      anteprime in-app (v4.1.x)

### Progressi & dati
- [x] Grafici (fl_chart), top esercizi, linea del record (PR)
- [x] Selettore intervallo temporale sui grafici
- [x] Confronto tra esercizi
- [x] Export dati (CSV/JSON) e condivisione
- [x] Ranghi e medaglie (da Legno ad Antimateria) con overlay level-up

### Sicurezza & notifiche
- [x] PIN (SHA-256), biometria, blocco dispositivo
- [x] Cifratura at-rest AES-256 della cronologia
- [x] Promemoria/notifiche locali settimanali

## Idee/task ancora in sospeso

### Distribuzione
- [ ] Build AAB di produzione per il Play Store
- [~] Build iOS / TestFlight
  - [x] Firebase iOS configurato (`flutterfire configure`): sezione iOS in
    `lib/firebase_options.dart` + `GoogleService-Info.plist` in `ios/Runner/`
    aggiunto al target Xcode (build file / group / Resources)
  - [x] `firebase_options.dart` e `GoogleService-Info.plist` committati (config
    client) così la CI iOS compila senza segreti aggiuntivi
  - [x] Workflow CI `ios-build.yml`: IPA NON firmato su runner macOS come artifact
  - [ ] Build FIRMATA per TestFlight/App Store: Apple Developer Program,
    certificato di distribuzione (.p12) + provisioning profile come secrets,
    `ios/ExportOptions.plist`, step `flutter build ipa`

### Prossimo task
- [x] **Icone launcher native per i nuovi temi leggendari** (cavaliere, cerberus,
      igris, sukuna, toji) — Android:
      - [x] Icona adattiva vettoriale per soggetto (foreground/background/monochrome)
      - [x] `<activity-alias>` in `AndroidManifest.xml` (una per icona) + alias in
        `MainActivity.kt` + stringhe dock + voce in `AppIconService.styles`
        (`premium/themeId`)
      - [ ] iOS: `.appiconset` + mappa in `AppDelegate.swift` (rimandato: come per
        gli altri temi leggendari, le icone iOS alternative non sono ancora fornite)

### Possibili estensioni future
- [ ] Integrazione pagamenti reali per i contenuti premium (Play Billing / RevenueCat)
- [ ] Import da backup JSON dall'interfaccia (funzione già presente in StorageService)
- [ ] Video/immagini curate proprietarie (host dedicato) al posto dei fallback
- [ ] Sincronizzazione cloud opzionale (mantenendo la cifratura E2E)

## Build
```bash
flutter pub get
flutter run          # dispositivo/emulatore collegato
flutter build apk    # Android
flutter build web    # browser
```
