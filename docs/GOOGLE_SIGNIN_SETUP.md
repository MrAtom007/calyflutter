# Configurazione Google Sign-In (produzione)

Il login Google in CaliStrack usa `google_sign_in`. Serve **un tuo progetto**
Google Cloud con gli OAuth client. Nessun file segreto va committato: Android
funziona registrando l'impronta SHA-1; iOS usa il Client ID nell'`Info.plist`.

> Nota: i **dati dei wearable** (Garmin, Samsung Health, Honor, Google) arrivano
> da **Health Connect / Apple Health**, non dall'account Google. Il login Google
> serve solo per identità/profilo.

## Dati del progetto

| Campo | Valore |
|---|---|
| Package / Bundle ID | `com.calistrack.calistrack` |
| SHA-1 (debug keystore) | `C5:C6:4C:CC:DA:BC:87:F2:EB:32:8D:A0:03:AD:DC:59:D1:92:DA:4C` |

Per la release firmata, ottieni lo SHA-1 del **tuo** keystore di produzione:

```bash
keytool -list -v -keystore /percorso/release.jks -alias TUO_ALIAS
```

## 1. Google Cloud Console

1. Vai su https://console.cloud.google.com/ → crea/seleziona un progetto.
2. **API e servizi → Schermata consenso OAuth**: configurala (External, nome
   app, email di supporto). Aggiungi te stesso come utente di test.
3. **API e servizi → Credenziali → Crea credenziali → ID client OAuth**.

### Android
- Tipo applicazione: **Android**
- Nome pacchetto: `com.calistrack.calistrack`
- Impronta SHA-1: quella sopra (debug) e/o quella di release.
- Crea. Su Android **non serve** alcun file nell'app: basta la registrazione.

### iOS
- Tipo applicazione: **iOS**
- Bundle ID: `com.calistrack.calistrack`
- Crea. Prendi nota di **iOS Client ID** e **Reversed Client ID**.

## 2. Config iOS (`ios/Runner/Info.plist`)

Sostituisci i placeholder già presenti:

- `GIDClientID` → `TUO_IOS_CLIENT_ID.apps.googleusercontent.com`
- URL scheme → `com.googleusercontent.apps.TUO_REVERSED_CLIENT_ID`

## 3. Verifica

```bash
flutter clean && flutter pub get
flutter run           # Android o iOS
# Salute → "Accedi con Google"
```

Se il login si chiude subito senza errori su Android, di solito significa
SHA-1 o package name non combacianti in Cloud Console.
