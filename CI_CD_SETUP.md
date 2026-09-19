# Secrets necessari per CI/CD Play Console

Configura questi secrets in GitHub: **Settings → Secrets and variables → Actions → New repository secret**

## 1. Firma Android (OBBLIGATORIO per build firmata)

| Secret | Descrizione | Come ottenere |
|--------|-------------|---------------|
| `KEY_STORE_FILE` | File keystore `.jks` o `.keystore` codificato in **base64** | `base64 -w0 tuo-keystore.jks` |
| `KEY_STORE_PASSWORD` | Password del keystore | Quella che hai scelto alla creazione |
| `KEY_ALIAS` | Alias della chiave (es. `upload` o `release`) | `keytool -list -keystore tuo-keystore.jks` |
| `KEY_PASSWORD` | Password della chiave specifica | Spesso uguale a store password |

> **Nota:** Il `key.properties` locale NON viene committato. Il workflow lo ricrea dai secrets.

## 2. Google Play Console (OBBLIGATORIO per deploy automatico)

### Opzione A: Service Account (raccomandato)
1. **Google Cloud Console** → IAM & Admin → Service Accounts
2. Crea service account → Ruoli: **Service Account User** + **Project Viewer** (minimo)
3. **Play Console** → Setup → API access → Linka il service account → Ruolo: **Release Manager**
4. Scarica chiave JSON → Codifica in base64: `base64 -w0 service-account.json`
5. Secret: `PLAY_SERVICE_ACCOUNT_KEY` = output base64

### Opzione B: fastlane (alternativa)
1. Stesso service account sopra
2. Secret: `FASTLANE_KEY` = base64 della chiave JSON
3. Il workflow userà `fastlane supply` come fallback

## 3. Firebase (opzionale, per firebase_options.dart in CI)
| Secret | Descrizione |
|--------|-------------|
| `FIREBASE_CONFIG_ANDROID` | `google-services.json` base64 |
| `FIREBASE_CONFIG_IOS` | `GoogleService-Info.plist` base64 |

## 4. Test su device farm (opzionale)
| Secret | Descrizione |
|--------|-------------|
| `FIREBASE_TEST_LAB_KEY` | Service account per Firebase Test Lab |

---

## Come testare in locale prima del push

```bash
# 1. Crea key.properties locale (NON committare)
cat > android/key.properties <<EOF
storeFile=../app/keystore.jks
storePassword=TUA_PASSWORD
keyAlias=TUO_ALIAS
keyPassword=TUA_PASSWORD
EOF

# 2. Build locale AAB firmato
flutter build appbundle --release

# 3. Verifica AAB
ls -lh build/app/outputs/bundle/release/*.aab

# 4. Test su device/emulator
flutter install --release
```

---

## Track Play Console - quale usare?

| Track | Tester max | Approvazione | Uso |
|-------|------------|--------------|-----|
| **Internal** | 100 | Quasi istantanea (minuti) | **Inizia qui** - superi requisito "12 tester" |
| **Closed Alpha** | Illimitati | Ore/giorni | Dopo internal, per gruppo più ampio |
| **Open Beta** | Illimitati | Giorni | Pubblico, chiunque può unirsi |
| **Production** | Tutti | Giorni + review | Solo dopo alpha/beta stabili |

**Strategia consigliata:**
1. Deploy su **Internal** via workflow
2. Aggiungi 12+ email reali in Play Console → Internal Testing → Testers
3. Aspetta 14 giorni (requisito Google)
4. Promuovi ad **Alpha** → poi **Production** (da Play Console UI o workflow con `track: production`)

---

## Comandi utili

```bash
# Trigger manuale da CLI
gh workflow run android-deploy.yml -f track=internal

# Con version override
gh workflow run android-deploy.yml -f track=internal -f version_name=4.15.0 -f version_code=35

# Vedi run recenti
gh run list --workflow=android-deploy.yml --limit=5

# Scarica AAB artifact
gh run download <run-id> -n app-release-aab
```