# CaliStrack — Roadmap

Stato attuale: **v2.6.0** (tutto consolidato su `main`, build APK cumulativa).

## Completato in v2.6.0

### Animazioni
- [x] Feedback di pressione (PressableScale) su: salva allenamento, controlli e
      preset del timer, pulsanti dello Store, chip categoria ed esercizi in
      "Nuovo allenamento", selettori dei grafici.
- [x] Transizioni animate tra schermate (`slide_from_right`) e tra tab (`shift`).
- [x] Animazione d'ingresso della LockScreen (header, pallini e tastierino in sequenza).
- [x] Micro-animazioni sulle chip categoria in "Nuovo allenamento".

### Grafici / dati
- [x] Selettore intervallo temporale sui grafici (4/8/12 settimane, 6/12 mesi).
- [x] Linea del record (PR) orizzontale di riferimento sui grafici
      (Progressi e Dettaglio esercizio).
- [x] Esportazione dati allenamenti (CSV/JSON) e condivisione
      (in Progressi e in Impostazioni → Backup e privacy).
- [x] Confronto tra esercizi (selezione di due esercizi con grafici sovrapposti
      e tabella comparativa: sessioni, record, volume totale).

### Funzionalità
- [x] Mappa media "curated" con tag immagine e query video mirate per i ~30
      esercizi più comuni (`src/data/media.js`).
- [x] Caricamento di video personali per esercizio (oltre alle foto), con player
      nativo in-app (`expo-av`).
- [x] Promemoria/notifiche allenamento locali ricorrenti (giorni + orario) via
      `expo-notifications` (Impostazioni → Promemoria allenamento).
- [x] Cifratura end-to-end (at-rest) della cronologia allenamenti: AES-256
      con chiave nel Secure Store (`src/crypto.js`, toggle in Impostazioni).

## Idee/task ancora in sospeso

### Distribuzione
- [ ] Generare l'AAB di produzione (`eas build -p android --profile production`) per il Play Store.
- [ ] Eventuale build iOS.

### Possibili estensioni future
- [ ] Integrazione pagamenti reali per lo Store (Play Billing / RevenueCat).
- [ ] Import da backup JSON dall'interfaccia (la funzione `importWorkouts` è già pronta in `storage.js`).
- [ ] Video/immagini curate proprietarie (host dedicato) al posto dei fallback.
- [ ] Sincronizzazione cloud opzionale (mantenendo la cifratura E2E).

## Come riprendere le build
```bash
cd /home/mratom/development/git/calistrack
# login o token
EXPO_TOKEN=<token> npx eas-cli build -p android --profile preview --non-interactive
```
Ogni build è cumulativa: include automaticamente tutte le modifiche presenti su `main`.
