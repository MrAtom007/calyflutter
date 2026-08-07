# CaliStrack — Checklist operativa di lancio

Guida passo-passo per portare CaliStrack in produzione (Android/iOS), attivare la
telemetria e collegare i pagamenti reali. Spunta man mano.

---

## 0. Preparazione build

- [ ] `flutter pub get` senza errori
- [ ] `dart format lib test` pulito · `flutter analyze` senza issue · `flutter test` verde
- [ ] Versione aggiornata in `pubspec.yaml` (`version: X.Y.Z+build`)
- [ ] `android/key.properties` presente (firma release) e **non** committato
- [ ] `google-services.json` (Android) e `GoogleService-Info.plist` (iOS) al loro posto

---

## 1. Firebase: Analytics + Crashlytics (issue #4)

- [ ] `flutterfire configure` eseguito e include **Analytics** e **Crashlytics**
- [ ] Build **release** su un dispositivo reale:
      `flutter run --release` (Analytics/Crashlytics sono attivi solo in release)
- [ ] Firebase Console → **Analytics → DebugView**: compaiono gli eventi
      `app_open`, `onboarding_completed`, `workout_saved`, `level_up`
- [ ] Forza un crash di test e verifica che appaia in **Crashlytics**
      (es. `FirebaseCrashlytics.instance.crash()` temporaneo, poi rimuovi)
- [ ] Mapping/symbol upload ok (Android: plugin Crashlytics già configurato)

---

## 2. Google Play — Closed testing (issue #3)

- [ ] App creata su **Play Console** (package `com.calistrack.calistrack`)
- [ ] Scheda "Contenuti dell'app" completata (privacy, data safety, target audience)
- [ ] **Privacy policy** pubblicata e URL inserito
- [ ] Genera l'AAB firmato:
      `flutter build appbundle --release`
- [ ] Carica l'AAB sul track **Closed testing**
- [ ] Aggiungi i tester (lista email o Google Group) — servono **12 opt-in attivi**
- [ ] Invia la guida `store/closed-testing-tester-guide.md` ai tester
- [ ] I tester **accettano l'opt-in** e **non disinstallano** per **14 giorni**
- [ ] Trascorsi i 14 giorni: richiedi l'accesso alla produzione

---

## 3. App Store (iOS) — opzionale in parallelo

- [ ] App creata su **App Store Connect** (Bundle ID coerente)
- [ ] Certificati/Profili di firma (Apple Developer Program)
- [ ] `flutter build ipa --release` e upload via Xcode/Transporter
- [ ] TestFlight per il test interno/esterno
- [ ] Scheda store + privacy compilate

---

## 4. Store listing / ASO (issue #5)

- [ ] Titolo, descrizione breve e completa da `store/ASO-listing.md` (IT/EN)
- [ ] Keyword field App Store impostato
- [ ] **5 screenshot** caricati (`CaliStrack-Presentazioni/store-screenshots/`)
- [ ] Feature graphic 1024×500 (Play)
- [ ] Icona 512×512 (Play) / icone iOS
- [ ] (Consigliato) Store Listing Experiment su icona + primo screenshot (issue #8)

---

## 5. Monetizzazione reale — RevenueCat (issue #6/#7)

> Lo scaffold è già in `MonetizationService` (dietro feature-flag).

- [ ] Crea progetto su **RevenueCat** e collega Play/App Store
- [ ] Crea l'**entitlement** `premium`
- [ ] Crea i **prodotti** (es. "unlock_all" one-time, eventuale subscription)
      su Play Console e App Store Connect e mappali su RevenueCat
- [ ] Recupera le **API key** pubbliche (Android `goog_...`, iOS `appl_...`)
- [ ] Build con le key iniettate:
      ```bash
      flutter build appbundle --release \
        --dart-define=RC_ANDROID_KEY=goog_xxx \
        --dart-define=RC_IOS_KEY=appl_xxx
      ```
- [ ] Testa acquisto con account di test (Play: license testing / App Store sandbox)
- [ ] Verifica **Restore purchases** su un secondo dispositivo
- [ ] Conferma che `hasPremium` sblocca temi/icone e logga `purchase_completed`

---

## 6. Rilascio in produzione

- [ ] Promuovi la build da Closed testing → Production (Play)
- [ ] Rollout graduale (es. 20% → 50% → 100%) monitorando Crashlytics
- [ ] Monitora eventi/funnel su Analytics nei primi giorni
- [ ] Prepara una prima nota di rilascio (changelog)

---

## Comandi rapidi

```bash
# Qualità
dart format lib test && flutter analyze && flutter test

# Build Android (con pagamenti reali)
flutter build appbundle --release \
  --dart-define=RC_ANDROID_KEY=goog_xxx --dart-define=RC_IOS_KEY=appl_xxx

# Build iOS
flutter build ipa --release
```

## Riferimenti nel repo
- Guida tester: `store/closed-testing-tester-guide.md`
- Testi store/ASO: `store/ASO-listing.md`
- Telemetria: `lib/services/analytics_service.dart`
- Pagamenti: `lib/services/monetization_service.dart`
